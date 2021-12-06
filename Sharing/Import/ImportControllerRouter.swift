//
//  ImportControllerRouter.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 17.05.2021.
//

import Foundation

class ImportControllerRouter {
  
  private let _controller: ImportController
  required init(controller: ImportController) {
    self._controller = controller
  }
  
  enum Segue {
    case locales(LocalePickerHandler)
    case paywall(PaywallHandlers?)
    
    var identifier: String {
      switch self {
      case .locales: return Destination.toLocalePicker.rawValue
      case .paywall:
        switch Holiday.current {
        case .helloween:
          return Destination.toPaywall.rawValue
        case .christmas:
          return Destination.toChristmasPaywall.rawValue
        case .none:
          return Destination.toPaywall.rawValue
        }
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .locales(let handler): return LocalesViewModel(onSelect: handler)
      case .paywall(let handlers): return PaywallViewModel(subscription: Subscription.currentGroup.main ,handlers: handlers)
      }
    }
  }
  
  func navigate(to segue: Segue) {
    _controller.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
  }
}

extension ImportController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier,
            let destination = Destination(rawValue: identifier),
              let vModel = sender else { return }
    
    switch destination {
    case .toLocalePicker:
      if let controller = destination.destinationController(for: segue) as? LocalesController {
        controller.viewModel = vModel as? LocalesViewModel
      }
    case .toPaywall, .toChristmasPaywall:
      if let controller = destination.destinationController(for: segue) as? PaywallController {
        controller.viewModel = vModel as? PaywallViewModel
      }
    }
  }
}


