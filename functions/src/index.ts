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
