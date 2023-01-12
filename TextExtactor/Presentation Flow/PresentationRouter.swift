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
    case paywall(DoublePaywallSubscriptions, PaywallHandlers)
    
    var identifier: String {
      switch self {
      case .paywall: return Destination.toDoublePaywall.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .paywall(let subscriptions, let handlers):
        return DoublePaywallViewModel(subscriptions: subscriptions, handlers: handlers, source: .main)
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
    default: break
    }
  }
}


