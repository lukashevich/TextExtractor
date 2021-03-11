//
//  RootTabController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import UIKit

struct Destination {
  static let toDocPreview = "toDocumentPreview"
  static let toPaywall = "toPaywall"
}

final class RootTabController: UITabBarController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Destination.toDocPreview,
       let navigation = segue.destination as? UINavigationController,
       let controller = navigation.viewControllers.first as? DocumentPreviewController, let doc = sender as? Document {
      controller.viewModel = DocumentPreviewViewModel(document: doc)
    } else if segue.identifier == Destination.toPaywall,
              let paywall = segue.destination as?  PaywallController,
                  let handlers = sender as? PaywallHandlers {
      paywall.viewModel = PaywallViewModel(handlers: handlers)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      self._showPaywall()
//    }
  }
  
  private func _showPaywall() {
    self.performSegue(withIdentifier: "toPaywall", sender: nil)
  }
}
