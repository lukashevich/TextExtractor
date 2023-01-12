//
//  DoublePaywallController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation
import UIKit

final class DoublePaywallController: UIViewController, AlertPresenter, ParalaxBackgrounded, Snowy {
  
  enum PurhcaseState {
    case successfully
    case denied
  }
  
  @IBOutlet private weak var _title: UILabel!

  @IBOutlet private weak var _productPreloader: PreloaderView!
  
  @IBOutlet private weak var _fullPreloader: UIView!
  @IBOutlet private weak var _fullPreloaderActivity: UIActivityIndicatorView!
  
  @IBOutlet private weak var _trialView: UIView!
  @IBOutlet private weak var _trialLabel: UILabel!
  @IBOutlet private weak var _subscribeButton: UIButton!
  @IBOutlet private weak var _ctaTitle: UILabel!
  @IBOutlet private weak var _ctaSubTitle: UILabel!

  @IBOutlet private weak var _mainSubsriptionView: SubscriptionPriceView!
  @IBOutlet private weak var _secondarySubsriptionView: SubscriptionPriceView!

  var viewModel: DoublePaywallViewModel!
  
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
    
    Analytics.log(DoublePaywallAnalytics.ctaClicked)
    guard let product = _selectedProduct else { return }
    self._showPreloader()
    
    SubscriptionHelper.subscribe(subscription: product, resultHandler: { result in
      switch result {
      case .success:
        Analytics.log(DoublePaywallAnalytics.purchased)

        SubscriptionHelper.handleSubscription(product)
        self.dismiss(.successfully)
      case .error(let error):
        Analytics.log(DoublePaywallAnalytics.purchaseError)

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
  
  private var _selectedProduct: Subscription? {
    didSet {
      _subscribeButton.isEnabled = _selectedProduct != nil
    }
  }
  
  private func _prepareSubcriptionViews() {
    
    _mainSubsriptionView.selectionHandler = { [unowned self] in
      _secondarySubsriptionView.deselect()
      _selectedProduct = viewModel.subscriptions.main
    }
    
    _secondarySubsriptionView.selectionHandler = { [unowned self] in
      _mainSubsriptionView.deselect()
      _selectedProduct = viewModel.subscriptions.secondary
    }
    
    _mainSubsriptionView.tap()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Analytics.log(DoublePaywallAnalytics.shown)

    switch viewModel.source {
    case .main:
      break
    case .extension:
      isModalInPresentation = true
      _subscribeButton.pulsate()
    }
    
    _prepareSubcriptionViews()
    
    _title.makeInUAColors()
    
    switch Holiday.current {
    case .helloween, .none:
      setParalaxBackground()
    case .christmas:
      letItSnow()
    }
    
    _productPreloader.isHidden = true
    
    SubscriptionHelper.retrieveInfo(subscription: viewModel.subscriptions.main, completion: _mainSubsriptionView.setProduct)
    
    SubscriptionHelper.retrieveInfo(subscription: viewModel.subscriptions.secondary, completion: _secondarySubsriptionView.setProduct)
  }
  
  func dismiss(_ state: PurhcaseState) {
    switch state {
    case .successfully:
      self.dismiss(animated: true, completion: self.viewModel.successHandler)
    case .denied:
      self.dismiss(animated: true, completion: self.viewModel.denyHandler)
    }
  }
}

private extension UILabel {
  private func _gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return UIColor(patternImage: image!)
  }

  private func _getGradientLayer(bounds : CGRect) -> CAGradientLayer{
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    gradient.colors = [UIColor(hexString: "#005BBB"),
                       UIColor(hexString: "#FFD500")].map(\.cgColor)
    gradient.startPoint = CGPoint(x: 0.5, y: 0)
    gradient.endPoint = CGPoint(x: 0.5, y: 1)
    return gradient
  }
  
  func makeInUAColors() {
    let gradient = _getGradientLayer(bounds: bounds)
    textColor = _gradientColor(bounds: bounds, gradientLayer: gradient)
  }
}
