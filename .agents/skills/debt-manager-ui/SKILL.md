---
name: debt-manager-ui
description: Use when writing Flutter UI for the Debt Payoff Manager app. Enforces the project's "Material Structure, Notion Soul" design system — correct tokens, widgets, typography, color roles, and layout patterns. Triggers on any task involving screens, widgets, pages, layouts, or UI components in this project.
license: MIT
metadata:
  author: internal
  version: "1.0.0"
  domain: frontend
  triggers: screen, widget, UI, page, layout, design, scaffold, component, AppBar, BottomSheet, Card, Button, TextField, Chip
  role: specialist
  scope: implementation
  output-format: code
  related-skills: flutter-expert, flutter-architecture, flutter-animations
---

# Debt Manager UI — Design System Enforcer

You are the **UI implementation specialist** for the **Debt Payoff Manager** Flutter app. Your responsibility is to translate designs and product requirements into pixel-perfect, lint-clean Flutter code that **strictly follows the project's design system**.

---

## The Design System: Material Structure · Notion Soul

All UI code you write must reflect this duality:
- **MD3 structure**: Use the correct Material component (NavigationBar, FAB, BottomSheet, Card, FilledButton, etc.)
- **Notion soul**: Warm neutrals, near-black text, whisper borders, ultra-soft shadows, Roboto compressed

---

## Core Import Rules

**ALWAYS** use the project's own design system tokens — never hardcode raw colors, font sizes, or spacing:

```dart
// ✅ CORRECT — use design system
import 'package:debt_payoff_manager/core/theme/theme.dart';
import 'package:debt_payoff_manager/core/widgets/widgets.dart';

// ❌ WRONG — never do these
Color(0xFF1B6B4A)          // hardcode color
fontSize: 16               // hardcode font size
EdgeInsets.all(16)         // hardcode spacing without AppDimensions
Colors.green               // raw Material color
TextStyle(fontFamily: 'Roboto') // manual text style
```

---

## Token Reference

### Colors — `AppColors`
| Token | Value | When to Use |
|---|---|---|
| `AppColors.mdPrimary` | `#1B6B4A` | Primary actions, active states, icons |
| `AppColors.mdOnPrimary` | `#FFFFFF` | Text/icons on primary |
| `AppColors.mdPrimaryContainer` | `#A8F0CC` | Tonal surfaces, selected chips |
| `AppColors.mdSurface` | `#FFFFFF` | Cards, modal backgrounds |
| `AppColors.mdSurfaceContainerLow` | `#F6F5F4` | Scaffold background, alternating sections |
| `AppColors.mdOnSurface` | `#1A1A1A` | Primary text (Notion Black) |
| `AppColors.mdOnSurfaceVariant` | `#404943` | Secondary text, icons |
| `AppColors.mdOutlineVariant` | `#EAEAE8` | Whisper borders, dividers |
| `AppColors.mdError` | `#BA1A1A` | Error icons, focused error borders |
| `AppColors.mdErrorContainer` | `#FFD9D9` | Overdue debt card background |
| `AppColors.debtRed` | `#DD0000` | Overdue text, debt-specific destructive |
| `AppColors.whisperBorder` | `rgba(0,0,0,0.10)` | Card borders (use `Border.all(color: AppColors.whisperBorder)`) |

### Spacing — `AppDimensions`
| Token | Value | When to Use |
|---|---|---|
| `AppDimensions.xs` | `4px` | Tight spacing, badge padding |
| `AppDimensions.sm` | `8px` | Icon-to-label gap, small gaps |
| `AppDimensions.md` | `16px` | Standard padding, horizontal page padding |
| `AppDimensions.lg` | `24px` | Section gap, button horizontal padding |
| `AppDimensions.xl` | `32px` | Large section spacing |
| `AppDimensions.pagePaddingH` | `16px` | Horizontal edge of every screen |
| `AppDimensions.sectionGap` | `24px` | Between sections on a screen |

### Radius — `AppDimensions`
| Token | Value | Use Case |
|---|---|---|
| `AppDimensions.radiusSm` | `8px` | Inputs, small containers |
| `AppDimensions.radiusMd` | `12px` | Medium cards |
| `AppDimensions.radiusLg` | `16px` | Standard cards, DebtCard |
| `AppDimensions.radius2xl` | `24px` | Hero cards, bottom sheet handle area |
| `AppDimensions.radiusFull` | `999px` | Buttons (pill), chips, FAB, status badges |

