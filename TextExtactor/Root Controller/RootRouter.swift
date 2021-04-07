//
//  RootRouter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 02.04.2021.
//

import UIKit

class RootRouter {
  
  private let _controller: RootTabController
  required init(controller: RootTabController) {
    self._controller = controller
  }
  
  enum Segue {
    case paywall(Subscription, PaywallHandlers)
    case exportDocPreview
    
    var identifier: String {
      switch self {
      case .paywall: return Destination.toPaywall.rawValue
      case .exportDocPreview: return Destination.toExportedDoc.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
        case .paywall(let subscription, let handlers): return PaywallViewModel(subscription: subscription, handlers: handlers)
        case .exportDocPreview: return ExportedDocPreviewViewModel()
      }
    }
  }
  
  func navigate(to segue: Segue) {
    _controller.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
  }
}

extension RootTabController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier,
            let destination = Destination(rawValue: identifier),
              let vModel = sender else { return }
    
    switch destination {
    case .toDocPreview:
      if let controller = destination.destinationController(for: segue) as? DocumentPreviewController {
        controller.viewModel = vModel as? DocumentPreviewViewModel
      }
    case .toNewDocument:
      if let controller = destination.destinationController(for: segue) as? NewDocumentController {
        controller.viewModel = vModel as? NewDocumentViewModel
      }
    case .toPaywall:
      if let controller = destination.destinationController(for: segue) as? PaywallController {
        controller.viewModel = vModel as? PaywallViewModel
      }
    case .toExportedDoc:
      if let controller = destination.destinationController(for: segue) as? ExportedDocPreviewController {
        controller.viewModel = vModel as? ExportedDocPreviewViewModel
      }
    default: break
    }
  }
}


