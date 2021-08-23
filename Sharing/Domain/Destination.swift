//
//  Destination.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 17.05.2021.
//

import Foundation

enum Destination: String {
  case toLocalePicker = "toLocalePicker"
  
  func destinationController(for segue: UIStoryboardSegue) -> UIViewController? {
    switch self {
    case .toLocalePicker:
      return segue.destination as? LocalesController
    }
  }
}
