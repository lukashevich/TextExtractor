//
//  PaywallSmallView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.03.2021.
//

import UIKit


final class PaywallCell: UITableViewCell {
  
  @IBOutlet weak var _fullPreloader: UIView!
  @IBOutlet weak var _fullPreloaderActivity: UIActivityIndicatorView!
  
  @IBOutlet weak var _trialLabel: UILabel!
  @IBOutlet weak var _subscribeButton: UIButton!

  var subscriptionHandler: (()->Void)?
  var problemHandler: ((Error)->Void)?

  override func didMoveToSuperview() {
    SubscriptionHelper.retrieveInfo(subscription: Subscription.currentGroup.main) { product in
      guard let product = product, let period = product.period else { return }
      let priceText = self._price(from: product.price, locale: product.priceLocale)
      let subscriptionDuration = period.unit.stringValue
      self._subscribeButton.setTitle("PAYWALL_CTA".localized([priceText, subscriptionDuration]), for: .normal)

      guard let intro = product.intro else {
        self._trialLabel.isHidden = true
        return
      }

      self._trialLabel.text = "Starts with a \(intro.numberOfUnits)-\(intro.unit.stringValue) free trial"
    }
  }

  private func _price(from value: Double, locale: Locale) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .currency
    return formatter.string(from: value as NSNumber) ?? ""
  }
 
  @IBAction func subscribePressed() {
    self._showPreloader()
    SubscriptionHelper.subscribe(resultHandler: { result in
        switch result {
        case .success:
          UserDefaults.standard.userSubscribed = true
          self.subscriptionHandler?()
        case .error(let error):
          self.problemHandler?(error)
          self._hidePreloader()
      }
    })
  }
  
  @IBAction func restore() {
    self._showPreloader()
    SubscriptionHelper.restore { result in
      switch result {
      case .success(let receipt):
        let purchaseResult = SubscriptionHelper.verifySubscriptions(receipt)
        DispatchQueue.main.async {
          switch purchaseResult {
          case .purchased:
            UserDefaults.standard.userSubscribed = true
            self.subscriptionHandler?()
          case .expired:
            UserDefaults.standard.userSubscribed = false
            self._hidePreloader()
          case .notPurchased:
            UserDefaults.standard.userSubscribed = false
            self._hidePreloader()
            break
          }
        }
      case .error(let error):
        self.problemHandler?(error)
        self._hidePreloader()
      }
    }
  }
  
  private func _showPreloader() {
    self._fullPreloaderActivity.startAnimating()
    self._fullPreloader.showAnimated()
  }
  
  private func _hidePreloader() {
    self._fullPreloader.hideAnimated()
  }
}
