//
//  AppDelegate.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import UIKit
import SwiftyStoreKit
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    _createDefaultsFolders()
    _completeTransactions()
    
    PresentPaywallOnLaunchHelper.showIfNeeded()
    
    SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
      PresentPaywallOnLaunchHelper.showPaywall(with: Subscription.from(product: product))
      return true
    }
    
    AppStoreReviewHelper.askForReviewIfNeeded()
    
    return true
  }
  
  private func _createDefaultsFolders() {
    FileManager.createDefaults()
  }
  
  private func _completeTransactions() {
    SubscriptionHelper.completeTransactions()
  }
  
  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}

extension AppDelegate {
  static var shared: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  var rootViewController: RootTabController? {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: "RootVC") as? RootTabController
  }
}

extension UIApplication {
  static var mainWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .filter({$0.activationState == .foregroundActive})
      .map({$0 as? UIWindowScene})
      .compactMap({$0})
      .first?.windows
      .filter({$0.isKeyWindow}).first
  }
  
  class var rootController: RootTabController? {
    var topMostViewController = UIApplication.mainWindow?.rootViewController
    while let presentedViewController = topMostViewController?.presentedViewController {
        topMostViewController = presentedViewController
    }
    return topMostViewController as? RootTabController
  }
}

private extension Subscription {
  static func from(product: SKProduct) -> Subscription {
    guard let purchase = Subscription.init(rawValue: product.productIdentifier) else {
      return .monthlyTrial2
    }
    return purchase
  }
}
