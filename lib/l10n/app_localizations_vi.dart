// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Debt Payoff X';

  @override
  String get navDebts => 'Khoản nợ';

  @override
  String get navPlan => 'Kế hoạch';

  @override
  String get navProgress => 'Tiến độ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get navThisMonth => 'Tháng này';

  @override
  String get commonAddDebt => 'Thêm khoản nợ';

  @override
  String get commonSavePayment => 'Lưu thanh toán';

  @override
  String get commonUndo => 'Hoàn tác';

  @override
  String get commonViewAll => 'Xem tất cả';

  @override
  String get commonComingSoon => 'Sắp ra mắt';

  @override
  String commonComingSoonFeature(String feature) {
    return '$feature sẽ có trong bản cập nhật sắp tới.';
  }

  @override
  String get commonRecordAnotherAmount => 'Ghi số khác';

  @override
  String get paymentTypeMinimumLabel => 'Tối thiểu';

  @override
  String get paymentTypeExtraLabel => 'Trả thêm';

  @override
  String get paymentTypeLumpSumLabel => 'Trả dồn';

  @override
  String get homeCurrentBalanceTitle => 'Tổng dư nợ hiện tại';

  @override
  String get homeStrategyLabel => 'Chiến lược';

  @override
  String get homeExtraMonthlyLabel => 'Extra / tháng';

  @override
  String homePaidAmountLabel(String amount) {
    return 'Đã trả $amount';
  }

  @override
  String get homeTrackedLabel => 'Đang theo dõi';

  @override
  String get homePaidOffLabel => 'Đã trả xong';

  @override
  String get homePausedLabel => 'Tạm dừng';

  @override
  String get homeTrackedDebtsTitle => 'Khoản nợ cần theo dõi';

  @override
  String get homeTrackedDebtsSubtitle =>
      'Danh sách này lấy trực tiếp từ dữ liệu bạn đã lưu.';

  @override
  String get homeDuePaused => 'Tạm dừng';

  @override
  String homeDueDay(int day) {
    return 'Ngày $day';
  }

  @override
  String get homeNoDebtsTracked => 'Hiện chưa có khoản nợ nào cần theo dõi.';

  @override
  String get homeCurrentPlanTitle => 'Kế hoạch trả nợ hiện tại';

  @override
  String get homeCurrentPlanPendingSubtitle =>
      'App sẽ tính lại ngày hết nợ ngay khi bạn cập nhật khoản trả mới nhất.';

  @override
  String homeCurrentPlanProjectedSubtitle(String monthYear) {
    return 'Nếu giữ nhịp hiện tại, bạn có thể hết nợ vào $monthYear.';
  }

  @override
  String homeCurrentPlanStrategyLine(String strategy, String amount) {
    return '$strategy · Extra $amount / tháng';
  }

  @override
  String get homeViewPlanDetails => 'Xem kế hoạch chi tiết';

  @override
  String get monthlyActionStandaloneTitle => 'Việc tháng này';

  @override
  String get monthlyActionEmptyTitle => 'Chưa có khoản nợ để theo dõi';

  @override
  String get monthlyActionEmptySubtitle =>
      'Thêm khoản nợ đầu tiên để app gợi ý việc cần làm trong tháng.';

  @override
  String get monthlyActionSectionTitle => 'Việc cần làm tháng này';

  @override
  String get monthlyActionSectionSubtitle =>
      'Xử lý khoản bắt buộc trước. App sẽ gợi ý phần trả thêm riêng.';

  @override
  String monthlyActionCompletionChip(int completed, int total) {
    return 'Đã xong $completed/$total';
  }

  @override
  String get monthlyActionSummaryDebtFreeLabel => 'Ngày hết nợ dự kiến';

  @override
  String get monthlyActionSummaryRecalculating => 'Đang tính lại';

  @override
  String get monthlyActionSummaryRequired => 'Bắt buộc';

  @override
  String get monthlyActionSummaryExtra => 'Trả thêm';

  @override
  String get monthlyActionSummaryOverdue => 'Quá hạn';

  @override
  String get monthlyActionRequiredSectionTitle => 'Cần trả bắt buộc';

  @override
  String get monthlyActionRequiredSectionSubtitle =>
      'Quá hạn trước, rồi đến các khoản sắp đến hạn.';

  @override
  String get monthlyActionOptionalSectionTitle => 'Trả thêm để hết nợ sớm hơn';

  @override
  String get monthlyActionOptionalSectionSubtitle =>
      'Chỉ làm phần này sau khi xong các khoản bắt buộc.';

  @override
  String get monthlyActionAllDoneTitle =>
      'Bạn đã xong các khoản bắt buộc tháng này';

  @override
  String get monthlyActionAllDoneSubtitle =>
      'Nếu còn dư ngân sách, bạn có thể dùng phần trả thêm bên dưới để về đích sớm hơn.';

  @override
  String get monthlyActionNextActionTitle =>
      'Tháng này chưa còn khoản nào cần xử lý';

  @override
  String get monthlyActionNextActionSubtitle =>
      'Bạn có thể xem kế hoạch hiện tại hoặc ghi một khoản thanh toán khác nếu vừa trả thêm.';

  @override
  String get monthlyActionNextActionPrimary => 'Xem kế hoạch';

  @override
  String monthlyActionRequiredTotal(String amount) {
    return 'Cần trả $amount';
  }

  @override
  String monthlyActionSuggestedTotal(String amount) {
    return 'Gợi ý $amount';
  }

  @override
  String get monthlyActionDoneBadge => 'Đã xong';

  @override
  String monthlyActionDueDate(String date) {
    return 'Hạn $date';
  }

  @override
  String get monthlyActionOptionalTiming =>
      'Sau khi xong khoản bắt buộc tháng này';

  @override
  String get monthlyActionOptionalHelper =>
      'Khoản này giúp bạn rút ngắn thời gian hết nợ.';

  @override
  String get monthlyActionOverdueChip => 'Quá hạn';

  @override
  String get monthlyActionUpcomingChip => 'Sắp đến hạn';

  @override
  String monthlyActionPriorityChip(int rank) {
    return 'Ưu tiên #$rank';
  }

  @override
  String get monthlyActionSavedButton => 'Đã lưu';

  @override
  String get monthlyActionPaidButton => 'Đã thanh toán';

  @override
  String monthlyActionSnackbarSaved(String debtName) {
    return 'Đã lưu thanh toán cho $debtName.';
  }

  @override
  String get monthlyActionConfirmTitle => 'Xác nhận thanh toán';

  @override
  String get monthlyActionConfirmSubtitle =>
      'Khoản này sẽ được lưu vào lịch sử và cập nhật lại kế hoạch trả nợ của bạn.';

  @override
  String get monthlyActionInfoDebt => 'Khoản nợ';

  @override
  String get monthlyActionInfoType => 'Loại thanh toán';

  @override
  String get monthlyActionInfoAmount => 'Số tiền';

  @override
  String get monthlyActionInfoDate => 'Ngày áp dụng';

  @override
  String monthlyActionRecastDebtFree(
    String previous,
    String current,
    String delta,
  ) {
    return 'Ngày hết nợ dự kiến: $previous → $current$delta';
  }

  @override
  String monthlyActionRecastProjectedInterest(
    String previous,
    String current,
    String delta,
  ) {
    return 'Tổng lãi dự kiến: $previous → $current$delta';
  }

  @override
  String monthlyActionRecastSavedInterest(
    String previous,
    String current,
    String delta,
  ) {
    return 'Lãi tiết kiệm được: $previous → $current$delta';
  }

  @override
  String monthlyActionDeltaSooner(int months) {
    return ' (sớm hơn $months tháng)';
  }

  @override
  String monthlyActionDeltaLater(int months) {
    return ' (trễ hơn $months tháng)';
  }

  @override
  String monthlyActionDeltaReduced(String amount) {
    return ' (giảm $amount)';
  }

  @override
  String monthlyActionDeltaIncreased(String amount) {
    return ' (tăng $amount)';
  }

  @override
  String get monthlyActionRecastNeutral =>
      'Kế hoạch vừa được cập nhật từ dữ liệu mới nhất của bạn.';

  @override
  String get logPaymentTitle => 'Ghi nhận thanh toán';

  @override
  String get logPaymentMissingDebt =>
      'Khoản nợ này không còn tồn tại hoặc đã bị xóa.';

  @override
  String logPaymentCurrentBalance(String amount) {
    return 'Dư nợ hiện tại $amount';
  }

  @override
  String get logPaymentAmountLabel => 'Số tiền đã trả';

  @override
  String get logPaymentAmountHelper =>
      'Số tiền này sẽ được trừ trực tiếp vào dư nợ hiện tại.';

  @override
  String get logPaymentTypeLabel => 'Loại thanh toán';

  @override
  String get logPaymentDateLabel => 'Ngày áp dụng';

  @override
  String get logPaymentNoteLabel => 'Ghi chú';

  @override
  String get logPaymentNoteHint => 'Ví dụ: trả tự động, thưởng, trả trước hạn';

  @override
  String get logPaymentInfo =>
      'Khoản thanh toán này sẽ lưu lại số dư trước và sau, rồi cập nhật kế hoạch ngay sau khi lưu.';

  @override
  String get logPaymentInvalidAmount => 'Nhập số tiền hợp lệ lớn hơn 0.';

  @override
  String get logPaymentSavedMessage =>
      'Đã lưu thanh toán và cập nhật kế hoạch.';

  @override
  String get pricingBody =>
      'Bản MVP hiện tại vẫn giữ đầy đủ core payoff flow miễn phí. Premium là lộ trình tiếp theo cho cloud backup, PDF report và shared planning.';

  @override
  String get pricingContinueFree => 'Tiếp tục với bản miễn phí';

  @override
  String get pricingFreeBulletExport =>
      'CSV export + local backup/restore + clear all';

  @override
  String get pricingFreeBulletPayments =>
      'Payment logging + monthly action view';

  @override
  String get pricingFreeBulletStrategies =>
      'Snowball / Avalanche + living timeline';

  @override
  String get pricingFreeBulletUnlimitedDebts =>
      'Nhập và chỉnh sửa không giới hạn khoản nợ';

  @override
  String get pricingFreeSubtitle => 'Có sẵn trong MVP';

  @override
  String get pricingFreeTitle => 'Free';

  @override
  String get pricingHeadline =>
      'Local-first trước. Premium chỉ mở khi thật sự thêm giá trị.';

  @override
  String get pricingMvpNotice => 'Premium chưa mở trong bản MVP này.';

  @override
  String get pricingPageTitle => 'Free vs Premium';

  @override
  String get pricingPremiumBulletCloud => 'Cloud backup giữa nhiều thiết bị';

  @override
  String get pricingPremiumBulletPdf =>
      'PDF report để in hoặc gửi cố vấn tài chính';

  @override
  String get pricingPremiumBulletPricing =>
      'Pricing minh bạch, không trial mập mờ';

  @override
  String get pricingPremiumBulletSharing =>
      'Partner sharing và scenario comparison';

  @override
  String get pricingPremiumSubtitle =>
      'Stub để chuẩn bị monetization, chưa có IAP';

  @override
  String get pricingPremiumTitle => 'Premium';

  @override
  String get pricingTrustMessage =>
      'Cam kết trust không đổi khi lên Premium: không bank linking, không auto-charge mập mờ, và local export vẫn luôn khả dụng.';

  @override
  String get settingsCancel => 'Hủy';

  @override
  String get settingsClearAllDialogBody =>
      'Thao tác này sẽ xóa toàn bộ dữ liệu local và đưa app về trạng thái lần đầu mở.';

  @override
  String get settingsClearAllDialogTitle => 'Xóa toàn bộ dữ liệu?';

  @override
  String get settingsClearAllSubtitle =>
      'Chỉ reset dữ liệu trên thiết bị này. Cloud chưa bật ở Level 0.';

  @override
  String get settingsClearAllTitle => 'Xóa toàn bộ dữ liệu';

  @override
  String get settingsCloudBackupTitle => 'Sao lưu đám mây';

  @override
  String get settingsContinue => 'Tiếp tục';

  @override
  String get settingsCopyrightFooter => '© 2026 Debt Payoff X';

  @override
  String get settingsCurrencySubtitle =>
      'Hiện tại chỉ dùng cho format hiển thị.';

  @override
  String get settingsCurrencyTitle => 'Loại tiền tệ';

  @override
  String get settingsDataBannerLocalBody =>
      'Dữ liệu hiện nằm trên thiết bị này. Bạn luôn có CSV export, local backup/restore và clear all mà không cần tài khoản hoặc bank linking.';

  @override
  String get settingsDataBannerLocalTitle => 'Local-first đang bật';

  @override
  String get settingsDataBannerTrustBody =>
      'Bạn đang ở trust level > 0. Local export vẫn còn, nhưng các thao tác reset cần cẩn thận hơn vì có thể liên quan tới cloud semantics.';

  @override
  String get settingsDataBannerTrustTitle => 'Trust mode nâng cao đang bật';

  @override
  String get settingsDeleteAllConfirm => 'Xóa sạch';

  @override
  String get settingsExportCsvSubtitle =>
      'ZIP gồm nhiều file CSV + manifest để bạn tự kiểm tra từng bảng.';

  @override
  String get settingsExportCsvTitle => 'Xuất dữ liệu (CSV)';

  @override
  String get settingsExtraMonthlySubtitle =>
      'Đang lưu trong kế hoạch chính của bạn.';

  @override
  String get settingsExtraMonthlyTitle => 'Trả thêm hàng tháng';

  @override
  String get settingsFinalConfirmBody =>
      'Bạn sẽ mất toàn bộ debts, payments, milestones và backup local hiện tại trong app này.';

  @override
  String get settingsFinalConfirmTitle => 'Xác nhận lần cuối';

  @override
  String get settingsGoBack => 'Quay lại';

  @override
  String get settingsCurrentStrategySubtitle =>
      'Mở tab Kế hoạch để xem thứ tự ưu tiên chi tiết.';

  @override
  String get settingsCurrentStrategyTitle => 'Chiến lược hiện tại';

  @override
  String get settingsLocaleSheetTitle => 'Chọn ngôn ngữ';

  @override
  String get settingsLocaleSubtitle =>
      'Ảnh hưởng tới ngôn ngữ hiển thị và format ngày.';

  @override
  String get settingsLocaleTitle => 'Ngôn ngữ';

  @override
  String get settingsLocalBackupSubtitle =>
      'Tạo JSON backup ZIP đầy đủ để lưu sang Files, Drive hoặc ổ đĩa ngoài.';

  @override
  String get settingsLocalBackupTitle => 'Sao lưu cục bộ';

  @override
  String get settingsMonthlyLogSubtitle =>
      'Dùng cho monthly log summary khi flow này được mở.';

  @override
  String get settingsMonthlyLogTitle => 'Nhật ký hàng tháng';

  @override
  String get settingsPageTitle => 'Cài đặt';

  @override
  String get settingsPaymentReminderSubtitle =>
      'App sẽ dùng cài đặt này khi payment reminders được bật.';

  @override
  String get settingsPaymentReminderTitle => 'Nhắc nhở thanh toán';

  @override
  String get settingsResetAction => 'Reset';

  @override
  String get settingsRestoreAction => 'Khôi phục';

  @override
  String get settingsRestoreConfirm => 'Khôi phục';

  @override
  String get settingsRestoreDialogDataHeader => 'Dữ liệu trong backup:';

  @override
  String get settingsRestoreDialogExportedAtLabel => 'Xuất lúc';

  @override
  String get settingsRestoreDialogFileLabel => 'File';

  @override
  String get settingsRestoreDialogTitle => 'Khôi phục từ bản sao lưu?';

  @override
  String get settingsRestoreDialogTotalRecordsLabel => 'Tổng bản ghi';

  @override
  String get settingsRestoreDialogWarning =>
      'Toàn bộ dữ liệu local hiện tại sẽ bị thay thế.';

  @override
  String get settingsRestoreSubtitle =>
      'Đọc preview manifest và số bản ghi trước khi thay thế dữ liệu local.';

  @override
  String get settingsRestoreSuccess =>
      'Đã khôi phục dữ liệu local từ bản sao lưu đã chọn.';

  @override
  String get settingsRestoreTitle => 'Khôi phục từ bản sao lưu';

  @override
  String get settingsSectionData => 'DỮ LIỆU';

  @override
  String get settingsSectionOptions => 'TUỲ CHỌN';

  @override
  String get settingsSectionPlan => 'KẾ HOẠCH TRẢ NỢ';

  @override
  String get settingsSectionReminders => 'NHẮC NHỞ';

  @override
  String get settingsStrategyAvalanche => 'Avalanche';

  @override
  String get settingsStrategyCustom => 'Custom';

  @override
  String get settingsStrategySnowball => 'Snowball';

  @override
  String get settingsTrustLevelLocalOnlyBody =>
      'Hiện tại bạn đang ở local-only. Cloud backup là roadmap tiếp theo, không phải yêu cầu để dùng app.';

  @override
  String get settingsTrustLevelLocalOnlyLabel => 'Local only';

  @override
  String get settingsTrustLevelOneBody =>
      'Cloud backup cơ bản đã bật. Local export vẫn luôn khả dụng.';

  @override
  String get settingsTrustLevelOneLabel => 'Trust 1';

  @override
  String get settingsTrustLevelTwoBody =>
      'Đang dùng trust mode cao hơn. Hãy kiểm tra quyền chia sẻ trước khi reset local.';

  @override
  String get settingsTrustLevelTwoLabel => 'Trust 2';

  @override
  String get settingsVersionFooter => 'Phiên bản 1.0.0 (MVP)';

  @override
  String get settingsZipLabel => 'ZIP';

  @override
  String get syncBackupBody =>
      'Hiện tại app của bạn đang ở chế độ local-only. Bạn vẫn có đầy đủ export, local backup và restore mà không cần tài khoản.';

  @override
  String get syncBackupContinueLocal => 'Tiếp tục dùng local-only';

  @override
  String get syncBackupFreeBulletBackup =>
      'Local backup ZIP để lưu thủ công sang Files hoặc Drive';

  @override
  String get syncBackupFreeBulletCsv =>
      'CSV export đầy đủ để mở trong Excel hoặc Numbers';

  @override
  String get syncBackupFreeBulletPreview =>
      'Restore có preview trước khi thay thế dữ liệu local';

  @override
  String get syncBackupFreeBulletReset =>
      'Clear all / factory reset mà không khóa quyền truy cập dữ liệu';

  @override
  String get syncBackupFreeTitle => 'Bạn đã có trong bản miễn phí';

  @override
  String get syncBackupHeadline =>
      'Sao lưu đám mây là bước tiếp theo, không phải điều kiện để dùng app.';

  @override
  String get syncBackupPremiumBulletCloud => 'Cloud backup giữa nhiều thiết bị';

  @override
  String get syncBackupPremiumBulletPdf =>
      'PDF report để in hoặc gửi cố vấn tài chính';

  @override
  String get syncBackupPremiumBulletPricing =>
      'Pricing minh bạch, không trial mập mờ';

  @override
  String get syncBackupPremiumBulletSharing =>
      'Partner sharing và scenario comparison';

  @override
  String get syncBackupPremiumTitle => 'Premium sau này sẽ thêm';

  @override
  String get syncBackupTrustMessage =>
      'Cam kết trust không đổi: dữ liệu khởi đầu nằm trên thiết bị, không bank linking, và export local vẫn luôn mở ngay cả khi Premium xuất hiện.';

  @override
  String get syncBackupViewPricing => 'Xem Free vs Premium';

  @override
  String get welcomeAddFirstDebt => 'Thêm khoản nợ đầu tiên';

  @override
  String get welcomeChangeLanguage => 'Đổi ngôn ngữ';

  @override
  String get welcomeSubtitle =>
      'Tạo kế hoạch trả nợ cá nhân hoá trong 3 phút.\nKhông tài khoản. Không chạm ngân hàng.';

  @override
  String get welcomeTitle => 'Kiểm soát nợ,\ngiải phóng tương lai.';

  @override
  String get welcomeTrustFree => 'Miễn phí';

  @override
  String get welcomeTrustLocalFirst => 'Local-first';

  @override
  String get welcomeTrustNoBankSync => 'Không sync bank';

  @override
  String get planExtraAmountSheetTitle => 'Số tiền trả thêm';

  @override
  String get planExtraAmountSheetSubtitle =>
      'Tăng tiền trả thêm hàng tháng giúp bạn rút ngắn đáng kể thời gian dứt nợ.';

  @override
  String get planExtraAmountSheetSave => 'Lưu thay đổi';

  @override
  String get planExtraAmountSheetReset => 'Về mức \$0 (Tối thiểu)';

  @override
  String get planTimelineTitle => 'Kế hoạch';

  @override
  String get planTimelineEmptyTitle => 'Chưa có kế hoạch để hiển thị';

  @override
  String get planTimelineEmptySubtitle =>
      'Thêm ít nhất một khoản nợ để app recast timeline, debt-free date, và projected interest của bạn.';

  @override
  String get planTimelineAllPaidTitle => 'Tất cả khoản nợ đã được trả xong';

  @override
  String get planTimelineAllPaidSubtitle =>
      'Timeline tháng không còn khoản đang hoạt động. App vẫn giữ plan summary cuối cùng để bạn đối chiếu.';

  @override
  String get planTimelineRecasting => 'Đang recast...';

  @override
  String planTimelineStrategySummary(
    String strategy,
    String amount,
    int months,
  ) {
    return '$strategy · Extra $amount / tháng · $months tháng projected';
  }

  @override
  String get planTimelineRecastNeutral =>
      'Plan vừa được recast từ dữ liệu mới nhất.';

  @override
  String get planTimelineComparisonTitle => 'Projected vs minimum-only';

  @override
  String get planTimelineComparisonCurrent => 'Kế hoạch hiện tại';

  @override
  String get planTimelineComparisonBaseline => 'Minimum-only baseline';

  @override
  String get planTimelineComparisonSaved => 'Tiết kiệm được';

  @override
  String get planTimelineSectionTitle => 'Timeline theo tháng';

  @override
  String get planTimelineSectionSubtitle =>
      'List-first view với payment breakdown, ending balance, và milestone payoff theo projection mới nhất.';

  @override
  String get planTimelineHeroDebtFree => 'Debt-free date';

  @override
  String get planTimelineHeroProjectedInterest => 'Projected interest';

  @override
  String get planTimelineHeroSavedVsMinimum => 'Saved vs minimum';

  @override
  String get planTimelineMonthEndingBalance => 'Ending balance';

  @override
  String get planTimelineMonthDebtsPaidOff => 'Debts paid off';

  @override
  String get planTimelineMonthStartingBalance => 'Starting balance';

  @override
  String get planTimelineMonthInterestAccrued => 'Interest accrued';

  @override
  String get planTimelineMonthPaymentApplied => 'Payment applied';

  @override
  String get planTimelineMonthPaymentLabel => 'Payment';

  @override
  String get planTimelineMonthInterestLabel => 'Interest';

  @override
  String get planTimelinePaidOffBadge => 'Paid off';

  @override
  String get onboardingDebtEntryTitle => 'Thêm khoản nợ đầu tiên';

  @override
  String get onboardingDebtEntrySave => 'Lưu khoản nợ';

  @override
  String get onboardingStep1 => 'Bước 1/4';

  @override
  String get onboardingAddAnotherTitle => 'Kiểm tra lại khoản nợ';

  @override
  String get onboardingStep2 => 'Bước 2/4';

  @override
  String get onboardingAddAnotherEmpty => 'Bạn chưa lưu khoản nợ nào.';

  @override
  String onboardingAddAnotherCount(int count) {
    return 'Bạn đã lưu $count khoản nợ. Có thể thêm tiếp hoặc sang bước chọn chiến lược.';
  }

  @override
  String get onboardingAddAnotherRequirement =>
      'Hãy thêm ít nhất 1 khoản nợ để app có thể tiếp tục onboarding.';

  @override
  String get onboardingAddAnotherContinue => 'Sang bước chọn chiến lược';

  @override
  String get onboardingAddAnotherAddMore => 'Thêm một khoản nợ nữa';

  @override
  String get onboardingStrategyTitle => 'Chọn chiến lược';

  @override
  String get onboardingStep3 => 'Bước 3/4';

  @override
  String get onboardingStrategySubtitle =>
      'Chọn cách app ưu tiên khoản nợ khi bạn bắt đầu trả thêm.';

  @override
  String get onboardingStrategyRequirement =>
      'Bạn cần ít nhất một khoản nợ để chọn chiến lược.';

  @override
  String get onboardingStrategyDescription =>
      'App đang so projection thật của Snowball và Avalanche từ dữ liệu khoản nợ hiện tại của bạn.';

  @override
  String get onboardingStrategyEmptyTitle =>
      'Chưa có khoản nợ để áp dụng chiến lược';

  @override
  String get onboardingStrategyEmptySubtitle =>
      'Hãy thêm ít nhất một khoản nợ trước khi tiếp tục.';

  @override
  String get onboardingStrategyBackToAdd => 'Quay lại thêm khoản nợ';

  @override
  String get onboardingStrategySnowballFallback =>
      'Ưu tiên khoản có số dư nhỏ nhất.';

  @override
  String get onboardingStrategyAvalancheFallback =>
      'Ưu tiên APR cao nhất để giảm lãi.';

  @override
  String get onboardingStrategyChangeNote =>
      'Bạn có thể đổi chiến lược bất kỳ lúc nào sau onboarding. Mỗi lần đổi, plan summary và timeline cache sẽ recast lại.';

  @override
  String get onboardingStrategyContinue => 'Lưu chiến lược và tiếp tục';

  @override
  String get onboardingStrategyTopPriorityExcluded =>
      'Mọi khoản đang được exclude khỏi strategy.';

  @override
  String onboardingStrategyTopPriority(String name) {
    return 'Bắt đầu với $name';
  }

  @override
  String get onboardingStrategyPreviewCalculating =>
      'Đang tính payoff date và projected interest từ dữ liệu hiện tại...';

  @override
  String get onboardingStrategyPreviewRecasting => 'Đang recast';

  @override
  String onboardingStrategyPreviewSummary(
    String date,
    String duration,
    String interest,
  ) {
    return 'Debt-free $date · $duration · lãi $interest';
  }

  @override
  String onboardingStrategyPreviewSaved(String saved) {
    return 'Tiết kiệm $saved vs minimum-only';
  }

  @override
  String get onboardingStrategyError =>
      'Không thể lưu chiến lược. Vui lòng thử lại.';

  @override
  String get onboardingStrategyPreviewTitle => 'Preview hiện tại';

  @override
  String get onboardingExtraTitle => 'Ngân sách thêm';

  @override
  String get onboardingStep4 => 'Bước 4/4';

  @override
  String get onboardingExtraSubtitle =>
      'Ngoài khoản tối thiểu, bạn muốn để thêm bao nhiêu mỗi tháng?';

  @override
  String get onboardingExtraDescription =>
      'Mặc định là \$0. Preview sẽ recast live sau 300ms để cho bạn thấy debt-free date và lãi tiết kiệm thật.';

  @override
  String get onboardingExtraMonthlyLabel => 'Extra payment mỗi tháng';

  @override
  String onboardingExtraTrackedCount(String strategy, int count) {
    return '$strategy · $count khoản đang theo dõi';
  }

  @override
  String get onboardingExtraMaxLabel => 'Max';

  @override
  String get onboardingExtraWhatsNextTitle => 'Điều gì xảy ra tiếp theo?';

  @override
  String get onboardingExtraWhatsNextDescription =>
      'Khoản extra này sẽ được dùng làm ngân sách trả thêm mỗi tháng. Khi bạn bấm lưu, plan summary và timeline cache sẽ recast ngay.';

  @override
  String get onboardingExtraSave => 'Lưu và xem tóm tắt';

  @override
  String get onboardingExtraUseZero => 'Dùng \$0 lúc này';

  @override
  String get onboardingExtraError =>
      'Không thể lưu ngân sách thêm. Vui lòng thử lại.';

  @override
  String get onboardingExtraPreviewEmpty =>
      'Thêm ít nhất một khoản nợ để xem preview payoff thật.';

  @override
  String get onboardingExtraPreviewTitle => 'Live preview';

  @override
  String get onboardingExtraPreviewRecasting => 'Đang recast...';

  @override
  String onboardingExtraPreviewDebtFree(String extraAmount) {
    return 'Debt-free date với extra $extraAmount / tháng';
  }

  @override
  String get onboardingExtraPreviewProjectedInterest => 'Projected interest';

  @override
  String get onboardingExtraPreviewSavedVsMinimum => 'Saved vs minimum';

  @override
  String get onboardingAhaEmpty => 'Bạn chưa có khoản nợ nào trong kế hoạch.';

  @override
  String get onboardingAhaRecasting => 'Kế hoạch của bạn đang recast.';

  @override
  String onboardingAhaDebtFree(String date) {
    return 'Bạn có thể debt-free vào $date.';
  }

  @override
  String get onboardingAhaEmptySubtitle =>
      'Hãy quay lại bước trước để thêm ít nhất một khoản nợ.';

  @override
  String get onboardingAhaReadySubtitle =>
      'Kế hoạch đã được recast. Checklist tháng này đã sẵn sàng.';

  @override
  String get onboardingAhaSummaryTitle => 'Tóm tắt hiện tại';

  @override
  String get onboardingAhaTotalBalance => 'Tổng dư nợ';

  @override
  String get onboardingAhaTrackedCount => 'Khoản theo dõi';

  @override
  String get onboardingAhaDataCompact =>
      'Dữ liệu lưu local. Không cần tài khoản.';

  @override
  String get onboardingAhaDataFull =>
      'Dữ liệu của bạn đã được lưu local trên thiết bị. Từ đây bạn có thể vào Monthly Action View để check off payment thật và xem timeline recast ngay.';

  @override
  String get onboardingAhaBackToAdd => 'Quay lại thêm khoản nợ';

  @override
  String get onboardingAhaOpenMonthly => 'Mở Monthly Action View';

  @override
  String get onboardingAhaRecastingShort => 'Đang recast';

  @override
  String get onboardingAhaDebtFreeDate => 'Debt-free date';

  @override
  String get onboardingAhaExtraMonthly => 'Extra / tháng';

  @override
  String get onboardingAhaProjectedInterest => 'Projected interest';

  @override
  String get onboardingAhaSavedVsMinimum => 'Saved vs minimum';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonTotalDebt => 'Tổng dư nợ';

  @override
  String get commonNotes => 'Ghi chú';

  @override
  String get debtDetailTitle => 'Chi tiết khoản nợ';

  @override
  String get debtDetailInitialPrincipal => 'Số gốc ban đầu';

  @override
  String get debtDetailApr => 'APR';

  @override
  String get debtDetailDueDate => 'Ngày đến hạn';

  @override
  String get debtDetailMinimumPayment => 'Minimum payment';

  @override
  String get debtDetailInterestCalc => 'Cách tính lãi';

  @override
  String get debtDetailLogPayment => 'Log payment';

  @override
  String get debtDetailViewHistory => 'Xem history';

  @override
  String get debtDetailArchiveTitle => 'Lưu trữ khoản nợ?';

  @override
  String get debtDetailArchivedMsg => 'Đã lưu trữ khoản nợ.';

  @override
  String get debtDetailUnarchivedMsg =>
      'Đã đưa khoản nợ trở lại danh sách đã trả.';

  @override
  String get debtDetailDeleteTitle => 'Xóa khoản nợ?';

  @override
  String get debtDetailDeletedMsg => 'Đã xóa khoản nợ.';

  @override
  String get debtsListTitle => 'Các khoản nợ';

  @override
  String get debtsListFilterAll => 'Tất cả';

  @override
  String get debtsListFilterActive => 'Đang nợ';

  @override
  String get debtsListFilterPaid => 'Đã trả';

  @override
  String get debtsListFilterArchived => 'Đã lưu trữ';

  @override
  String get logPaymentNotFound =>
      'Khoản nợ này không còn tồn tại hoặc đã bị xóa.';

  @override
  String get paymentHistoryTitle => 'Lịch sử thanh toán';

  @override
  String get paymentHistoryNoPayments => 'Chưa có payment cho bộ lọc này';

  @override
  String get debtOptionsEdit => 'Chỉnh sửa khoản nợ';

  @override
  String get debtOptionsDelete => 'Xóa khoản nợ';

  @override
  String get debtOptionsDeleteSubtitle =>
      'Bạn vẫn có thể khôi phục ngay sau khi xóa.';

  @override
  String get editDebtTitle => 'Chỉnh sửa khoản nợ';

  @override
  String get monthlyActionThisMonth => 'Tháng này';

  @override
  String get monthlyActionNoChecklist => 'Không có checklist cho tháng này';

  @override
  String get monthlyActionNeedToPay => 'Tháng này bạn cần trả';

  @override
  String get monthlyActionTotalThisMonth => 'Tổng tháng này';

  @override
  String get monthlyActionCompleted => 'Đã hoàn thành';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get progressNoProgress => 'Chưa có tiến độ để hiển thị';

  @override
  String get progressByDebt => 'Tiến độ theo khoản';

  @override
  String get progressPlanSummary => 'Plan summary';

  @override
  String get progressDebtFreeDate => 'Debt-free date';

  @override
  String get progressProjectedInterest => 'Projected interest';

  @override
  String get progressSavedVsMinimum => 'Saved vs minimum';

  @override
  String get debtDetailInfo => 'Thông tin khoản nợ';

  @override
  String get debtDetailWarnings => 'Lưu ý dữ liệu';

  @override
  String get debtDetailTracking => 'Theo dõi thanh toán';

  @override
  String get debtDetailTrackingHelper =>
      'Log payment thật để giảm current balance, tạo audit trail trước/sau, và recast timeline ngay lập tức.';

  @override
  String get debtDetailArchiveMessage =>
      'Khoản nợ đã trả xong này sẽ được chuyển sang danh sách lưu trữ.';

  @override
  String get debtDetailArchiveConfirm => 'Lưu trữ';

  @override
  String get debtDetailDeleteMessage =>
      'Khoản nợ sẽ bị ẩn khỏi app, nhưng bạn vẫn có thể khôi phục ngay sau khi xóa.';

  @override
  String get debtDetailDeleteConfirm => 'Xóa';

  @override
  String get debtsListSectionAll => 'Tất cả khoản nợ';

  @override
  String get debtsListSectionActive => 'Khoản nợ đang theo dõi';

  @override
  String get debtsListSectionPaidOff => 'Khoản nợ đã trả xong';

  @override
  String get debtsListSectionArchived => 'Khoản nợ đã lưu trữ';

  @override
  String get debtsListEmptyAll =>
      'Bạn chưa có khoản nợ nào. Hãy thêm khoản đầu tiên.';

  @override
  String get debtsListEmptyActive =>
      'Hiện không có khoản nợ nào đang theo dõi.';

  @override
  String get debtsListEmptyPaidOff =>
      'Chưa có khoản nợ nào được đánh dấu đã trả xong.';

  @override
  String get debtsListEmptyArchived => 'Chưa có khoản nợ nào được lưu trữ.';

  @override
  String get logPaymentHelperAmount =>
      'Amount giảm trực tiếp current balance (balance-first model).';

  @override
  String get logPaymentAuditHelper =>
      'Payment này sẽ tạo audit trail với số dư trước/sau và recast timeline ngay sau khi lưu.';

  @override
  String get logPaymentErrorInvalidAmount => 'Nhập số tiền hợp lệ lớn hơn 0.';

  @override
  String get monthlyActionNoChecklistSubtitle =>
      'Mọi khoản đang theo dõi của bạn đã trả xong hoặc đang tạm dừng. Timeline vẫn được recast từ dữ liệu mới nhất.';

  @override
  String get monthlyActionChecklistHelper =>
      'Checklist này được compute trực tiếp từ strategy, timeline cache, và payment history của bạn.';

  @override
  String get monthlyActionRecasting => 'Đang recast...';

  @override
  String monthlyActionInMonth(String monthYear) {
    return 'Trong $monthYear';
  }

  @override
  String get monthlyActionLogged => 'Đã log';

  @override
  String get monthlyActionCheckOff => 'Check off';

  @override
  String get progressEmptySubtitle =>
      'Thêm khoản nợ đầu tiên để app bắt đầu theo dõi mức độ hoàn thành của bạn.';

  @override
  String get progressPaidSoFar => 'Đã trả được';

  @override
  String progressRemainingAmount(String amount) {
    return 'Còn lại $amount';
  }

  @override
  String get progressOverall => 'Tiến độ tổng thể';

  @override
  String get progressTabHelper =>
      'Tiến độ ở đây kết hợp cả số dư thực tế và plan summary đã recast. Phần overview trước đây ở Home đã được chuyển về tab này.';

  @override
  String get progressByDebtHelper =>
      'Dựa trên số dư hiện tại so với gốc ban đầu của từng khoản.';

  @override
  String get progressDebtPaidOffStatus =>
      'Khoản nợ này đã được đánh dấu trả xong.';

  @override
  String get progressDebtPausedStatus => 'Khoản nợ này đang tạm dừng.';

  @override
  String progressDebtRemainingVsOriginal(String current, String original) {
    return 'Còn lại $current trên gốc $original';
  }

  @override
  String paymentHistorySubtitle(int count, String balance) {
    return '$count payment đã log · Current balance $balance';
  }

  @override
  String get paymentHistoryByMonth => 'Theo tháng';

  @override
  String get paymentHistoryNoPaymentsSubtitle =>
      'Log payment từ debt detail hoặc Monthly Action View để thấy lịch sử thật.';

  @override
  String get paymentTypeFeeLabel => 'Fee adjustment';

  @override
  String get paymentTypeRefundLabel => 'Refund';

  @override
  String get paymentTypeChargeLabel => 'Charge';

  @override
  String get debtOptionsUnarchive => 'Bỏ lưu trữ';

  @override
  String get debtOptionsArchive => 'Lưu trữ khoản nợ';

  @override
  String get addDebtTitle => 'Thêm khoản nợ';

  @override
  String get addDebtSave => 'Lưu khoản nợ';

  @override
  String get addDebtSaveChanges => 'Lưu thay đổi';

  @override
  String get commonMonth => 'tháng';
}
