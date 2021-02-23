//
//  UITabBarController+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import UIKit

enum Tab: Int {
  case extract
  case recents
}

extension UITabBarController {
  func select(_ tab: Tab) {
    selectedIndex = tab.rawValue
  }
}
