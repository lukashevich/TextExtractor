//
//  PresentationPresenter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.08.2021.
//
import UIKit

struct PresentationPresenter {
  static var presented: Bool { UserDefaults.standard.presentationShowed }
  
  static func startPresentation() {
    UserDefaults.standard.presentationShowed = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
      UIApplication.rootController?.showPresentation()
    }
  }
}

private extension UserDefaults {
  var presentationShowed: Bool {
    get { UserDefaults.standard.bool(forKey: #function) }
    set { UserDefaults.standard.set(newValue, forKey: #function) }
  }
}
