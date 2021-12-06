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
    
    var identifier: String {
      switch self {
      case .paywall: return Destination.toPaywall.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .paywall(let handlers): return PaywallViewModel(subscription: Subscription.currentGroup.main ,handlers: handlers)
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
    case .toPaywall:
      if let controller = destination.destinationController(for: segue) as? PaywallController {
        controller.viewModel = vModel as? PaywallViewModel
      }
    default: break
    }
  }
}


