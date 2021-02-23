//
//  UILabel+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

@IBDesignable
extension UILabel {
  @IBInspectable
  var smallCaps: Bool {
    set (smallCaps) {
      switch smallCaps {
      case true:
        font = font.withSmallCaps
      case false: break
      }
    }
    
    get {
      return false
    }
  }
}

