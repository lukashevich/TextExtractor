//
//  UIColor+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 16.02.2021.
//

import UIKit.UIColor

extension UIColor {
  static var accentColor: UIColor {
    return UIColor(named: "AccentColor") ?? UIColor.green.withAlphaComponent(0.8)
  }
}
