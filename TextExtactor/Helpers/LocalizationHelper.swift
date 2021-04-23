//
//  LocalizationHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.03.2021.
//

import UIKit

protocol Localizable {
  var localized: String { get }
}

extension String: Localizable {
  var localized: String {
    return NSLocalizedString(self, comment: "")
  }
  
  func localized(_ arguments: [CVarArg]) -> String {
    return String(format: self.localized, locale: nil, arguments: arguments)
  }
}

protocol XIBLocalizable {
  var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      
      text = string.localized
    }
  }
}
extension UIButton: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      setTitle(string.localized, for: .normal)
    }
  }
}

extension UITextView: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      text = string.localized
    }
  }
}

extension UITextField: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      placeholder = string.localized
    }
  }
}

extension UITabBarItem: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      title = string.localized
    }
  }
}

extension UISearchBar: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      placeholder = string.localized
    }
  }
}

extension UIViewController: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      title = string.localized
    }
  }
}

extension UINavigationItem: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      title = string.localized
    }
  }
}

extension UIBarButtonItem: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      guard let string = key, string != string.localized else { return }
      title = string.localized
    }
  }
}
