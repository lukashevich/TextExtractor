//
//  Destination.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 17.05.2021.
//

import Foundation

enum Destination: String {
  case toLocalePicker
  case toPaywall
  case toDoublePaywall
  case toChristmasPaywall
    
  func destinationController(for segue: UIStoryboardSegue) -> UIViewController? {
    switch self {
    case .toLocalePicker:
      return segue.destination as? LocalesController
    case .toPaywall, .toChristmasPaywall:
      return segue.destination as? PaywallController
    case .toDoublePaywall:
      return segue.destination as? DoublePaywallController
    }
  }
}
