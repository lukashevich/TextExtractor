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

extension UIButton {
  func pulsate() {
    let pulse = CASpringAnimation(keyPath: "transform.scale")
    pulse.duration = 0.2
    pulse.fromValue = 1.0
    pulse.toValue = 1.1
    pulse.autoreverses = true
    pulse.repeatCount = 4
    pulse.initialVelocity = 0.5
    pulse.damping = 1.0

    TapticHelper.strong()
    
    layer.add(pulse, forKey: "pulse")
  }
  
  func flash() {
    let flash = CABasicAnimation(keyPath: "opacity")
    flash.duration = 0.2
    flash.fromValue = 1
    flash.toValue = 0.1
    flash.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    flash.autoreverses = true
    flash.repeatCount = 3
    
    layer.add(flash, forKey: nil)
  }
  
  
  func shake() {
    let shake = CABasicAnimation(keyPath: "position")
    shake.duration = 0.075
    shake.repeatCount = 3
    shake.autoreverses = true
    
    let fromPoint = CGPoint(x: center.x - 7, y: center.y)
    let fromValue = NSValue(cgPoint: fromPoint)
    
    let toPoint = CGPoint(x: center.x + 7, y: center.y)
    let toValue = NSValue(cgPoint: toPoint)
    
    shake.fromValue = fromValue
    shake.toValue = toValue
    
    layer.add(shake, forKey: "position")
  }
}
