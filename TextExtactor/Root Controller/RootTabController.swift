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
    }
  }
}

final class RootTabController: UITabBarController {
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
  
  
}
