//
//  DoublePaywall+MainExtesions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 03.07.2022.
//

import Foundation
import UIKit

extension DoublePaywallController: URLPresenter {
  @IBAction func tosPressed() {
    self.open(link: .tos)
  }
  
  @IBAction func privacyPressed() {
    self.open(link: .privacy)
  }
}