### Heights — `AppDimensions`
| Token | Value | Use Case |
|---|---|---|
| `AppDimensions.buttonHeight` | `48px` | All standard buttons |
| `AppDimensions.buttonHeightLg` | `56px` | Primary CTA at bottom of forms |
| `AppDimensions.buttonHeightSm` | `36px` | Chips |
| `AppDimensions.navBarHeight` | `80px` | NavigationBar (do not override) |
| `AppDimensions.topAppBarHeight` | `64px` | Standard AppBar |

### Typography — `AppTextStyles`
| Token | Size / Weight | Use Case |
|---|---|---|
| `AppTextStyles.displayLarge` | 64 / Bold | AHA moment, zero-debt celebration |
| `AppTextStyles.headlineLarge` | 40 / Bold | Hero card amounts |
| `AppTextStyles.titleLarge` | 22 / Bold | Screen titles, AppBar |
| `AppTextStyles.titleMedium` | 16 / SemiBold | Card titles, section group names |
| `AppTextStyles.bodyLarge` | 16 / Regular | Main content text |
| `AppTextStyles.bodyMedium` | 14 / Medium | Secondary labels, subtitles |
| `AppTextStyles.labelMedium` | 12 / Medium | Form labels, nav labels |
| `AppTextStyles.labelSmall` | 11 / SemiBold | Badge text, micro labels |
| `AppTextStyles.moneyLarge` | 40 / Bold tabular | Hero total debt display |
| `AppTextStyles.moneyMedium` | 28 / Bold tabular | Card balance amounts |
| `AppTextStyles.moneySmall` | 20 / SemiBold tabular | Inline balance |
| `AppTextStyles.moneyXSmall` | 16 / SemiBold tabular | Small balance cells |

---

## Widget Library — Use First, Build Later

**Always prefer existing widgets** before creating new ones:

```dart
// Buttons — never use raw FilledButton/ElevatedButton directly
AppButton.filled(label: 'Áp dụng', onPressed: _submit)
AppButton.filledLg(label: 'Bắt đầu', onPressed: _start, fullWidth: true)
AppButton.tonal(label: 'Xem chi tiết', onPressed: _view)
AppButton.outlined(label: 'Bỏ qua', onPressed: _skip)
AppButton.error(label: 'Xoá khoản nợ', onPressed: _delete)
AppButton.text(label: 'Xem tất cả', onPressed: _seeAll)

// Cards
AppCard(child: ..., onTap: _open)                           // generic card
AppHeroCard(child: ...)                                     // Forest Green fill
DebtCard(name: 'Chase', balance: '$4,800', apr: '18%',     // specific debt card
  state: DebtCardState.overdue, onTap: _open)

// Status indicators
StatusBadge.overdue()
StatusBadge.paid()
StatusBadge.active(label: 'ĐANG TRẢ')
StatusBadge.upcoming()

// Chips
AppChip.filter(label: 'Snowball', selected: _isSelected, onTap: _toggle)
AppChip.assist(label: '+\$500', onTap: _addExtra)

// Inputs
AppTextField(label: 'Tên khoản nợ', controller: _ctrl, required: true)
AppTextField.currency(label: 'Số dư', controller: _balanceCtrl)

// Money display
MoneyText(amount: 4800.0)
MoneyText.large(amount: 18400.0, isPositive: false)  // red
MoneyText.small(amount: 200.0, showSign: true, isPositive: true)  // +$200 green

// Layout helpers
SectionHeader(title: 'Khoản nợ', trailingLabel: 'Xem tất cả', onTrailingTap: ...)
EmptyState(title: 'Chưa có khoản nợ', actionLabel: 'Thêm ngay', onAction: ...)
```

---

## Screen Structure Template

