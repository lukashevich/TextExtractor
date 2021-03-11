//
//  UIBarButtonItem+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 24.02.2021.
//

import UIKit

extension UIBarButtonItem {
  @IBInspectable var semibold: Bool {
    get { return false }
    set {
      let saveButtonFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
      setTitleTextAttributes(saveButtonFontAttribute, for: .normal)
      setTitleTextAttributes(saveButtonFontAttribute, for: .disabled)
    }
  }
}
