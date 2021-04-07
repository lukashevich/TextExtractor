//
//  UIApplication+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

extension UIApplication {
  static func dismissToRoot(animated: Bool = true) {
    guard let tabbar = UIApplication.mainWindow?.rootViewController as? RootTabController else { return }
    
    tabbar.dismiss(animated: animated, completion: {
      tabbar.reloadControllers()
    })
  }
}
