//
//  RootTabController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import UIKit

enum Destination: String {
  case toNewDocument = "toNewDocument"
  case toDocPreview = "toDocumentPreview"
  case toPaywall = "toPaywall"
  case toLocalePicker = "toLocalePicker"
  case toExportedDoc = "toExportedDoc"
  case toDateStylePicker = "toDateStylePicker"
  
  func destinationController(for segue: UIStoryboardSegue) -> UIViewController? {
    switch self {
    case .toNewDocument:
      return segue.destination as? NewDocumentController
    case .toDocPreview:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? DocumentPreviewController
    case .toPaywall:
      return segue.destination as? PaywallController
    case .toLocalePicker:
      return segue.destination as? LocalesController
    case .toExportedDoc:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? ExportedDocPreviewController
    case .toDateStylePicker:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? DateStylePicker
    }
  }
}

final class RootTabController: UITabBarController {
  
  private lazy var _router = RootRouter(controller: self)

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
  
  func showPaywall() {
    _router.navigate(to: .paywall(.monthlyTrial, .empty))
  }
}
