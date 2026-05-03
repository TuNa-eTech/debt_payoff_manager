import { createHash, randomBytes } from "crypto";

import { initializeApp } from "firebase-admin/app";
import {
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();

const db = getFirestore();

type ShareMode = "readonly" | "collaborative";
type PremiumPlatform = "ios" | "android";

interface VerifyPurchasePayload {
  platform: PremiumPlatform;
  productId: string;
  transactionId?: string;
  verificationData?: {
    localVerificationData?: string;
    serverVerificationData?: string;
    source?: string;
  };
}

interface EntitlementDoc {
  active: boolean;
  productId: string | null;
  platform: PremiumPlatform | null;
  originalTransactionId: string | null;
  latestTransactionId: string | null;
  expiresAt: Timestamp | null;
  latestReceiptData?: string | null;
  updatedAt: Timestamp;
}

interface AppleReceiptItem {
  product_id?: string;
  transaction_id?: string;
  original_transaction_id?: string;
  expires_date_ms?: string;
  cancellation_date_ms?: string;
}

interface AppleVerifyReceiptResponse {
  status: number;
  latest_receipt?: string;
  latest_receipt_info?: AppleReceiptItem[];
  receipt?: {
    in_app?: AppleReceiptItem[];
  };
}

interface PremiumTransactionDoc {
  uid: string;
  productId: string;
  platform: PremiumPlatform;
  originalTransactionId: string;
  latestTransactionId: string | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface PendingInvite {
  email: string;
  tokenHash: string;
  createdAt: Timestamp;
  expiresAt: Timestamp;
}

interface SharedPlanDoc {
  ownerUid: string;
  scenarioId: string;
  mode: ShareMode;
  partnerUids: string[];
  pendingInvites: PendingInvite[];
  pendingTokenHashes: string[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
  revokedAt: Timestamp | null;
}

const inviteTtlMs = 7 * 24 * 60 * 60 * 1000;
const defaultInviteBaseUrl = "https://debt-payoff-manager-e6283.web.app/invite";
const premiumProductIds = new Set(["premium_monthly", "premium_yearly"]);
const entitlementDocId = "premium";
const appleProductionVerifyUrl = "https://buy.itunes.apple.com/verifyReceipt";
const appleSandboxVerifyUrl = "https://sandbox.itunes.apple.com/verifyReceipt";

function requireUid(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }
  return uid;
}

function requiredString(data: unknown, field: string): string {
  const value = (data as Record<string, unknown> | undefined)?.[field];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return value.trim();
}

function optionalString(data: unknown, field: string): string | null {
  const value = (data as Record<string, unknown> | undefined)?.[field];
  if (value == null) return null;
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${field} must be a string.`);
  }
  return value.trim();
}

function requiredAmountCents(data: unknown): number {
  const value = (data as Record<string, unknown> | undefined)?.amountCents;
  if (!Number.isInteger(value) || Number(value) <= 0) {
    throw new HttpsError("invalid-argument", "amountCents must be positive.");
  }
  return Number(value);
}

function optionalRecord(data: unknown, field: string): Record<string, unknown> {
  const value = (data as Record<string, unknown> | undefined)?.[field];
  if (value == null) return {};
  if (typeof value !== "object" || Array.isArray(value)) {
    throw new HttpsError("invalid-argument", `${field} must be an object.`);
  }
  return value as Record<string, unknown>;
}

function parsePremiumPlatform(value: string): PremiumPlatform {
  if (value !== "ios" && value !== "android") {
    throw new HttpsError("invalid-argument", "Unsupported purchase platform.");
  }
  return value;
}

function parseVerifyPurchasePayload(data: unknown): VerifyPurchasePayload {
  const platform = parsePremiumPlatform(requiredString(data, "platform"));
  const productId = requiredString(data, "productId");
  if (!premiumProductIds.has(productId)) {
    throw new HttpsError("invalid-argument", "Unsupported Premium product.");
  }
  const verificationData = optionalRecord(data, "verificationData");
  return {
    platform,
    productId,
    transactionId: optionalString(data, "transactionId") ?? undefined,
    verificationData: {
      localVerificationData:
        optionalString(verificationData, "localVerificationData") ?? undefined,
      serverVerificationData:
        optionalString(verificationData, "serverVerificationData") ?? undefined,
      source: optionalString(verificationData, "source") ?? undefined,
    },
  };
}

function parseMode(data: unknown): ShareMode {
  const mode = requiredString(data, "mode");
  if (mode !== "readonly" && mode !== "collaborative") {
    throw new HttpsError("invalid-argument", "Unsupported sharing mode.");
  }
  return mode;
}

function normalizeEmail(email: string): string {
  const normalized = email.trim().toLowerCase();
  if (!normalized.includes("@") || normalized.length > 254) {
    throw new HttpsError("invalid-argument", "Enter a valid partner email.");
  }
  return normalized;
}

function shareId(ownerUid: string, scenarioId: string): string {
  return `${ownerUid}_${scenarioId}`;
}

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

function generateInviteToken(): string {
  return randomBytes(32).toString("base64url");
}

function inviteUrl(token: string): string {
  const baseUrl = process.env.INVITE_BASE_URL ?? defaultInviteBaseUrl;
  const separator = baseUrl.includes("?") ? "&" : "?";
  return `${baseUrl}${separator}token=${encodeURIComponent(token)}`;
}

function sharedPlanRef(id: string) {
  return db.collection("sharedPlans").doc(id);
}

function nowTimestamp(): Timestamp {
  return Timestamp.now();
}

function premiumEntitlementRef(uid: string) {
  return db.collection("users").doc(uid).collection("entitlements").doc(entitlementDocId);
}

function premiumTransactionRef(originalTransactionId: string) {
  return db.collection("premiumTransactions").doc(originalTransactionId);
}

function entitlementResponse(doc: EntitlementDoc | null) {
  const expiresAt = doc?.expiresAt ?? null;
  const isExpired = expiresAt != null && expiresAt.toMillis() <= Date.now();
  const active = doc?.active === true && !isExpired;
  return {
    active,
    productId: active ? doc?.productId ?? null : null,
    expiresAt: expiresAt?.toDate().toISOString() ?? null,
  };
}

async function writeEntitlement(uid: string, entitlement: EntitlementDoc) {
  await premiumEntitlementRef(uid).set(entitlement, { merge: true });
}

async function readEntitlement(uid: string): Promise<EntitlementDoc | null> {
  const snapshot = await premiumEntitlementRef(uid).get();
  return snapshot.exists ? (snapshot.data() as EntitlementDoc) : null;
}

async function verifyAppleReceipt(
  receiptData: string,
  expectedProductId: string,
): Promise<{
  productId: string;
  originalTransactionId: string | null;
  latestTransactionId: string | null;
  expiresAt: Timestamp | null;
  latestReceiptData: string | null;
}> {
  const sharedSecret = process.env.APP_STORE_SHARED_SECRET;
  if (!sharedSecret && process.env.FUNCTIONS_EMULATOR === "true") {
    if (receiptData !== "test-valid-receipt") {
      throw new HttpsError("permission-denied", "Invalid sandbox receipt.");
    }
    return {
      productId: expectedProductId,
      originalTransactionId: "test-original-transaction",
      latestTransactionId: "test-latest-transaction",
      expiresAt: Timestamp.fromMillis(Date.now() + 30 * 24 * 60 * 60 * 1000),
      latestReceiptData: receiptData,
    };
  }
  if (!sharedSecret) {
    throw new HttpsError(
      "failed-precondition",
      "App Store shared secret is not configured.",
    );
  }

  const response = await postAppleReceipt(appleProductionVerifyUrl, receiptData, sharedSecret);
  const verified = response.status === 21007
    ? await postAppleReceipt(appleSandboxVerifyUrl, receiptData, sharedSecret)
    : response;
  if (verified.status !== 0) {
    throw new HttpsError("permission-denied", "App Store receipt is invalid.");
  }

  const candidates = [
    ...(verified.latest_receipt_info ?? []),
    ...(verified.receipt?.in_app ?? []),
  ].filter((item) => item.product_id === expectedProductId);

  if (candidates.length === 0) {
    throw new HttpsError("permission-denied", "Receipt does not contain this product.");
  }

  candidates.sort((a, b) => Number(b.expires_date_ms ?? 0) - Number(a.expires_date_ms ?? 0));
  const latest = candidates[0];
  if (latest.cancellation_date_ms != null) {
    throw new HttpsError("permission-denied", "Subscription purchase was cancelled.");
  }
  const expiresMs = Number(latest.expires_date_ms ?? 0);
  if (!Number.isFinite(expiresMs) || expiresMs <= Date.now()) {
    throw new HttpsError("permission-denied", "Subscription is expired.");
  }

  return {
    productId: expectedProductId,
    originalTransactionId: latest.original_transaction_id ?? null,
    latestTransactionId: latest.transaction_id ?? null,
    expiresAt: Timestamp.fromMillis(expiresMs),
    latestReceiptData: verified.latest_receipt ?? receiptData,
  };
}

async function writeOwnedEntitlement(
  uid: string,
  entitlement: EntitlementDoc,
) {
  const originalTransactionId = entitlement.originalTransactionId;
  if (!originalTransactionId) {
    throw new HttpsError(
      "permission-denied",
      "Receipt does not include an original transaction.",
    );
  }

  const transactionRef = premiumTransactionRef(originalTransactionId);
  const entitlementRef = premiumEntitlementRef(uid);
  await db.runTransaction(async (transaction) => {
    const existing = await transaction.get(transactionRef);
    if (existing.exists) {
      const data = existing.data() as PremiumTransactionDoc;
      if (data.uid !== uid) {
        throw new HttpsError(
          "permission-denied",
          "This App Store subscription belongs to another account.",
        );
      }
      transaction.update(transactionRef, {
        productId: entitlement.productId,
        platform: entitlement.platform,
        latestTransactionId: entitlement.latestTransactionId,
        updatedAt: entitlement.updatedAt,
      });
    } else {
      transaction.set(transactionRef, {
        uid,
        productId: entitlement.productId,
        platform: entitlement.platform,
        originalTransactionId,
        latestTransactionId: entitlement.latestTransactionId,
        createdAt: entitlement.updatedAt,
        updatedAt: entitlement.updatedAt,
      });
    }

    transaction.set(entitlementRef, entitlement, { merge: true });
  });
}

async function revalidateIosEntitlement(
  uid: string,
  entitlement: EntitlementDoc,
): Promise<EntitlementDoc> {
  if (entitlement.platform !== "ios" ||
      !entitlement.productId ||
      !entitlement.latestReceiptData) {
    return entitlement;
  }

  const verified = await verifyAppleReceipt(
    entitlement.latestReceiptData,
    entitlement.productId,
  );
  const updatedAt = nowTimestamp();
  const updated: EntitlementDoc = {
    ...entitlement,
    active: true,
    productId: verified.productId,
    originalTransactionId: verified.originalTransactionId,
    latestTransactionId:
      verified.latestTransactionId ?? entitlement.latestTransactionId,
    expiresAt: verified.expiresAt,
    latestReceiptData:
      verified.latestReceiptData ?? entitlement.latestReceiptData,
    updatedAt,
  };
  await writeOwnedEntitlement(uid, updated);
  return updated;
}

async function postAppleReceipt(
  url: string,
  receiptData: string,
  sharedSecret: string,
): Promise<AppleVerifyReceiptResponse> {
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      "receipt-data": receiptData,
      "password": sharedSecret,
      "exclude-old-transactions": true,
    }),
  });
  if (!response.ok) {
    throw new HttpsError("unavailable", "App Store receipt service is unavailable.");
  }
  return (await response.json()) as AppleVerifyReceiptResponse;
}

function assertOwner(plan: SharedPlanDoc, uid: string): void {
  if (plan.ownerUid !== uid) {
    throw new HttpsError("permission-denied", "Only the owner can do this.");
  }
}

function assertParticipant(plan: SharedPlanDoc, uid: string): void {
  if (plan.ownerUid !== uid && !plan.partnerUids.includes(uid)) {
    throw new HttpsError("permission-denied", "You do not have access.");
  }
}

function assertActive(plan: SharedPlanDoc): void {
  if (plan.revokedAt != null) {
    throw new HttpsError("failed-precondition", "This share is revoked.");
  }
}

export const createSharingInvite = onCall(async (request) => {
  const ownerUid = requireUid(request.auth?.uid);
  const scenarioId = requiredString(request.data, "scenarioId");
  const partnerEmail = normalizeEmail(requiredString(request.data, "partnerEmail"));
  const mode = parseMode(request.data);
  const id = shareId(ownerUid, scenarioId);
  const token = generateInviteToken();
  const tokenHash = hashToken(token);
  const createdAt = nowTimestamp();
  const expiresAt = Timestamp.fromMillis(createdAt.toMillis() + inviteTtlMs);
  const ref = sharedPlanRef(id);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const existing = snapshot.exists
      ? (snapshot.data() as SharedPlanDoc)
      : null;
    const pendingInvites = (existing?.pendingInvites ?? [])
      .filter((invite) => invite.email !== partnerEmail);
    const pendingTokenHashes = (existing?.pendingTokenHashes ?? [])
      .filter((hash) => {
        return pendingInvites.some((invite) => invite.tokenHash === hash);
      });
    pendingInvites.push({ email: partnerEmail, tokenHash, createdAt, expiresAt });
    pendingTokenHashes.push(tokenHash);

    transaction.set(ref, {
      ownerUid,
      scenarioId,
      mode,
      partnerUids: existing?.partnerUids ?? [],
      pendingInvites,
      pendingTokenHashes,
      createdAt: existing?.createdAt ?? createdAt,
      updatedAt: createdAt,
      revokedAt: null,
    });
  });

  return {
    shareId: id,
    inviteUrl: inviteUrl(token),
    expiresAt: expiresAt.toDate().toISOString(),
  };
});

export const acceptSharingInvite = onCall(async (request) => {
  const partnerUid = requireUid(request.auth?.uid);
  const token = requiredString(request.data, "token");
  const tokenHash = hashToken(token);
  const matches = await db
    .collection("sharedPlans")
    .where("pendingTokenHashes", "array-contains", tokenHash)
    .limit(1)
    .get();

  if (matches.empty) {
    throw new HttpsError("not-found", "Invite link is invalid or expired.");
  }

  const ref = matches.docs[0].ref;
  const acceptedPlan = await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Invite link is invalid or expired.");
    }
    const plan = snapshot.data() as SharedPlanDoc;
    assertActive(plan);
    if (plan.ownerUid === partnerUid) {
      throw new HttpsError("failed-precondition", "Owners cannot accept their own invite.");
    }
    const invite = plan.pendingInvites.find((item) => item.tokenHash === tokenHash);
    if (!invite || invite.expiresAt.toMillis() < Date.now()) {
      throw new HttpsError("deadline-exceeded", "Invite link has expired.");
    }

    const partnerUids = plan.partnerUids.includes(partnerUid)
      ? plan.partnerUids
      : [...plan.partnerUids, partnerUid];
    const pendingInvites = plan.pendingInvites
      .filter((item) => item.tokenHash !== tokenHash);
    const pendingTokenHashes = plan.pendingTokenHashes
      .filter((hash) => hash !== tokenHash);
    const updatedAt = nowTimestamp();

    transaction.update(ref, {
      partnerUids,
      pendingInvites,
      pendingTokenHashes,
      updatedAt,
    });

    return {
      ...plan,
      partnerUids,
      pendingInvites,
      pendingTokenHashes,
      updatedAt,
    };
  });

  return {
    shareId: ref.id,
    ownerUid: acceptedPlan.ownerUid,
    scenarioId: acceptedPlan.scenarioId,
    mode: acceptedPlan.mode,
  };
});

export const revokeSharingAccess = onCall(async (request) => {
  const ownerUid = requireUid(request.auth?.uid);
  const id = requiredString(request.data, "shareId");
  const partnerUid = requiredString(request.data, "partnerUid");
  const ref = sharedPlanRef(id);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Shared plan not found.");
    }
    const plan = snapshot.data() as SharedPlanDoc;
    assertOwner(plan, ownerUid);
    const partnerUids = plan.partnerUids.filter((uid) => uid !== partnerUid);
    const updatedAt = nowTimestamp();
    transaction.update(ref, {
      partnerUids,
      updatedAt,
      revokedAt: partnerUids.length === 0 && plan.pendingInvites.length === 0
        ? updatedAt
        : plan.revokedAt,
    });
  });

  return { shareId: id };
});

export const leaveSharedPlan = onCall(async (request) => {
  const partnerUid = requireUid(request.auth?.uid);
  const id = requiredString(request.data, "shareId");
  const ref = sharedPlanRef(id);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Shared plan not found.");
    }
    const plan = snapshot.data() as SharedPlanDoc;
    assertParticipant(plan, partnerUid);
    if (plan.ownerUid === partnerUid) {
      throw new HttpsError("failed-precondition", "Owners must revoke sharing instead.");
    }
    const partnerUids = plan.partnerUids.filter((uid) => uid !== partnerUid);
    const updatedAt = nowTimestamp();
    transaction.update(ref, {
      partnerUids,
      updatedAt,
      revokedAt: partnerUids.length === 0 && plan.pendingInvites.length === 0
        ? updatedAt
        : plan.revokedAt,
    });
  });

  return { shareId: id };
});

export const logSharedPayment = onCall(async (request) => {
  const partnerUid = requireUid(request.auth?.uid);
  const id = requiredString(request.data, "shareId");
  const debtId = requiredString(request.data, "debtId");
  const amountCents = requiredAmountCents(request.data);
  const date = requiredString(request.data, "date");
  const note = optionalString(request.data, "note");
  const ref = sharedPlanRef(id);

  await db.runTransaction(async (transaction) => {
    const shareSnapshot = await transaction.get(ref);
    if (!shareSnapshot.exists) {
      throw new HttpsError("not-found", "Shared plan not found.");
    }
    const plan = shareSnapshot.data() as SharedPlanDoc;
    assertActive(plan);
    assertParticipant(plan, partnerUid);
    if (plan.ownerUid === partnerUid) {
      throw new HttpsError("failed-precondition", "Owners should use the app payment logger.");
    }
    if (plan.mode !== "collaborative") {
      throw new HttpsError("permission-denied", "This shared plan is read-only.");
    }

    const debtRef = db.doc(`users/${plan.ownerUid}/debts/${debtId}`);
    const debtSnapshot = await transaction.get(debtRef);
    if (!debtSnapshot.exists) {
      throw new HttpsError("not-found", "Debt not found.");
    }
    const debt = debtSnapshot.data();
    if (debt?.scenarioId !== plan.scenarioId) {
      throw new HttpsError("permission-denied", "Debt is outside the shared plan.");
    }

    const before = Number(debt.currentBalanceCents ?? 0);
    const applied = Math.min(before, amountCents);
    const after = Math.max(0, before - applied);
    const paymentRef = db.collection(`users/${plan.ownerUid}/payments`).doc();
    const timestamp = nowTimestamp();

    transaction.set(paymentRef, {
      id: paymentRef.id,
      scenarioId: plan.scenarioId,
      debtId,
      amountCents,
      principalPortionCents: applied,
      interestPortionCents: 0,
      feePortionCents: amountCents - applied,
      date,
      type: "extra",
      source: "manual",
      note,
      status: "completed",
      appliedBalanceBeforeCents: before,
      appliedBalanceAfterCents: after,
      createdAt: timestamp,
      updatedAt: timestamp,
      deletedAt: null,
      _deviceId: `shared:${partnerUid}`,
      _schemaVersion: 1,
    });
    transaction.update(debtRef, {
      currentBalanceCents: after,
      updatedAt: timestamp,
      status: after === 0 ? "paidOff" : debt.status,
      paidOffAt: after === 0 ? timestamp : debt.paidOffAt ?? null,
    });
    transaction.update(ref, { updatedAt: timestamp });
  });

  return { shareId: id };
});

export const verifyPurchase = onCall(
  { secrets: ["APP_STORE_SHARED_SECRET"] },
  async (request) => {
    const uid = requireUid(request.auth?.uid);
    const payload = parseVerifyPurchasePayload(request.data);
    if (payload.platform !== "ios") {
      throw new HttpsError(
        "failed-precondition",
        "Android billing is deferred for the iOS-first release.",
      );
    }

    const serverVerificationData =
      payload.verificationData?.serverVerificationData?.trim();
    if (!serverVerificationData) {
      throw new HttpsError("invalid-argument", "Missing App Store receipt data.");
    }

    const verified = await verifyAppleReceipt(
      serverVerificationData,
      payload.productId,
    );
    const updatedAt = nowTimestamp();
    const entitlement: EntitlementDoc = {
      active: true,
      productId: verified.productId,
      platform: payload.platform,
      originalTransactionId: verified.originalTransactionId,
      latestTransactionId: verified.latestTransactionId ?? payload.transactionId ?? null,
      expiresAt: verified.expiresAt,
      latestReceiptData: verified.latestReceiptData ?? serverVerificationData,
      updatedAt,
    };
    await writeOwnedEntitlement(uid, entitlement);
    return entitlementResponse(entitlement);
  },
);

export const refreshEntitlement = onCall(async (request) => {
  const uid = requireUid(request.auth?.uid);
  const entitlement = await readEntitlement(uid);
  if (entitlement == null) {
    return entitlementResponse(null);
  }

  let current = entitlement;
  try {
    current = await revalidateIosEntitlement(uid, entitlement);
  } catch (error) {
    if (error instanceof HttpsError && error.code !== "unavailable") {
      current = {
        ...entitlement,
        active: false,
        updatedAt: nowTimestamp(),
      };
      await writeEntitlement(uid, current);
    }
  }
  const response = entitlementResponse(current);
  if (!response.active && current.active) {
    await writeEntitlement(uid, {
      ...current,
      active: false,
      updatedAt: nowTimestamp(),
    });
  }
  return response;
});
