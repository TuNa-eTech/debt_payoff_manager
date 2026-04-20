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
  String get logPaymentNoteHint => 'Ví dụ: autopay, bonus, paycheck sweep';

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
}
