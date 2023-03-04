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

extension UILabel {
  private func _gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return UIColor(patternImage: image!)
  }

  private func _getGradientLayer(bounds : CGRect) -> CAGradientLayer{
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    gradient.colors = [UIColor(hexString: "#005BBB"),
                       UIColor(hexString: "#FFD500")].map(\.cgColor)
    gradient.startPoint = CGPoint(x: 0.5, y: 0)
    gradient.endPoint = CGPoint(x: 0.5, y: 1)
    return gradient
  }
  
  func makeInUAColors() {
    let gradient = _getGradientLayer(bounds: bounds)
    textColor = _gradientColor(bounds: bounds, gradientLayer: gradient)
  }
}
