//
//  HolidayAffected.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 18.11.2021.
//

import Foundation
import UIKit

protocol HolidayAffected where Self: UIViewController {
  func setupHolidayBackgound()
}

enum Holiday {
  case helloween
  case christmas
  case none
  
  static var current: Holiday {
    switch Date() {
    case Date.christmassRange:
      return .christmas
    case Date.helloweenRange:
      return .helloween
    default:
      return .none
    }
  }
}

extension HolidayAffected {
  func setupHolidayBackgound() {

    view.backgroundColor = .systemBackground
    let backView = UIView(frame: view.bounds)

    switch Holiday.current {
    case .helloween:
      backView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "christmas-pattern")).withAlphaComponent(0.05)
    case .christmas:
      backView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "christmas-pattern")).withAlphaComponent(0.05)
    case .none:
      backView.backgroundColor = .tertiarySystemFill
    }
    
    view.addSubview(backView)
    view.sendSubviewToBack(backView)
  }
}
