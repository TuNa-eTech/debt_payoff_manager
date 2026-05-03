import app_links
import FirebaseCore
import Flutter
import StoreKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    registerSubscriptionChannel()
    if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
      AppLinks.shared.handleLink(url: url)
      return true
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerSubscriptionChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "debt_payoff_manager/subscriptions",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "openManageSubscriptions" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.openManageSubscriptions(result: result)
    }
  }

  private func openManageSubscriptions(result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(
        FlutterError(
          code: "UNAVAILABLE",
          message: "Subscription management requires iOS 15 or later.",
          details: nil
        )
      )
      return
    }
    guard let scene = window?.windowScene else {
      result(
        FlutterError(
          code: "NO_WINDOW_SCENE",
          message: "No active window scene is available.",
          details: nil
        )
      )
      return
    }

    Task { @MainActor in
      do {
        try await AppStore.showManageSubscriptions(in: scene)
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "STOREKIT_ERROR",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }
}
