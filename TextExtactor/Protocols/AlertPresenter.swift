//
//  AlertPresenter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 27.03.2021.
//

import UIKit

protocol AlertPresenter { }

enum AlertType {
  case subscriptionExpired
  case subscriptionNotPurchased
  case somethingWentWrong
  case error(Error)
  
  var info:(title: String, message: String) {
    switch self {
    case .subscriptionExpired:
      return (title: "Sorry", message: "Your subscription is Expired")
    case .subscriptionNotPurchased:
      return (title: "Sorry", message: "You don't have any active subscriptions")
    case .somethingWentWrong:
      return (title: "Sorry", message: "Something went wrong")
    case .error(let error):
      return (title: "Error", message: error.localizedDescription)
    }
  }
}

extension AlertPresenter where Self: UIViewController {
  func showAlert(_ type: AlertType) {
    let info = type.info
    let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
    alert.view.tintColor = .accentColor
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
 }
