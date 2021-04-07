//
//  LibraryRouter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

class LibraryRouter {
  
  private let _controller: LibraryController
  required init(controller: LibraryController) {
    self._controller = controller
  }
  
  enum Segue {
    case newDoc
    case preview(Document)
    case paywall(Subscription, PaywallHandlers)
    
    var identifier: String {
      switch self {
      case .newDoc: return Destination.toNewDocument.rawValue
      case .preview: return Destination.toDocPreview.rawValue
      case .paywall: return Destination.toPaywall.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .newDoc: return NewDocumentViewModel()
      case .preview(let doc): return DocumentPreviewViewModel(document: doc, isNew: false)
      case .paywall(let subscription, let handlers): return PaywallViewModel(subscription: subscription, handlers: handlers)
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



