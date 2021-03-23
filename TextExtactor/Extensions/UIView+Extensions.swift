//
//  UIView+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
  
  @IBInspectable var cornerRadius: CGFloat {
    set (radius) {
      layer.cornerRadius = radius
      layer.masksToBounds = radius > 0
      
      if #available(iOS 13.0, *) {
        layer.cornerCurve = .continuous
      }
    }
    
    get {
      return layer.cornerRadius
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    set (width) {
      layer.borderWidth = width
    }
    
    get {
      return layer.borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor {
    set (color) {
      layer.borderColor = color.cgColor
    }
    
    get {
      guard let color = layer.borderColor else { return .systemBackground }
      return UIColor(cgColor: color)
    }
  }
  
  @IBInspectable var shadow: CGFloat {
    set (shadow) {
      layer.shadowColor = UIColor.quaternarySystemFill.cgColor
      layer.shadowOpacity = 1
      layer.shadowOffset = .zero
      layer.shadowRadius = shadow
    }
    
    get { 0.0 }
  }
  
  func disable(animated:Bool = true) {
    if animated {
      UIView.animate(withDuration: 0.1) {
        self.alpha = 0.3
        self.isUserInteractionEnabled = false
      }
      return
    }
    alpha = 0.3
    isUserInteractionEnabled = false
  }
  
  func enable(animated:Bool = true) {
    isHidden = false
    if animated {
      UIView.animate(withDuration: 0.1) {
        self.alpha = 1.0
        self.isUserInteractionEnabled = true
      }
      return
    }
    alpha = 1.0
    isUserInteractionEnabled = true
  }
  
  func hideAnimated() {
    UIView.animate(withDuration: 0.1) {
      self.alpha = 0.0
    } completion: { _ in
      self.isHidden = true
    }
  }
  
  func showAnimated() {
    self.isHidden = false
    self.alpha = 0.0
    UIView.animate(withDuration: 0.1) {
      self.alpha = 1.0
    }
  }
}


