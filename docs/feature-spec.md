# Debt Payoff Manager — Feature Spec

> Tài liệu tính năng sản phẩm, tổng hợp từ phân tích 6 app cạnh tranh trong cluster "debt payoff" trên App Store US (04/2026).

---

## Nguyên tắc thiết kế sản phẩm

Trước khi đi vào tính năng cụ thể, mọi quyết định feature đều phải đi qua 4 nguyên tắc này:

| # | Nguyên tắc | Lý do từ research |
|---|---|---|
| 1 | **Living Plan, không phải Static Calculator** | 5/5 app debt payoff fail vì plan bị đóng băng sau setup — user cần plan phản ánh thực tế sau mỗi thay đổi |
| 2 | **Trust là tính năng** | 6/6 app fail trust theo các cách khác nhau — pricing, custody, reliability, data loss. Trust phải là nền tảng, không phải afterthought |
| 3 | **Boring but robust > Feature breadth** | Review positive xuyên 6 app đều khen simplicity. User không muốn budgeting suite, muốn 1 việc làm đúng |
| 4 | **Không giữ tiền hộ user** | Changed fail nặng nhất ở custody model. App chỉ hỗ trợ lập kế hoạch và theo dõi, không chạm vào dòng tiền thật |

---

## Danh sách tính năng

### Tier 1 — Core (MVP, phải có trước khi ship)

Đây là các tính năng giải quyết trực tiếp pain point lặp lại ở 5/5 hoặc 6/6 app đã phân tích.

---

#### 1.0 Guided First-Time Setup (Onboarding)

**Pain point giải quyết:** 5/5 app fail ở form nhập — root cause không chỉ là UX form xấu, mà user không biết cần nhập gì, nhập xong làm gì, và không thấy value ngay lập tức → drop trước khi hiểu app.

**Flow:**

1. **Welcome** — một nút duy nhất: "Thêm khoản nợ đầu tiên"
2. **Guided debt entry** — từng field có tooltip giải thích ngắn gọn
   - VD: "APR là gì? Tìm ở đâu trên statement của bạn"
   - Chỉ yêu cầu field bắt buộc (tên, số dư, lãi suất, minimum payment). Các field khác optional, có default hợp lý
3. **Thêm khoản khác?** — cho phép thêm ngay hoặc "Xem plan trước"
4. **Strategy selection bằng số thật** — không giải thích lý thuyết Snowball vs Avalanche, mà tính trên data user vừa nhập:
   - "Snowball: trả xong [Khoản A] trong 4 tháng → motivation sớm"
   - "Avalanche: tiết kiệm $420 lãi tổng cộng"
   - User chọn 1, có thể đổi bất kỳ lúc nào sau
5. **Extra amount prompt** — "Ngoài minimum, bạn có thể trả thêm bao nhiêu/tháng?" (default = $0, không ép)
6. **Landing → Monthly Action View** với debt-free date:
   - "Bạn sẽ hết nợ vào [tháng/năm]. Tháng này cần trả: $XXX"

**Nguyên tắc onboarding:**
- Toàn bộ flow phải hoàn thành được trong < 5 phút với 1 khoản nợ
- Không yêu cầu tạo account — data lưu local ngay (Nguyên tắc 2)
- User phải thấy debt-free date từ data thật của họ ngay lần mở đầu tiên — đây là "aha moment"
- Skip được mọi bước optional, không block progress

---

#### 1.1 Nhập & quản lý khoản nợ

**Pain point giải quyết:** Form nhập bị lỗi, không edit được sau khi tạo, không thêm được nợ mới giữa chừng (Debt Payoff Box, Debt Snowball, Debt Payoff Assistant, Debt Payoff Planner & Tracker)

- Nhập không giới hạn số khoản nợ ở bản miễn phí
- Thông tin mỗi khoản: tên, tổng nợ gốc, số dư hiện tại, lãi suất (APR), minimum payment, ngày đến hạn hàng tháng
- Hỗ trợ nhiều loại nợ: credit card, student loan, car loan, mortgage, personal loan, medical debt
- Edit bất kỳ field nào của khoản nợ đã nhập, bất kỳ lúc nào — plan tự recast ngay
- Thêm khoản nợ mới giữa chừng mà không phá plan hiện tại
- Xóa / archive khoản nợ đã trả xong

