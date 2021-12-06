//
//  RootTabController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import UIKit

final class RootTabController: UITabBarController {
  
  private lazy var _router = RootRouter(controller: self)

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func reloadControllers() {
    viewControllers?.forEach({ (controller) in
      switch controller {
      case is UINavigationController:
        if let rootController = (controller as? UINavigationController)?.viewControllers.first as? TabBared {
          rootController.appeared()
        }
      case is TabBared:
        (controller as? TabBared)?.appeared()
      default: break
      }
    })
  }

  func showPaywall(subscription: Subscription = Subscription.currentGroup.trial) {
    _router.navigate(to: .paywall(subscription, .empty))
  }
  
  func showPresentation() {
    _router.navigate(to: .presentation)
  }
}
