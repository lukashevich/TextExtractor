//
//  TabBared.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 19.02.2021.
//

import Foundation
import UIKit

protocol TabBared where Self: UIViewController {
  func appeared()
}

extension TabBared {
  func select(tab: Tab) {
    guard let tabBarController = self.tabBarController else {
      return
    }
    tabBarController.select(tab)
  }
  
  func toNewDocument() {
    guard let tabBarController = self.tabBarController else {
      return
    }
    tabBarController.performSegue(withIdentifier: Destination.toNewDocument.rawValue, sender: nil)
  }
  
  func toPreview(with doc: Document) {
    guard let tabBarController = self.tabBarController else {
      return
    }
    tabBarController.performSegue(withIdentifier: Destination.toDocPreview.rawValue, sender: doc)
  }
}
