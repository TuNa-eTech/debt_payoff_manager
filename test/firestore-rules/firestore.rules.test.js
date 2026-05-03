const assert = require('assert');
const fs = require('fs');
const path = require('path');
const { after, before, beforeEach, describe, it } = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  deleteDoc,
  doc,
  getDoc,
  setDoc,
  Timestamp,
} = require('firebase/firestore');

const projectId = 'debt-payoff-manager-rules-test';
const rulesPath = path.resolve(__dirname, '../../firestore.rules');
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST?.split(':')[0] ?? '127.0.0.1';
const firestorePort = Number(
  process.env.FIRESTORE_EMULATOR_HOST?.split(':')[1] ?? 8080,
);

let testEnv;

function now() {
  return Timestamp.fromDate(new Date('2026-04-25T00:00:00Z'));
}

function validDebt(overrides = {}) {
  return {
    id: 'debt-1',
    scenarioId: 'main',
    name: 'Chase Sapphire',
    type: 'creditCard',
    originalPrincipalCents: 500000,
    currentBalanceCents: 423045,
    apr: '0.1899',
    interestMethod: 'compoundDaily',
    minimumPaymentCents: 2500,
    minimumPaymentType: 'interestPlusPercent',
    minimumPaymentPercent: '0.01',
    minimumPaymentFloorCents: 2500,
    paymentCadence: 'monthly',
    dueDayOfMonth: 15,
    firstDueDate: '2026-05-15',
    status: 'active',
    pausedUntil: null,
    priority: null,
    excludeFromStrategy: false,
    createdAt: now(),
    updatedAt: now(),
    paidOffAt: null,
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validPayment(overrides = {}) {
  return {
    id: 'payment-1',
    scenarioId: 'main',
    debtId: 'debt-1',
    amountCents: 12000,
    principalPortionCents: 10000,
    interestPortionCents: 2000,
    feePortionCents: 0,
    date: '2026-04-25',
    type: 'extra',
    source: 'manual',
    note: null,
    status: 'completed',
    appliedBalanceBeforeCents: 423045,
    appliedBalanceAfterCents: 413045,
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validPlan(overrides = {}) {
  return {
    id: 'plan-1',
    scenarioId: 'main',
    strategy: 'avalanche',
    extraMonthlyAmountCents: 35000,
    extraPaymentCadence: 'monthly',
    customOrderJson: null,
    lastRecastAt: now(),
    projectedDebtFreeDate: '2027-12-31',
    totalInterestProjectedCents: 85000,
    totalInterestSavedCents: 15000,
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validSettings(overrides = {}) {
  return {
    id: 'singleton',
    scenarioId: 'main',
    trustLevel: 1,
    firebaseUid: 'alice',
    currencyCode: 'USD',
    localeCode: 'en-US',
    dayCountConvention: 'actual365',
    notifPaymentReminder: true,
    notifPaymentReminderDaysBefore: 7,
    notifMilestone: true,
    notifMonthlyLog: true,
    onboardingStep: 5,
    onboardingCompleted: true,
    onboardingCompletedAt: now(),
    isPremium: false,
    premiumExpiresAt: null,
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validMilestone(overrides = {}) {
  return {
    id: 'milestone-1',
    scenarioId: 'main',
    type: 'firstPayment',
    debtId: null,
    achievedAt: now(),
    seen: false,
    metadata: '{"savedAmountCents":1200}',
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validInterestRateHistory(overrides = {}) {
  return {
    id: 'rate-1',
    scenarioId: 'main',
    debtId: 'debt-1',
    apr: '0.2499',
    effectiveFrom: '2026-01-01',
    effectiveTo: null,
    reason: 'promo-ended',
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validScenario(overrides = {}) {
  return {
    id: 'main',
    scenarioId: 'main',
    name: 'Main plan',
    isMain: true,
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    _deviceId: 'ios-simulator',
    _schemaVersion: 1,
    ...overrides,
  };
}

function validSharedPlan(overrides = {}) {
  return {
    ownerUid: 'alice',
    scenarioId: 'main',
    mode: 'readonly',
    partnerUids: ['bob'],
    pendingInvites: [],
    pendingTokenHashes: [],
    createdAt: now(),
    updatedAt: now(),
    revokedAt: null,
    ...overrides,
  };
}

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function unauthDb() {
  return testEnv.unauthenticatedContext().firestore();
}

describe('firestore.rules Phase 7 Level 1 sync', () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId,
      firestore: {
        rules: fs.readFileSync(rulesPath, 'utf8'),
        host: firestoreHost,
        port: firestorePort,
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it('lets an authenticated user create and read their own valid debt', async () => {
    const alice = authedDb('alice');
    const debtRef = doc(alice, 'users/alice/debts/debt-1');

    await assertSucceeds(setDoc(debtRef, validDebt()));
    await assertSucceeds(getDoc(debtRef));
  });

  it('lets an owner create and update every serializer-shaped mirror collection', async () => {
    const alice = authedDb('alice');
    const cases = [
      ['users/alice/debts/debt-1', validDebt, { currentBalanceCents: 400000 }],
      ['users/alice/payments/payment-1', validPayment, { note: 'manual log' }],
      ['users/alice/plans/plan-1', validPlan, { extraMonthlyAmountCents: 40000 }],
      ['users/alice/scenarios/main', validScenario, { name: 'Main household plan' }],
      ['users/alice/settings/singleton', validSettings, { localeCode: 'vi-VN' }],
      ['users/alice/milestones/milestone-1', validMilestone, { seen: true }],
      [
        'users/alice/interestRateHistory/rate-1',
        validInterestRateHistory,
        { effectiveTo: '2026-12-31' },
      ],
    ];

    for (const [path, factory, update] of cases) {
      const ref = doc(alice, path);
      await assertSucceeds(setDoc(ref, factory()));
      await assertSucceeds(setDoc(ref, factory(update)));
    }
  });

  it('blocks unauthenticated reads and writes', async () => {
    const anon = unauthDb();
    const debtRef = doc(anon, 'users/alice/debts/debt-1');

    await assertFails(setDoc(debtRef, validDebt()));
    await assertFails(getDoc(debtRef));
  });

  it('blocks one user from reading or writing another user path', async () => {
    const alice = authedDb('alice');
    const bob = authedDb('bob');
    const debtRef = doc(alice, 'users/alice/debts/debt-1');

    await assertSucceeds(setDoc(debtRef, validDebt()));
    await assertFails(getDoc(doc(bob, 'users/alice/debts/debt-1')));
    await assertFails(
      setDoc(doc(bob, 'users/alice/debts/debt-2'), validDebt({ id: 'debt-2' })),
    );
  });

  it('rejects invalid debt payloads', async () => {
    const alice = authedDb('alice');

    await assertFails(
      setDoc(
        doc(alice, 'users/alice/debts/debt-1'),
        validDebt({ currentBalanceCents: -1 }),
      ),
    );
  });

  it('rejects payloads missing required serializer fields', async () => {
    const alice = authedDb('alice');
    const { name, ...missingName } = validDebt();

    assert.equal(name, 'Chase Sapphire');
    await assertFails(setDoc(doc(alice, 'users/alice/debts/debt-1'), missingName));
  });

  it('requires the document id to match the mirrored domain id', async () => {
    const alice = authedDb('alice');

    await assertFails(
      setDoc(doc(alice, 'users/alice/debts/other-id'), validDebt()),
    );
  });

  it('validates payment split invariants', async () => {
    const alice = authedDb('alice');

    await assertSucceeds(
      setDoc(doc(alice, 'users/alice/payments/payment-1'), validPayment()),
    );
    await assertFails(
      setDoc(
        doc(alice, 'users/alice/payments/payment-2'),
        validPayment({
          id: 'payment-2',
          amountCents: 12001,
        }),
      ),
    );
  });

  it('allows owner settings and sync metadata but keeps them private', async () => {
    const alice = authedDb('alice');
    const bob = authedDb('bob');
    const settingsRef = doc(alice, 'users/alice/settings/singleton');
    const syncMetaRef = doc(alice, 'users/alice/syncMeta/lastKnownState');

    await assertSucceeds(setDoc(settingsRef, validSettings()));
    await assertSucceeds(
      setDoc(syncMetaRef, {
        deviceId: 'ios-simulator',
        schemaVersion: 1,
        updatedAt: now(),
      }),
    );
    await assertFails(getDoc(doc(bob, 'users/alice/settings/singleton')));
    await assertFails(getDoc(doc(bob, 'users/alice/syncMeta/lastKnownState')));
  });

  it('validates singleton settings document id and bounded fields', async () => {
    const alice = authedDb('alice');

    await assertFails(
      setDoc(
        doc(alice, 'users/alice/settings/not-singleton'),
        validSettings({ id: 'not-singleton' }),
      ),
    );
    await assertFails(
      setDoc(
        doc(alice, 'users/alice/settings/singleton'),
        validSettings({ notifPaymentReminderDaysBefore: 2 }),
      ),
    );
  });

  it('blocks client-side premium promotion in synced settings', async () => {
    const alice = authedDb('alice');
    const settingsRef = doc(alice, 'users/alice/settings/singleton');

    await assertSucceeds(setDoc(settingsRef, validSettings()));
    await assertFails(
      setDoc(
        settingsRef,
        validSettings({
          isPremium: true,
          premiumExpiresAt: now(),
        }),
      ),
    );
  });

  it('keeps entitlement documents server-owned but readable by the owner', async () => {
    const alice = authedDb('alice');
    const bob = authedDb('bob');
    const entitlementRef = doc(alice, 'users/alice/entitlements/premium');

    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'users/alice/entitlements/premium'), {
        active: true,
        productId: 'premium_monthly',
        platform: 'ios',
        originalTransactionId: 'original',
        latestTransactionId: 'latest',
        expiresAt: now(),
        updatedAt: now(),
      });
    });

    await assertSucceeds(getDoc(entitlementRef));
    await assertFails(getDoc(doc(bob, 'users/alice/entitlements/premium')));
    await assertFails(
      setDoc(entitlementRef, {
        active: true,
        productId: 'premium_yearly',
        platform: 'ios',
        updatedAt: now(),
      }),
    );
  });

  it('keeps shared plan writes server-owned', async () => {
    const alice = authedDb('alice');

    await assertFails(
      setDoc(doc(alice, 'sharedPlans/alice_main'), validSharedPlan()),
    );
  });

  it('allows a partner to read only the shared owner scenario', async () => {
    const alice = authedDb('alice');
    const bob = authedDb('bob');
    const charlie = authedDb('charlie');

    await assertSucceeds(setDoc(doc(alice, 'users/alice/debts/debt-1'), validDebt()));
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'sharedPlans/alice_main'),
        validSharedPlan(),
      );
    });

    await assertSucceeds(getDoc(doc(bob, 'sharedPlans/alice_main')));
    await assertSucceeds(getDoc(doc(bob, 'users/alice/debts/debt-1')));
    await assertFails(getDoc(doc(charlie, 'sharedPlans/alice_main')));
    await assertFails(getDoc(doc(charlie, 'users/alice/debts/debt-1')));
  });

  it('blocks partner access to non-shared scenario data', async () => {
    const alice = authedDb('alice');
    const bob = authedDb('bob');

    await assertSucceeds(
      setDoc(
        doc(alice, 'users/alice/debts/private-debt'),
        validDebt({
          id: 'private-debt',
          scenarioId: 'private-scenario',
        }),
      ),
    );
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'sharedPlans/alice_main'),
        validSharedPlan(),
      );
    });

    await assertFails(getDoc(doc(bob, 'users/alice/debts/private-debt')));
  });

  it('blocks read-only and collaborative partners from direct mirror writes', async () => {
    const bob = authedDb('bob');

    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'sharedPlans/alice_main'),
        validSharedPlan({ mode: 'collaborative' }),
      );
    });

    await assertFails(
      setDoc(doc(bob, 'users/alice/payments/payment-by-bob'), validPayment({
        id: 'payment-by-bob',
      })),
    );
    await assertFails(
      setDoc(doc(bob, 'users/alice/debts/debt-1'), validDebt()),
    );
  });

  it('blocks revoked partners immediately', async () => {
    const alice = authedDb('alice');
    const bob = authedDb('bob');

    await assertSucceeds(setDoc(doc(alice, 'users/alice/debts/debt-1'), validDebt()));
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'sharedPlans/alice_main'),
        validSharedPlan({ revokedAt: now() }),
      );
    });

    await assertFails(getDoc(doc(bob, 'sharedPlans/alice_main')));
    await assertFails(getDoc(doc(bob, 'users/alice/debts/debt-1')));
  });

  it('allows an owner to delete their cloud mirror during downgrade teardown', async () => {
    const alice = authedDb('alice');
    const debtRef = doc(alice, 'users/alice/debts/debt-1');

    await assertSucceeds(setDoc(debtRef, validDebt()));
    await assertSucceeds(deleteDoc(debtRef));
  });
});
