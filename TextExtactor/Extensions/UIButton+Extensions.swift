//
//  UIButton+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

@IBDesignable
extension UIButton {
  @IBInspectable
  var smallCaps: Bool {
    set (smallCaps) {
      switch smallCaps {
      case true:
        titleLabel?.font = titleLabel?.font.withSmallCaps
      case false: break
      }
    }
    
    get {
      return false
    }
  }
}
