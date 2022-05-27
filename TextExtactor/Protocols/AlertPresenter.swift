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
  case cantTranscribe
  case wrongEmail
  case emptyFeedback
  case error(Error)
  
  var info:(title: String, message: String) {
    switch self {
    case .subscriptionExpired:
      return (title: "Sorry", message: "Your subscription is Expired")
    case .subscriptionNotPurchased:
      return (title: "Sorry", message: "You don't have any active subscriptions")
    case .somethingWentWrong:
      return (title: "Sorry", message: "Something went wrong")
    case .emptyFeedback:
      return (title: "Sorry", message: "There are nothing to send. \nPlease leave a brief feedback for us")
    case .wrongEmail:
      return (title: "Invalid feedback email", message: "Please make sure your email validation, so we can leave feedback to you soon...")
    case .error(let error):
      return (title: "Error", message: error.localizedDescription)
    case .cantTranscribe:
      return (title: "Sorry", message: "We couldn't transcribe this file. Please make sure your transcribing language is correct")
    }
  }
}

extension AlertPresenter where Self: UIViewController {
  func showAlert(_ type: AlertType, handler: ((UIAlertAction) -> Void)? = nil) {
    let info = type.info
    let alert = UIAlertController(title: info.title, message: info.message, preferredStyle: .alert)
    alert.view.tintColor = .accentColor
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
    self.present(alert, animated: true, completion: nil)
  }
 }