Every screen MUST follow this scaffold pattern:

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mdSurfaceContainerLow, // ← ALWAYS warm white
      appBar: AppBar(
        title: Text('Tên màn hình', style: AppTextStyles.titleLarge),
        // AppBar is themed globally — do NOT override backgroundColor
      ),
      body: SafeArea(
        child: SingleChildScrollView(            // use ListView for long lists
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // sections with AppDimensions.sectionGap between them
              _Section1(),
              const SizedBox(height: AppDimensions.sectionGap),
              _Section2(),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Layout Patterns

### Alternating Surface Rhythm
Use alternating `mdSurface` / `mdSurfaceContainerLow` to separate sections **without hard dividers**:

```dart
// Section on warm white background
Container(
  color: AppColors.mdSurfaceContainerLow,
  padding: const EdgeInsets.all(AppDimensions.md),
  child: ...,
)
// Next section on pure white
AppCard(child: ...)
```

### Bottom Sheet Actions (Edit/Delete)
Never use new screens for edit/delete. Always use `showModalBottomSheet`:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,  // for keyboard avoidance
  builder: (_) => Padding(
    padding: EdgeInsets.only(
      left: AppDimensions.bottomSheetPaddingH,
      right: AppDimensions.bottomSheetPaddingH,
      top: AppDimensions.bottomSheetPaddingV,
      bottom: AppDimensions.bottomSheetPaddingBottom +
          MediaQuery.of(context).viewInsets.bottom,
    ),
    child: ...,
  ),
);
```

### Delete/Destructive Confirmation
Use `showDialog` with Level 3 shadow (handled by `dialogTheme`):

```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('Xoá khoản nợ?', style: AppTextStyles.titleLarge),
    content: Text('Hành động này không thể hoàn tác.', style: AppTextStyles.bodyMedium),
    actions: [
      AppButton.text(label: 'Huỷ', onPressed: () => Navigator.pop(context)),
      AppButton.error(label: 'Xoá', onPressed: _confirmDelete),
    ],
  ),
);
```

---

## Elevation & Borders

| Level | Usage | Implementation |
|---|---|---|
| **0 — Flat** | Scaffold backgrounds, text blocks | No border, no shadow |
| **1 — Card** | Standard content cards | `border: Border.all(color: AppColors.whisperBorder, width: 1)` |
| **2 — Hover** | Interactive card on hover/press (handled by InkWell) | `AppCard` with `onTap` |
| **3 — Modal** | Dialogs, bottom sheets | Handled by `dialogTheme` / `bottomSheetTheme` |

**Never** use `elevation > 0` on cards. Use whisper borders instead.

---

## Financial UX Rules

1. **Money is always right-aligned** in tables and cells
2. **Debt = red**: Use `AppColors.debtRed` / `MoneyText(isPositive: false)`
3. **Payment/saving = green**: Use `AppColors.paidGreen` / `MoneyText(isPositive: true)`
4. **APR/interest** = amber: Use `AppColors.interestAmber`
5. **Always round decimal display**: `intl` via `MoneyText`, never `.toString()`
6. **Never show raw cents** unless specifically requested (e.g., `$4,800` not `$4800.0`)
7. **Overdue cards** always use `DebtCardState.overdue` (red fill + error border)

---

## Mandatory Checks Before Submitting Code

Run through this checklist mentally before completing any UI task:

- [ ] All colors use `AppColors.*` — no raw hex or `Colors.*`
- [ ] All spacing uses `AppDimensions.*` — no magic numbers
- [ ] All text uses `AppTextStyles.*` — no inline `TextStyle(fontSize: ...)`
- [ ] Scaffold background = `AppColors.mdSurfaceContainerLow`
- [ ] Buttons use `AppButton.*` — no raw `ElevatedButton`/`FilledButton`
- [ ] Money amounts use `MoneyText` — no manual `${amount.toStringAsFixed(2)}`
- [ ] Cards use `AppCard` or `DebtCard` — no raw `Card()`
- [ ] Lists have `const` optimizations where possible
- [ ] `flutter analyze` passes with 0 errors and 0 warnings in affected files

---

## Anti-Patterns (NEVER DO)

```dart
// ❌ Hardcoded color
color: Color(0xFF1B6B4A)
color: Colors.green

// ❌ Raw font size
style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

// ❌ Magic number spacing
padding: EdgeInsets.all(16)
SizedBox(height: 24)

// ❌ Raw Flutter button
ElevatedButton(onPressed: ..., child: Text('Submit'))
FilledButton(onPressed: ..., child: Text('Go'))

// ❌ Raw Card widget
Card(elevation: 2, child: ...)

// ❌ Un-formatted money
Text('\$${debt.balance.toStringAsFixed(2)}')

// ❌ Hardcoded Vietnamese strings without i18n comment (mark with // i18n: todo)
```

---

## Vietnamese UI Copy Guidelines

All user-facing strings inside UI widgets for this app should be in Vietnamese:
- "Tổng quan" (Overview/Home)
- "Khoản nợ" (Debt/Debts)
- "Kế hoạch trả nợ" (Payoff plan)
- "Tiến độ" (Progress)
- "Cài đặt" (Settings)
- "Thêm khoản nợ" (Add debt)
- "Số dư còn lại" (Remaining balance)
- "Thời gian trả hết" (Payoff date)
- "Lãi suất hàng năm" (Annual interest rate / APR)
- "Thanh toán tối thiểu" (Minimum payment)
- "Xoá khoản nợ" (Delete debt)
- "Lưu thay đổi" (Save changes)
- "Bỏ qua" (Skip / Cancel)
- "Áp dụng" (Apply)

Mark all hardcoded strings with `// i18n: todo` to signal future localization.
