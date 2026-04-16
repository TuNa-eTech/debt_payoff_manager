# Sync Strategy — Firestore Integration

> Chi tiết kiến trúc đồng bộ giữa local Drift DB và Firestore cloud.
> **Nguyên tắc nền tảng:** Drift là source of truth, Firestore là sync channel (ADR-003). App offline 100% vẫn full functional.
> **Reference:** architecture-decisions.md (ADR-003, 006, 009, 010, 011, 012, 013, 019), data-schema.md, feature-spec.md §1.6, §2.4.

---

## Mục lục

1. [Architecture overview](#1-architecture-overview)
2. [Progressive Trust Model — chi tiết triển khai](#2-progressive-trust-model--chi-tiết-triển-khai)
3. [Firestore data shape](#3-firestore-data-shape)
4. [Security rules](#4-security-rules)
5. [Sync engine](#5-sync-engine)
6. [Conflict resolution](#6-conflict-resolution)
7. [Anonymous → Email upgrade](#7-anonymous--email-upgrade)
8. [Partner Sharing mechanism](#8-partner-sharing-mechanism)
9. [Offline & queue management](#9-offline--queue-management)
10. [Cost estimation & optimization](#10-cost-estimation--optimization)
11. [Failure modes & recovery](#11-failure-modes--recovery)
12. [Observability](#12-observability)
13. [Migration paths giữa levels](#13-migration-paths-giữa-levels)

---

## 1. Architecture overview

```
┌──────────────────────────────────────────────────────────┐
│                        UI Layer                          │
│         Watch domain streams from repositories           │
└──────────────────────────────────────────────────────────┘
                            ▲
                            │ Stream<Debt>, Stream<Payment>, ...
┌──────────────────────────────────────────────────────────┐
│                   Repository Layer                       │
│        Exposes reactive streams from Drift ONLY          │
│     (Firestore changes flow INTO Drift, not out)         │
└──────────────────────────────────────────────────────────┘
                            ▲
                            │ CRUD, reactive queries
┌──────────────────────────────────────────────────────────┐
│                      Drift Layer                         │
│              ★ SOURCE OF TRUTH ★                         │
│      Every write stamps updated_at = now()               │
└──────────────────────────────────────────────────────────┘
               ▲                         ▲
               │ pull delta              │ push delta (debounced)
               │                         │
┌──────────────────────────────────────────────────────────┐
│                   Sync Engine (if Level ≥ 1)             │
│  • Push queue: local changes → Firestore                 │
│  • Pull listener: Firestore changes → Drift              │
│  • Conflict resolver: LWW by server timestamp            │
└──────────────────────────────────────────────────────────┘
                            ▲
                            │ Firestore SDK
┌──────────────────────────────────────────────────────────┐
│                    Firestore (Cloud)                     │
│              Sync channel, not primary store             │
└──────────────────────────────────────────────────────────┘
```

### Key invariants

1. **UI chỉ đọc từ Drift qua repository** — không bao giờ đọc trực tiếp Firestore
2. **Sync engine là bidirectional** nhưng cả 2 direction đều ghi vào Drift:
   - Local user action → Drift → Sync engine → Firestore
   - Firestore remote change → Sync engine → Drift → UI reactive update
3. **Firestore offline persistence OFF** trong app — Drift đã làm offline layer. Firestore chỉ dùng khi online.
4. **Mọi write local phải stamp `updated_at = now()`** — không bao giờ skip. Điều này drive delta sync.
5. **Level 0 user không load sync engine** — không Firebase init cho tới khi user opt-in.

---

## 2. Progressive Trust Model — chi tiết triển khai

### Level 0 — Local only

**Trigger:** First launch, hoặc user explicitly downgrade từ Level 1.

**State:**
- `UserSettings.trustLevel = 0`
- `UserSettings.firebaseUid = NULL`
- Firebase SDK **không init**

**Capabilities:**
- Full CRUD trên Drift
- Export CSV / PDF
- Tất cả Tier 1 features hoạt động

**Cost:** $0 (không Firebase interaction).

### Level 1 — Backed up

**Trigger:** User vào Settings → "Backup data" → chọn anonymous hoặc email sign-in.

**State transition:**
```
1. Firebase.initializeApp() (lazy, lần đầu)
2. FirebaseAuth.signInAnonymously() HOẶC signInWithEmailLink()
3. UserSettings.firebaseUid = auth.currentUser.uid
4. UserSettings.trustLevel = 1
5. SyncEngine.start()
6. Initial full push: toàn bộ Drift data → users/{uid}/...
7. SyncState.lastPushedAt = now
8. Enable real-time listener cho pull
```

**Capabilities:**
- Level 0 + cloud backup
- Restore từ cloud trên device mới (reinstall, đổi máy)

**Cost:** Firestore reads/writes (xem §10).

### Level 2 — Shared

**Trigger:** User Level 1 vào Share Plan → invite partner via email.

**State transition:**
```
1. Require email-authenticated account (không anonymous)
   → Nếu đang anonymous, prompt upgrade (xem §7)
2. Create sharedPlans/{planId} document với ownerUid + partnerUids[]
3. Partner receives invite (email link + deep link vào app)
4. Partner authenticates → added to partnerUids[]
5. Security rules grant partner read (hoặc write nếu collaborative) access
```

**Capabilities:**
- Level 1 + partner sync
- Real-time updates between owner và partner

**Cost:** Reads × 2 (partner cũng read), negligible writes tăng.

### Downgrade paths

| From → To | Action | Data impact |
|---|---|---|
| 1 → 0 | User: "Stop backing up" | Cloud data **delete** (with confirmation). Local data giữ nguyên. |
| 2 → 1 | User: "Stop sharing" | Partner access revoked. `sharedPlans/` document deleted. Owner data unaffected. |
| 2 → 0 | User: cả 2 steps trên liên tiếp | Clean teardown |

**Rule:** Downgrade **không bao giờ** mất local data. Luôn có undo window 7 ngày (trash) trước hard delete cloud.

---

## 3. Firestore data shape

Mirror 1-1 với Drift schema (ADR-012), per-user subcollection.

### Collection structure

```
users/{uid}/
  debts/{debtId}              ← mirror debts table
  payments/{paymentId}        ← mirror payments table
  plans/{planId}              ← mirror plans table
  interestRateHistory/{id}    ← mirror interest_rate_history
  milestones/{id}             ← mirror milestones (Tier 2)
  settings/singleton          ← single doc

sharedPlans/{planId}          ← denormalized cho sharing
  - ownerUid: string
  - partnerUids: string[]
  - mode: "readonly" | "collaborative"
  - sharedDebtIds: string[]   ← scope what partner can see
  - createdAt: Timestamp
  - updatedAt: Timestamp

users/{uid}/syncMeta/lastKnownState
  - lastPushedAt: Timestamp
  - deviceId: string          ← identify which device last wrote
  - schemaVersion: number     ← Drift schema version
```

### Document shape

Every synced document phải có:

```typescript
{
  id: string,                  // same as Drift id (UUID v4)
  scenarioId: string,          // "main" default
  ...business fields...,
  createdAt: Timestamp,        // Firestore server timestamp on first write
  updatedAt: Timestamp,        // Firestore server timestamp on every write
  deletedAt: Timestamp | null, // soft delete
  _deviceId: string,           // which device wrote this (for debug + conflict trace)
  _schemaVersion: number,      // which Drift schema version
}
```

### Type mapping: Drift → Firestore

| Drift type | Firestore type | Note |
|---|---|---|
| TEXT (Decimal) | string | Keep as string to preserve precision |
| INTEGER (money cents) | number | Firestore number là double, nhưng cents integer < 2^53 → safe |
| TEXT (enum name) | string | ADR-007 |
| TEXT (UTC ISO) | Timestamp | Convert at sync boundary |
| TEXT (local date) | string | Keep as "YYYY-MM-DD" string |
| BOOLEAN | boolean | |
| NULL | null | Preserved for nullable fields |

### Money precision note

Firestore `number` là IEEE 754 double. Integer cents `<= 2^53` (khoảng 90 trillion dollars) → safe. **Không bao giờ lưu dollar amount as decimal number trong Firestore** — luôn integer cents.

### Example document

```json
// users/abc123/debts/uuid-of-debt
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "scenarioId": "main",
  "name": "Chase Sapphire",
  "type": "creditCard",
  "originalPrincipalCents": 500000,
  "currentBalanceCents": 423045,
  "apr": "0.1899",
  "interestMethod": "compoundDaily",
  "minimumPaymentCents": 2500,
  "minimumPaymentType": "interestPlusPercent",
  "minimumPaymentPercent": "0.01",
  "minimumPaymentFloorCents": 2500,
  "paymentCadence": "monthly",
  "dueDayOfMonth": 15,
  "firstDueDate": "2025-01-15",
  "status": "active",
  "pausedUntil": null,
  "priority": null,
  "excludeFromStrategy": false,
  "createdAt": "<Timestamp>",
  "updatedAt": "<Timestamp>",
  "paidOffAt": null,
  "deletedAt": null,
  "_deviceId": "iphone-a1b2",
  "_schemaVersion": 1
}
```

---

## 4. Security rules

### Rule goals

1. User chỉ access được data của chính mình
2. Partner access được data được share via `sharedPlans`
3. Không ai khác (including admin) có thể write user data từ client
4. Ngăn chặn enumeration attack (list users)

### Rules file (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // === Helper functions ===
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
    
    function hasRequiredFields(data, fields) {
      return data.keys().hasAll(fields);
    }
    
    function isValidDebt(data) {
      return hasRequiredFields(data, ['id', 'name', 'type', 'originalPrincipalCents', 
                                      'currentBalanceCents', 'apr', 'status', 
                                      'createdAt', 'updatedAt'])
        && data.originalPrincipalCents is number
        && data.originalPrincipalCents > 0
        && data.currentBalanceCents >= 0
        && data.name.size() > 0
        && data.name.size() <= 60;
    }
    
    function isSharedWith(planId, uid) {
      let sharedDoc = get(/databases/$(database)/documents/sharedPlans/$(planId));
      return sharedDoc.data.ownerUid == uid 
          || uid in sharedDoc.data.partnerUids;
    }
    
    function canWriteShared(planId, uid) {
      let sharedDoc = get(/databases/$(database)/documents/sharedPlans/$(planId));
      return sharedDoc.data.ownerUid == uid 
          || (uid in sharedDoc.data.partnerUids && sharedDoc.data.mode == "collaborative");
    }
    
    // === User-owned collections ===
    match /users/{uid}/{collection}/{docId} {
      // Owner has full access
      allow read, write: if isSignedIn() && isOwner(uid);
      
      // Partner has read access if doc.scenarioId is shared
      allow read: if isSignedIn() 
                  && collection in ['debts', 'payments', 'plans', 'interestRateHistory']
                  && exists(/databases/$(database)/documents/sharedPlans/$(resource.data.scenarioId))
                  && isSharedWith(resource.data.scenarioId, request.auth.uid);
      
      // Partner can write only if collaborative mode
      allow write: if isSignedIn()
                   && collection in ['debts', 'payments']
                   && exists(/databases/$(database)/documents/sharedPlans/$(resource.data.scenarioId))
                   && canWriteShared(resource.data.scenarioId, request.auth.uid);
    }
    
    // Debt-specific validation on create/update
    match /users/{uid}/debts/{debtId} {
      allow create: if isSignedIn() && isOwner(uid) && isValidDebt(request.resource.data);
      allow update: if isSignedIn() && isOwner(uid) && isValidDebt(request.resource.data);
    }
    
    // === Shared plans ===
    match /sharedPlans/{planId} {
      allow read: if isSignedIn() 
                  && (resource.data.ownerUid == request.auth.uid
                      || request.auth.uid in resource.data.partnerUids);
      
      // Only owner can create / update / delete
      allow create: if isSignedIn() 
                    && request.resource.data.ownerUid == request.auth.uid;
      allow update, delete: if isSignedIn() 
                            && resource.data.ownerUid == request.auth.uid;
    }
    
    // === Sync metadata (private per user) ===
    match /users/{uid}/syncMeta/{doc} {
      allow read, write: if isSignedIn() && isOwner(uid);
    }
  }
}
```

### Rules testing requirements

- [ ] **Unit tests** bằng Firebase Rules Unit Testing Library cho mọi rule branch
- [ ] Test: user A cannot read user B's debts
- [ ] Test: partner cannot access non-shared scenario
- [ ] Test: partner in readonly mode cannot write
- [ ] Test: unauthenticated request rejected
- [ ] Test: invalid debt data (missing field, negative balance) rejected
- [ ] **Penetration test** trong Phase 9 gate — người ngoài team thử exploit

---

## 5. Sync engine

### Components

```
SyncEngine
├── PushQueue           — pending local writes to push
├── PullListener        — real-time Firestore onSnapshot
├── ConflictResolver    — apply LWW rules
├── RetryPolicy         — exponential backoff on failures
└── SyncState           — track last pushed/pulled timestamp
```

### Push flow

```
1. Drift repository insert/update/delete
   → triggers DriftStreamQuery changes
   → which fire a "local change event" with row data
   
2. SyncEngine.onLocalChange(table, row):
   a. Add to PushQueue
   b. Debounce 2s (coalesce rapid changes)
   
3. When debounce fires:
   a. Group by table
   b. Build Firestore batch write (max 500 ops)
   c. Each doc write = set(data, merge: false) to replace
   d. Use FieldValue.serverTimestamp() for updatedAt
   
4. On success:
   a. PushQueue entries cleared
   b. SyncState.lastPushedAt = now
   c. Emit "synced" event to UI
   
5. On failure (network, auth, rules reject):
   a. Keep in queue
   b. Retry with exponential backoff: 2s, 4s, 8s, 30s, 2min, 10min, 1h
   c. Surface error to user if > 1h stuck
```

### Pull flow

```
1. On SyncEngine.start() (Level 1+):
   For each synced table:
     a. Query: users/{uid}/{table} where updatedAt > lastPulledAt
     b. Apply results to Drift (upsert by id)
     c. Update SyncState.lastPulledAt
   
2. Start real-time listener:
   users/{uid}/{table}.onSnapshot()
   
3. On remote change:
   a. Get changed docs
   b. For each doc:
      - If deletedAt != null → soft delete in Drift
      - Else → upsert with conflict resolution (see §6)
   c. Drift change triggers UI reactive stream
```

### Pseudo-code (Dart)

```dart
class SyncEngine {
  final AppDatabase _db;
  final FirebaseFirestore _fs;
  final String _uid;
  final String _deviceId;
  
  final _pushQueue = <SyncOp>[];
  Timer? _debounceTimer;
  final _listeners = <StreamSubscription>[];
  
  Future<void> start() async {
    await _initialPull();
    _startRealtimeListeners();
    _listenLocalChanges();
  }
  
  Future<void> _initialPull() async {
    final syncState = await _db.syncState.get();
    for (final table in _syncableTables) {
      final since = syncState[table]?.lastPulledAt ?? DateTime(2000);
      final snapshot = await _fs
        .collection('users/$_uid/$table')
        .where('updatedAt', isGreaterThan: Timestamp.fromDate(since))
        .get();
      
      await _applyRemoteDocs(table, snapshot.docs);
      await _db.syncState.update(table, lastPulledAt: DateTime.now());
    }
  }
  
  void _listenLocalChanges() {
    for (final table in _syncableTables) {
      final sub = _db.watchChanges(table).listen((change) {
        _pushQueue.add(SyncOp(table, change));
        _debounceTimer?.cancel();
        _debounceTimer = Timer(Duration(seconds: 2), _flushPush);
      });
      _listeners.add(sub);
    }
  }
  
  Future<void> _flushPush() async {
    if (_pushQueue.isEmpty) return;
    
    final ops = List.of(_pushQueue);
    _pushQueue.clear();
    
    try {
      final batch = _fs.batch();
      for (final op in ops) {
        final ref = _fs.doc('users/$_uid/${op.table}/${op.data.id}');
        batch.set(ref, {
          ...op.data.toFirestore(),
          'updatedAt': FieldValue.serverTimestamp(),
          '_deviceId': _deviceId,
          '_schemaVersion': _db.schemaVersion,
        }, SetOptions(merge: false));
      }
      await batch.commit();
      await _db.syncState.bulkUpdate(lastPushedAt: DateTime.now());
    } catch (e) {
      _pushQueue.insertAll(0, ops); // requeue
      _scheduleRetry();
    }
  }
}
```

---

## 6. Conflict resolution

### Strategy: Last-Write-Wins by server timestamp (ADR-009)

**Not** LWW by local clock — local clocks can be skewed. Always use Firestore server timestamp.

### Algorithm (on pull, per doc)

```
remote = incoming Firestore doc
local = Drift row with same id (or null)

if local == null:
  → insert remote into Drift
  
elif remote.deletedAt != null:
  → soft delete local (set deletedAt = remote.deletedAt)
  
elif remote.updatedAt > local.updatedAt:
  → overwrite local with remote
  
elif remote.updatedAt < local.updatedAt:
  → ignore remote (our local is newer, will push)
  
elif remote.updatedAt == local.updatedAt:
  → tie-breaker: deviceId lexicographic compare, smaller wins
  (extremely rare — only if 2 devices write at exact same server instant)
```

### Why not CRDT / per-field merge?

- Complexity cao, bug risk high
- Use case rare: user editing same debt from 2 devices offline within seconds
- MVP LWW acceptable; defer per-field merge to v2 if user complaints
- Repository can surface "Last edited on [device] X ago" for transparency

### Edge case: deletedAt race

Scenario: Device A deletes debt (soft delete). Device B edits debt (update). Both offline. Both sync.

```
A.updatedAt = t1, A.deletedAt = t1
B.updatedAt = t2, B.deletedAt = null, B.balance = updated
```

Resolution by LWW:
- If t2 > t1 → B wins, debt resurrected (user sees edit, not deletion)
- If t1 > t2 → A wins, debt stays deleted

**Verdict:** Acceptable. User sees final consistent state. If conflict visible, show subtle "conflict resolved" toast.

### Edge case: parent-child reference

Scenario: Payment references a debt. Debt deleted remotely, payment still pending push.

```
1. Pull: debt X soft-deleted (deletedAt set)
2. Push: Payment pointing to debt X
3. Firestore rules pass (payment is valid, debt exists just soft-deleted)
4. Local UI filters out soft-deleted debts → payment shows as orphan until cleanup
```

**Mitigation:** Repository layer always joins with `debts.deletedAt IS NULL` for payment queries. Orphan payment hidden, not error.

---

## 7. Anonymous → Email upgrade

### Flow

```
State: trustLevel=1, anonymous auth, uid=ANON_UID

User triggers: "Sign in with email" in Settings

1. Get current user: auth.currentUser (anonymous)
2. Create EmailLink credential
3. auth.currentUser.linkWithCredential(cred)
   → Firebase keeps same UID, adds email provider
4. On success:
   - UserSettings.firebaseUid unchanged (still ANON_UID)
   - UserSettings.authProvider = "email"
   - All /users/ANON_UID/... data preserved
5. On conflict (email already has an account):
   - Prompt: "Email này đã có account. Chọn:"
     a. "Sign in to existing" → lose current anonymous data (warn + confirm)
     b. "Use different email"
   - If (a): signOut anonymous → signIn email → re-upload local Drift (local is source of truth)
```

### Key guarantees

- Non-destructive by default
- User always sees warning before any data loss
- Local Drift is fallback: even if cloud data lost, local can re-upload

---

## 8. Partner Sharing mechanism

### Invite flow

```
Owner (Level 1+, email auth):
  1. Open "Share with Partner"
  2. Enter partner email
  3. App creates sharedPlans/{planId}:
     {
       ownerUid: owner.uid,
       partnerUids: [],
       pendingInvites: [{ email, token, expiresAt }],
       mode: "readonly" | "collaborative",
       sharedDebtIds: ["debt1", "debt2"] | "all",
       createdAt: serverTimestamp,
     }
  4. Send invite: Firebase Dynamic Link với token
     https://debtpayoff.app/invite?token=XXX
  5. Email sent via Firebase Extension "Trigger Email"

Partner receives email → taps link:
  1. Open app (install if needed)
  2. Deep link routes to InviteAcceptScreen
  3. If not signed in → prompt sign-up (email link or Google)
  4. App validates token, calls Cloud Function acceptInvite(token)
     → CF adds partner.uid to sharedPlans.partnerUids
     → CF removes from pendingInvites
  5. Partner's app starts listening on sharedPlans + owner's scoped data
```

### Partner data access

Partner **does not copy data** to their own `users/{partnerUid}/`. They read from owner's collections via security rules:

```
// Partner view builder (pseudo):
1. Find sharedPlans where partnerUid in partnerUids
2. For each shared plan, read users/{ownerUid}/debts where scenarioId == planId
3. Write to partner's local Drift with flag `_source = "shared:ownerUid"`
4. UI shows indicator "Shared by [owner name]"
```

### Permissions matrix

| Action | Owner | Partner (readonly) | Partner (collaborative) |
|---|---|---|---|
| View debts | ✅ | ✅ | ✅ |
| View payments | ✅ | ✅ | ✅ |
| Add debt | ✅ | ❌ | ❌ (only owner creates debts) |
| Edit debt | ✅ | ❌ | ❌ |
| Delete debt | ✅ | ❌ | ❌ |
| Log payment | ✅ | ❌ | ✅ |
| Edit plan/strategy | ✅ | ❌ | ❌ |
| View progress | ✅ | ✅ | ✅ |
| Revoke access | ✅ (kick partner) | ❌ (leave only) | ❌ (leave only) |

### Revocation

```
Owner revokes:
  1. Update sharedPlans.partnerUids = [] (or remove specific uid)
  2. Partner's listener sees change, local Drift removes shared entries
  3. Partner UI shows "Access revoked" card
  
Partner leaves:
  1. Partner calls Cloud Function leaveSharedPlan(planId)
  2. CF verifies caller is in partnerUids, removes self
  3. Partner's local Drift purges shared data
```

---

## 9. Offline & queue management

### Offline behavior

- App fully functional offline (Drift is source of truth)
- `SyncEngine` queues writes, retries when online
- UI shows subtle offline indicator (not alarming)

### Connectivity detection

```dart
final connectivity = Connectivity();
connectivity.onConnectivityChanged.listen((result) {
  if (result != ConnectivityResult.none) {
    syncEngine.onOnline(); // flush queue, resume listeners
  } else {
    syncEngine.onOffline(); // pause listeners, keep queueing
  }
});
```

### Queue persistence

Push queue **must survive app restart**:

- In-memory queue + `SyncState.pendingWrites` counter in Drift
- On app start: query Drift for `updated_at > last_pushed_at` → reconstruct queue
- No separate queue storage needed (Drift itself is the queue)

### Conflict on reconnect

Scenario: offline 3 days, made 20 local changes, come online.

```
1. SyncEngine.onOnline():
   a. Initial pull (catch up remote changes)
      → apply LWW resolution
   b. Flush push queue (batched)
   c. Real-time listener resume
```

Risk: if remote changed same rows, LWW may overwrite local unintentionally.
Mitigation: local `updated_at` was stamped when change made offline, so if local is newer → local wins. Server timestamp only applies at push time, but Firestore server accepts the client's `updated_at` if we set it explicitly.

**Decision:** For sync, use **client-provided** `updated_at` (local time at write), not Firestore serverTimestamp(). Server timestamp only for audit (`_syncedAt`). This preserves offline-write semantics.

---

## 10. Cost estimation & optimization

### Firestore pricing (2026 approximation)

| Operation | Free tier (per day) | Cost beyond |
|---|---|---|
| Document reads | 50,000 | $0.06 per 100K |
| Document writes | 20,000 | $0.18 per 100K |
| Document deletes | 20,000 | $0.02 per 100K |
| Network egress | 10 GB/month | $0.12 per GB |

### Per-user estimate

**Active user** = log 1-2 payments/day, edit debt occasionally.

```
Writes/day:
- 2 payments × 1 write = 2
- 1-2 debt updates = 2
- 1 plan recast (cached, rarely sync) = ~0.2
- Milestone inserts occasional = ~0.1
→ ~5 writes/day/user

Reads/day:
- Initial pull on open (5-10 docs) = 10
- Real-time listener updates (infrequent per user) = ~5
→ ~15 reads/day/user
```

### Capacity on free tier

```
20,000 writes/day ÷ 5 writes/user = 4,000 active users
50,000 reads/day ÷ 15 reads/user = 3,333 active users

→ Free tier supports ~3,000 DAU safely
```

### Cost scaling (beyond free tier)

| DAU | Writes/month | Cost/month | Reads/month | Cost/month | Total |
|---|---|---|---|---|---|
| 1,000 | 150K | $0 | 450K | $0 | **$0** |
| 5,000 | 750K | ~$1.35 | 2.25M | ~$1.35 | **~$3** |
| 10,000 | 1.5M | ~$2.70 | 4.5M | ~$2.70 | **~$6** |
| 50,000 | 7.5M | ~$13.50 | 22.5M | ~$13.50 | **~$30** |

### Optimizations

1. **Debounce local writes 2s** (ADR-019) — coalesce rapid edits
2. **Batch writes** (up to 500/batch) — 1 Firestore call instead of 500
3. **Exclude TimelineCache from sync** (ADR-011) — saves ~30% writes
4. **Real-time listeners scoped tight** — only active scenario, not all history
5. **Pagination on initial pull** — limit 100 docs per query, paginate if more
6. **Cache static data** — settings fetched once per session
7. **Listener lifecycle** — pause listener when app backgrounded > 5 min

### Partner sharing cost

Partner read = additional read on owner's data. Doubles read cost for shared data only.

```
Shared couple: 2 reads/doc vs 1
Still within free tier for most use cases.
```

---

## 11. Failure modes & recovery

| Failure | Detection | Recovery |
|---|---|---|
| Network offline | ConnectivityService | Queue writes, show indicator, auto-resume |
| Firebase auth expired | FirebaseAuthException | Silent refresh token; if fails, prompt re-auth (keep Level, not downgrade) |
| Firestore rules reject | PermissionDeniedException | Log error, surface to user "Sync failed: permission"; retry after re-auth |
| Quota exceeded | ResourceExhaustedException | Exponential backoff up to 1hr; surface if prolonged |
| Server timestamp skew | updatedAt in future | Clamp to now() + 1min max; log anomaly |
| Firestore data corruption | Parse error | Skip bad doc, log with docId; user can re-upload from local |
| Drift data corruption | Constraint violation | Reject write, log; prompt user to restore from last cloud snapshot |
| Device clock wrong | Detect via server time diff > 5min | Warn user to fix clock (sync would be unreliable) |
| Two devices modifying same doc | LWW auto-resolves | Show "Conflict resolved" toast if delta > 1sec |
| Email link expired | FirebaseAuth error | Resend invite with new link |

### Disaster recovery

**Scenario A: User accidentally deletes everything on device**
- Reinstall app
- Sign in with existing account
- Initial pull restores from Firestore
- Level 0 users with only local export can restore via CSV import (v2 feature)

**Scenario B: Firestore data lost (hypothetical, Firebase issue)**
- Local Drift still has data
- On next sync, full push re-uploads
- Recommend users keep occasional CSV export (Settings → Export)

**Scenario C: Firebase project compromised**
- Revoke all tokens
- Users prompted to re-auth
- Local Drift unaffected

---

## 12. Observability

### What to log (structured, no PII — ADR-020)

```json
{
  "event": "sync.push.success",
  "docCount": 5,
  "table": "payments",
  "durationMs": 142,
  "trustLevel": 1,
  "scenarioId": "main"  // allowed — not PII
}

{
  "event": "sync.conflict.resolved",
  "docId": "uuid",    // allowed — opaque
  "winner": "remote",
  "deltaMs": 850,
  "table": "debts"
}

{
  "event": "sync.error",
  "errorCode": "permission-denied",
  "table": "debts",
  "retryCount": 3
}
```

### Metrics to track (aggregate only)

- Sync success rate (push, pull)
- P50/P95/P99 sync latency
- Conflict resolution rate (per 1000 syncs)
- Queue backlog size distribution
- Offline duration distribution
- Error rate by error code
- Free tier quota consumption

### Dashboards

- Firebase Console → Firestore usage
- Crashlytics → sync-related crashes
- Custom analytics (Firebase Analytics) → sync events

### Alerting

- Sync error rate > 1% → PagerDuty
- Free tier quota > 80% → email ops
- Security rules deny rate > 0.1% → review (may indicate client bug or abuse)

---

## 13. Migration paths giữa levels

### L0 → L1 (Backup)

```
Pre-conditions:
  - User taps "Enable Backup" in Settings
  - Firebase SDK not yet initialized

Steps:
  1. Show onboarding screen: "What backup means, data shape, cost"
  2. User chooses: Anonymous or Email
  3. Firebase.initializeApp() (first time)
  4. Auth (anonymous or email link)
  5. Write UserSettings.firebaseUid, trustLevel = 1
  6. Initial full push (all Drift data → Firestore)
     - Show progress UI: "Backing up 124 debts and 3,421 payments..."
  7. SyncEngine.start() → real-time listeners active
  8. Confirmation: "Backup enabled. Last synced just now."

Duration:
  - Small user (<100 records): < 5s
  - Heavy user (thousands): < 30s
  - Show progress bar
```

### L1 → L0 (Disable backup)

```
Pre-conditions:
  - User taps "Disable Backup" in Settings

Steps:
  1. Warning dialog: "Your cloud data will be deleted. Local data remains. Continue?"
  2. User confirms (type "DELETE" to confirm — high-friction intentional)
  3. SyncEngine.stop()
  4. Option: "Delete cloud data immediately" (default) or "Keep for 7 days then auto-delete"
  5. Call Cloud Function deleteUserData(uid)
     - CF iterates users/{uid}/** and batch deletes
     - CF deletes any sharedPlans where ownerUid = uid
  6. FirebaseAuth.signOut() (or delete anonymous user)
  7. UserSettings.firebaseUid = null, trustLevel = 0
  8. Local Drift unchanged (!)
  9. Confirmation: "Backup disabled. Your local data is safe."
```

### L1 → L2 (Enable sharing)

```
Pre-conditions:
  - User at L1
  - Must be email-authenticated (not anonymous)

Steps:
  1. If anonymous: prompt upgrade to email auth (§7)
  2. Open "Share Plan" screen
  3. Enter partner email + choose mode (readonly / collaborative)
  4. Select scope (all debts or specific)
  5. Create sharedPlans/{planId} doc
  6. Send invite email (Cloud Function)
  7. UserSettings.trustLevel = 2

Pending state:
  - Plan shows "Invite sent, waiting for partner"
  - Owner can cancel invite anytime
  - On partner accept: owner gets notification, UI updates
```

### L2 → L1 (Stop sharing)

```
Option A — Revoke partner (by owner):
  1. Settings → Shared → Remove partner
  2. Update sharedPlans.partnerUids = []
  3. Partner's local Drift purges shared data on next listener event
  4. If no partners left: delete sharedPlans doc, trustLevel = 1

Option B — Leave (by partner):
  1. Partner taps "Leave shared plan"
  2. Cloud Function removes partner.uid from partnerUids
  3. Partner's Drift purges shared data
  4. Partner's trustLevel unchanged (was L1 or L2 for their own data)
```

---

## Appendix A: Sync lifecycle diagram

```
┌─────────────┐
│  App Start  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐     trustLevel=0
│ Load Settings   ├───────────► [No sync, L0]
└──────┬──────────┘
       │ trustLevel≥1
       ▼
┌─────────────────┐
│ Init Firebase   │
│ Check auth      │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐    failure    ┌────────────────┐
│ Initial Pull    ├──────────────► │ Retry backoff  │
└──────┬──────────┘                └────────────────┘
       │ success
       ▼
┌─────────────────┐
│ Start Listeners │
│ Start Push Queue│
└──────┬──────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Steady state: bidirectional sync   │
│  • Local write → debounce → push    │
│  • Remote change → pull → Drift     │
└──────┬──────────────────────────────┘
       │ app background
       ▼
┌─────────────────┐
│ Pause listeners │
│ Keep push queue │
└──────┬──────────┘
       │ app foreground
       ▼
       → resume (go back to steady state)
```

---

## Appendix B: Sync checklist (implementation phase)

**E6 Phase deliverables (ref project-phases.md):**

- [ ] `lib/sync/sync_engine.dart`
- [ ] `lib/sync/push_queue.dart`
- [ ] `lib/sync/pull_listener.dart`
- [ ] `lib/sync/conflict_resolver.dart`
- [ ] `lib/sync/firestore_models.dart` (type-safe Firestore ↔ domain conversion)
- [ ] `firestore.rules` with unit tests
- [ ] Cloud Functions: `acceptInvite`, `leaveSharedPlan`, `deleteUserData`
- [ ] `lib/ui/screens/settings/sync_screen.dart`
- [ ] Emulator integration test suite
- [ ] Multi-device test plan executed (2 iOS + 2 Android + cross)

---

> **Lời khuyên cho implementation:**
> - Viết Firestore emulator test **trước** khi write sync engine code — TDD cho sync là cần thiết
> - Test offline scenarios như first-class citizens, không afterthought
> - Never trust network — mọi sync operation phải idempotent
> - Log mọi sync event (sanitized) để debug production issues
