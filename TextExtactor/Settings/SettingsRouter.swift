//
//  SettingsRouter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

class SettingsRouter {
  
  private let _controller: SettingsController
  required init(controller: SettingsController) {
    self._controller = controller
  }
  
  enum Segue {
    case paywall(PaywallHandlers?)
    case toPresentation
    case toExportedDoc
    case toFeedback
    case toPromo
    
    var identifier: String {
      switch self {
      case .paywall: return Destination.toPaywall.rawValue
      case .toExportedDoc: return Destination.toExportedDoc.rawValue
      case .toFeedback: return Destination.toFeedback.rawValue
      case .toPresentation: return Destination.toPresentation.rawValue
      case .toPromo: return Destination.toPromo.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .paywall(let handlers): return PaywallViewModel(subscription: Subscription.currentGroup.main ,handlers: handlers)
      case .toExportedDoc: return ExportedDocPreviewViewModel()
      case .toFeedback: return FeedbackViewModel()
      case .toPresentation: return PresentationViewModel()
      case .toPromo: return PromoViewModel()
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