---

#### 1.2 Payoff Strategy Engine

**Pain point giải quyết:** App chỉ sort nợ rồi dừng, không tạo strategy thật, không rollover payment (Debt Snowball, Debt Payoff Box, Debt Payoff Assistant)

- Hỗ trợ 2 chiến lược chính:
  - **Snowball** (trả nợ nhỏ nhất trước → rollover sang nợ tiếp)
  - **Avalanche** (trả nợ lãi suất cao nhất trước → tối ưu tổng lãi)
- Nhập **extra monthly amount** dành cho trả nợ (trên minimum payments)
- Tự động phân bổ extra amount vào khoản nợ ưu tiên theo strategy đã chọn
- **Auto rollover**: khi trả xong 1 khoản, toàn bộ payment của khoản đó tự động chuyển sang khoản tiếp theo
- So sánh nhanh Snowball vs Avalanche: tổng lãi phải trả, debt-free date, diff trực quan

---

#### 1.3 Living Payoff Timeline

**Pain point giải quyết:** Plan bị đóng băng theo ngày setup, thay đổi gì cũng không phản ánh (Debt Payoff Assistant — "static model", Debt Payoff Planner & Tracker — "payoff timeline thay đổi khó hiểu")

- Hiển thị **debt-free date** rõ ràng, cập nhật real-time khi thay đổi bất kỳ input nào
- Timeline view theo tháng: hiển thị số dư projected từng khoản, payment breakdown (principal vs interest), và milestone khi trả xong từng khoản
- Khi user thay đổi extra amount, thêm/xóa nợ, hoặc log payment → timeline recast tức thì kèm **giải thích rõ vì sao debt-free date thay đổi**
- Tổng lãi đã trả vs tổng lãi tiết kiệm được nhờ strategy

---

#### 1.4 Payment Logging (Biến calculator thành tracker)

