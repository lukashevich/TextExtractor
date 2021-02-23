//
//  UITextView+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit

extension UITextView {
  func typeOn(string: String) {
    let characterArray = Array(string)
    var characterIndex = 0
    Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
      if characterArray[characterIndex] != "$" {
        while characterArray[characterIndex] == " " {
          self.text.append(" ")
          characterIndex += 1
          if characterIndex == characterArray.count {
            timer.invalidate()
            return
          }
        }
        self.text.append(characterArray[characterIndex])
      }
      characterIndex += 1
      if characterIndex == characterArray.count {
        timer.invalidate()
      }
    }
  }
}

