//
//  TabBared.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 19.02.2021.
//

import Foundation
import UIKit

protocol TabBared where Self: UIViewController {
  func hideTabbarSeparator()
  func showTabbarSeparator()
}
extension TabBared {
  func hideTabbarSeparator() {
    guard let tabBar = self.tabBarController?.tabBar else {
      return
    }
    
    let appearance = tabBar.standardAppearance
    appearance.shadowImage = nil
    appearance.shadowColor = nil
    appearance.backgroundColor = .systemBackground
    tabBar.standardAppearance = appearance
  }
  
  func select(tab: Tab) {
    guard let tabBarController = self.tabBarController else {
      return
    }
    tabBarController.select(tab)
  }
  
  func toPreview(with doc: Document) {
    guard let tabBarController = self.tabBarController else {
      return
    }
    tabBarController.performSegue(withIdentifier: Destination.toDocPreview, sender: doc)
  }
  
  func showPaywall(handlers: PaywallHandlers? = nil) {
    guard let tabBarController = self.tabBarController as? RootTabController  else {
      return
    }
    tabBarController.performSegue(withIdentifier: Destination.toPaywall, sender: handlers)
  }
  
  func showTabbarSeparator() {
    guard let tabBar = self.tabBarController?.tabBar else {
      return
    }
    
    let appearance = tabBar.standardAppearance
    appearance.shadowColor = .separator
    appearance.backgroundColor = .systemBackground
    tabBar.standardAppearance = appearance
  }
}
