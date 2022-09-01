//
//  PaywallController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation
import UIKit

final class PaywallController: UIViewController, AlertPresenter, ParalaxBackgrounded, Snowy {
  
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
  @IBOutlet private weak var _ctaTitle: UILabel!
  @IBOutlet private weak var _ctaSubTitle: UILabel!

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
        SubscriptionHelper.handleSubscription(self.viewModel.subscription)
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
    
    switch Holiday.current {
    case .helloween, .none:
      setParalaxBackground()
    case .christmas:
      letItSnow()
    }

    SubscriptionHelper.retrieveInfo(subscription: viewModel.subscription) { [unowned self] product in
      guard let product = product, let period = product.period else { return }
      
      _productPreloader.isHidden = true
      _subscribeButton.pulsate()

      let priceText = self._price(from: product.price, locale: product.priceLocale)
      
      let subscriptionDuration: String
      switch period.unit {
      case .day:
        subscriptionDuration = "WEEK".localized
      default:
        subscriptionDuration = period.unit.stringValue
      }

      switch product.intro {
      case .none:
        _ctaTitle.text = "PAYWALL_CTA".localized([priceText, subscriptionDuration])
        _subscribeButton.setTitle("CONTINUE".localized, for: .normal)
        _ctaSubTitle.isHidden = true
      case .some(let intro):
        _ctaTitle.isHidden = true
        _subscribeButton.setTitle("PAYWALL_STARTS_WITH".localized([intro.numberOfUnits, intro.unit.stringValue]), for: .normal)
        _ctaSubTitle.text = "THEN".localized([priceText, subscriptionDuration])
      }
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
}

extension PaywallController: URLPresenter {
  @IBAction func tosPressed() {
    self.open(link: .tos)
  }
  
  @IBAction func privacyPressed() {
    self.open(link: .privacy)
  }
}
