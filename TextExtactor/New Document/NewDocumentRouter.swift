//
//  NewDocumentRouter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

class NewDocRouter {
  
  private let _controller: NewDocumentController
  required init(controller: NewDocumentController) {
    self._controller = controller
  }
  
  enum Segue {
    case preview(Document)
    case paywall(Subscription, PaywallHandlers)
    case locales(LocalePickerHandler)
    
    var identifier: String {
      switch self {
      case .preview: return Destination.toDocPreview.rawValue
      case .paywall: return Destination.toPaywall.rawValue
      case .locales: return Destination.toLocalePicker.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .preview(let doc): return DocumentPreviewViewModel(document: doc, isNew: true)
      case .paywall(let subscription, let handlers): return PaywallViewModel(subscription: subscription, handlers: handlers)
      case .locales(let handler): return LocalesViewModel(onSelect: handler)
      }
    }
  }
  
  func navigate(to segue: Segue) {
    _controller.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
  }
}

extension NewDocumentController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier,
            let destination = Destination(rawValue: identifier),
              let vModel = sender else { return }
    
    switch destination {
    case .toDocPreview:
      if let controller = destination.destinationController(for: segue) as? DocumentPreviewController {
        controller.viewModel = vModel as? DocumentPreviewViewModel
      }
    case .toPaywall:
      if let controller = destination.destinationController(for: segue) as? PaywallController {
        controller.viewModel = vModel as? PaywallViewModel
      }
    case .toLocalePicker:
      if let controller = destination.destinationController(for: segue) as? LocalesController {
        controller.viewModel = vModel as? LocalesViewModel
      }
    default: break
    }
  }
}


