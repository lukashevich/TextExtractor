//
//  PresentationRouter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.08.2021.
//

import UIKit

class PresentationRouter {
  
  private let _controller: PresentationController
  required init(controller: PresentationController) {
    self._controller = controller
  }
  
  enum Segue {
    case paywall(PaywallHandlers?)
    case doublePaywall(DoublePaywallSubscriptions, PaywallHandlers)

    var identifier: String {
      switch self {
      case .paywall: return Destination.toPaywall.rawValue
      case .doublePaywall: return Destination.toDoublePaywall.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .doublePaywall(let subscriptions, let handlers):
        return DoublePaywallViewModel(subscriptions: subscriptions, handlers: handlers, source: .onboarding)
      case .paywall(let handlers):
        return PaywallViewModel(subscription: Subscription.currentGroup.main, handlers: handlers, source: .onboarding)
      }
    }
  }
  
  func navigate(to segue: Segue) {
    switch _controller.tabBarController {
    case .none:
      _controller.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
    case .some(let tabbar):
      tabbar.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
    }
  }
}


extension PresentationController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier,
            let destination = Destination(rawValue: identifier),
              let vModel = sender else { return }
    
    switch destination {
    case .toDoublePaywall:
      if let controller = destination.destinationController(for: segue) as? DoublePaywallController {
        controller.viewModel = vModel as? DoublePaywallViewModel
      }
    case .toPaywall:
      if let controller = destination.destinationController(for: segue) as? PaywallController {
        controller.viewModel = vModel as? PaywallViewModel
      }
    default: break
    }
  }
}


