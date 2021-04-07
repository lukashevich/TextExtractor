//
//  PaywallController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation
import UIKit

final class PaywallController: UIViewController, URLPresenter, AlertPresenter {
  
  enum PurhcaseState {
    case successfully
    case denied
  }
  
  @IBOutlet private weak var _productPreloader: PreloaderView!
  
  @IBOutlet private weak var _fullPreloader: UIView!
  @IBOutlet private weak var _fullPreloaderActivity: UIActivityIndicatorView!
  
  @IBOutlet private weak var _trialView: UIView!
  @IBOutlet private weak var _trialLabel: UILabel!
  @IBOutlet private weak var _subscribeButton: UIButton!
  
  var viewModel: PaywallViewModel!
  
  private func _showPreloader() {
    self._fullPreloaderActivity.startAnimating()
    self._fullPreloader.showAnimated()
  }
  
  private func _hidePreloader() {
    self._fullPreloader.hideAnimated()
  }
  
  @IBAction func close() {
    self.dismiss(.denied)
  }
  
  @IBAction func subscribePressed() {
    self._showPreloader()
    SubscriptionHelper.subscribe(subscription: viewModel.subscription, resultHandler: { result in
      switch result {
      case .success:
        UserDefaults.standard.userSubscribed = true
        self.dismiss(.successfully)
      case .error(let error):
        self.showAlert(.error(error))
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
            self.dismiss(.successfully)
          case .expired:
            self.showAlert(.subscriptionExpired)
            UserDefaults.standard.userSubscribed = false
            self._hidePreloader()
          case .notPurchased:
            self.showAlert(.subscriptionNotPurchased)
            UserDefaults.standard.userSubscribed = false
            self._hidePreloader()
            break
          }
        }
      case .error:
        self.showAlert(.somethingWentWrong)
        self._hidePreloader()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SubscriptionHelper.retrieveInfo(subscription: viewModel.subscription) { product in
      guard let product = product, let period = product.period else { return }
      
      self._productPreloader.isHidden = true
      
      let priceText = self._price(from: product.price, locale: product.priceLocale)
      let subscriptionDuration = period.unit.stringValue
      self._subscribeButton.setTitle("PAYWALL_CTA".localized([priceText, subscriptionDuration]), for: .normal)
      guard let intro = product.intro else {
        self._trialView.isHidden = true
        return
      }
      self._trialLabel.text = "Starts with a \(intro.numberOfUnits)-\(intro.unit.stringValue) free trial"
    }
  }
  
  func dismiss(_ state: PurhcaseState) {
    switch state {
    case .successfully:
      self.dismiss(animated: true, completion: self.viewModel.successHandler)
    case .denied:
      self.dismiss(animated: true, completion: self.viewModel.denyHandler)
    }
  }
  
  private func _price(from value: Double, locale: Locale) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .currency
    return formatter.string(from: value as NSNumber) ?? ""
  }
  
  @IBAction func tosPressed() {
    self.open(link: .tos)
  }
  
  @IBAction func privacyPressed() {
    self.open(link: .privacy)
  }
}