**Pain point giải quyết:** Không log được khoản đã trả, không track progress thực tế (Debt Payoff Box — pain #1, Debt Payoff Planner & Tracker — "payment tracker không populate")

- Log payment thật cho từng khoản nợ: ngày, số tiền, ghi chú
- Phân biệt rõ:
  - **Minimum payment** (theo lịch)
  - **Extra payment** (one-time hoặc recurring)
  - **Lump-sum / windfall** (thưởng, tax refund, bán đồ...)
- Sau khi log → số dư tự cập nhật → timeline tự recast
- Lịch sử payment đầy đủ, có thể xem lại theo khoản nợ hoặc theo tháng
- Đánh dấu payment đã thực hiện vs payment theo kế hoạch (scheduled vs actual)

---

#### 1.5 Monthly Action View

**Pain point giải quyết:** User không biết tháng này phải trả gì, bao nhiêu, cho ai (gap chung xuyên category — app cho plan nhưng không cho action cụ thể tháng này)

- Màn hình chính hiển thị rõ: **"Tháng này bạn cần trả:"**
  - Danh sách từng khoản: tên nợ, số tiền cần trả (minimum + extra), ngày đến hạn
  - Tổng tiền cần trả tháng này
- Check off từng payment khi đã thực hiện → tự log vào payment history
- Hiển thị rõ nếu có payment overdue hoặc sắp đến hạn

---

#### 1.6 Trust Layer — Data & Pricing

**Pain point giải quyết:** Trust failure ở 6/6 app — pricing bait, data loss, trả tiền bị khóa, không backup

**Progressive Trust Model — user kiểm soát từng bước leo thang:**

| Level | Trigger | Cần account? | Data ở đâu |
|---|---|---|---|
| **Level 0 — Local** | Mở app lần đầu | ❌ Không | Device only (SQLite) |
| **Level 1 — Backed up** | User chọn "Backup data" | ✅ Firebase Auth (anonymous hoặc email) | Device + Firestore sync |
| **Level 2 — Shared** | User chọn "Share with partner" | ✅ Firebase Auth (email required) | Device + Firestore + sharing rules |

**Quy tắc chuyển level:**
- Level 0 → 1: non-destructive, local data push lên cloud, không mất gì
- Level 1 → 2: chỉ thêm sharing rules, data model không đổi
- User có thể **revoke sharing** (2 → 1) hoặc **delete cloud data** (1 → 0) bất kỳ lúc nào
- App **phải hoạt động offline đầy đủ** ở mọi level — cloud chỉ là sync layer

**Core trust commitments:**
- **Local-first data**: dữ liệu lưu trên device, không yêu cầu account để bắt đầu (Level 0)
- **Export đầy đủ**: xuất toàn bộ data ra CSV/PDF bất kỳ lúc nào, ở mọi level
- **Pricing minh bạch**:
  - Free: nhập không giới hạn nợ, full payoff plan, payment logging, monthly view (Level 0 đầy đủ)
  - Premium: cloud backup (Level 1), partner sharing (Level 2), scenario comparison, PDF report
- **Không trial mập mờ**, không auto-charge, không lock cancellation
- **Không yêu cầu bank linking** — app không chạm vào tài khoản ngân hàng
- **Cloud data transparency**: user luôn biết data nào đang trên cloud, và có nút xóa 1-tap

---

### Tier 2 — Power Features (Post-MVP, tăng retention & upsell value)

Các tính năng giải quyết edge case thực tế và tạo giá trị premium rõ ràng.

---

#### 2.1 What-If Scenario Comparison

**Pain point giải quyết:** Không thử được nhiều scenario, payoff logic không giúp ra quyết định (Debt Snowball, Debt Payoff Planner & Tracker)

- Tạo scenario mới từ plan hiện tại: "nếu tôi trả thêm X/tháng thì sao?", "nếu tôi có windfall Y thì sao?"
- So sánh side-by-side: debt-free date, tổng lãi, monthly commitment
- Lưu nhiều scenario để quay lại sau

---

#### 2.2 Edge-Case Debt Handling

**Pain point giải quyết:** App không xử lý được tình huống đời thật (Debt Payoff Box — forbearance, due date lỗi; Debt Payoff Assistant — static plan)

- **Debt pause / forbearance**: đánh dấu khoản nợ tạm dừng (payment = $0 trong giai đoạn forbearance), plan tự adjust
- **Interest rate change**: khi refinance hoặc promo rate hết hạn, cho phép cập nhật lãi suất → timeline recast
  - Deferred sau E1; runtime support sẽ đi cùng `InterestRateHistory`
- **Charge mới trên credit card**: cho phép cập nhật balance tăng (không chỉ giảm) → phản ánh đời thật
- **Custom payment cadence**: bi-weekly, weekly, hoặc theo payday thay vì chỉ monthly

---

#### 2.3 Progress & Motivation

**Pain point giải quyết:** User cần duy trì động lực trong hành trình trả nợ nhiều tháng/năm (review positive xuyên 6 app confirm nhu cầu này)

- Tổng nợ đã trả được (tính từ ngày bắt đầu)
- % hoàn thành tổng hành trình
- Milestone celebrations: khi trả xong 1 khoản, khi qua 25/50/75%, khi tiết kiệm được X tiền lãi
- Streak tracking: số tháng liên tiếp trả đúng hạn
- Monthly summary: tháng này trả được bao nhiêu, tiết kiệm bao nhiêu lãi, debt-free date tiến/lùi bao xa

---

#### 2.4 Partner / Household Sharing

**Pain point giải quyết:** Nhiều review nhắc cần dùng với vợ/chồng, accountability partner (Goodbudget — sync spouse; Debt Payoff Planner & Tracker — angle cặp đôi)

**Prerequisite:** User phải ở Trust Level 2 (xem 1.6) — đã có Firebase Auth email + cloud sync

**Cơ chế (Firebase-based):**
- Owner invite partner qua email → partner nhận invite trong app (cần cài app + Firebase Auth)
- Firestore security rules kiểm soát quyền: owner = read/write, partner = read-only hoặc collaborative
- Data sync real-time qua Firestore listener — cả 2 thấy cùng plan, cùng progress

**Tính năng:**
- Share plan read-only với partner qua invite email
- Partner có thể xem progress, monthly view, nhưng không edit (default)
- Optional: cả 2 cùng log payment (collaborative mode — owner bật/tắt)
- Owner có thể **revoke access** bất kỳ lúc nào → partner mất quyền xem ngay lập tức
- Khi owner downgrade về Level 1 hoặc 0 → sharing tự tắt, partner được thông báo

---

#### 2.5 Reminders & Notifications

- Nhắc trước ngày đến hạn payment (configurable: 1 ngày, 3 ngày, 1 tuần)
- Nhắc khi chưa log payment tháng này
- Nhắc milestone đạt được
- Tất cả notifications đều opt-in, không spam

---

#### 2.6 Reports & Export

**Pain point giải quyết:** Thiếu report đủ rõ theo tháng, không export được (Debt Payoff Assistant, Goodbudget)

- PDF report tổng hợp: tổng nợ, tiến trình, projected debt-free date, payment history
- CSV export đầy đủ cho từng khoản hoặc toàn bộ
- Payoff amortization table exportable
- Dùng cho accountability với financial coach hoặc partner

---

### Tier 3 — Future (Chỉ xem xét khi Tier 1-2 đã vững)

| Tính năng | Lý do chờ |
|---|---|
| Sinking fund / savings goal tracking | Phình scope sang budgeting — chỉ xây khi user demand rõ |
| Bank account sync (read-only) | Mâu thuẫn Nguyên tắc 4 (không chạm tài khoản ngân hàng). Chỉ xem xét nếu user research chứng minh manual entry là churn driver #1, VÀ có giải pháp không yêu cầu bank credential custody |
| AI-powered payoff recommendations | Nice-to-have, không phải core JTBD |
| Web app / iPad optimized | Review có nhắc iPad UX — nhưng mobile-first phải vững trước |
| Multi-currency support | Niche demand, không phải US market priority |

---

## Feature-to-Pain-Point Mapping

Bảng truy vết ngược: mỗi tính năng giải quyết pain point nào, từ app nào.

| Tính năng | Pain point | App có pain này |
|---|---|---|
| Guided onboarding + aha moment | Form fail, user drop trước khi thấy value | Box, Snowball, Assistant, Planner&Tracker |
| Nhập nợ không giới hạn, edit bất kỳ lúc nào | Form lỗi, không edit, free chỉ 2 debts | Box, Snowball, Assistant, Planner&Tracker |
| Snowball/Avalanche + auto rollover | Chỉ sort rồi dừng, không rollover | Snowball, Box, Assistant |
| Living timeline + recast giải thích | Plan đóng băng, timeline thay đổi khó hiểu | Assistant, Planner&Tracker, Box |
| Payment logging (actual vs planned) | Không log được, tracker không populate | Box, Planner&Tracker, Snowball |
| Monthly action view | Không biết tháng này trả gì | Gap chung category |
| Local-first + export + pricing rõ | Trust: data loss, paywall bait, trả tiền bị khóa | 6/6 app |
| What-if scenarios | Không thử được scenario | Snowball, Planner&Tracker |
| Forbearance / rate change / charge mới | Edge case đời thật không xử lý được | Box, Assistant |
| Progress / milestones | Cần motivation dài hạn | Review positive 6/6 app |
| Partner sharing | Dùng với vợ/chồng | Goodbudget, Planner&Tracker |

---

## Tổng kết scope

| Tier | Số tính năng | Mục tiêu |
|---|---|---|
| **Tier 1 — MVP** | 7 nhóm (1.0–1.6) | Ship được, giải quyết core pain, đủ trust để user giao hành trình trả nợ |
| **Tier 2 — Power** | 6 nhóm | Tăng retention, tạo premium value rõ ràng, xử lý edge case đời thật |
| **Tier 3 — Future** | 5 items | Chỉ khi Tier 1-2 vững, có user feedback real |

> **Triết lý scope: làm ít nhưng làm đúng. Mỗi tính năng phải trả lời được câu hỏi "pain point nào từ research đã chứng minh user thật sự cần cái này?" — nếu không trả lời được thì chưa xây.**
