//
//  SubcriptionPriceView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 01.07.2022.
//

import Foundation
import UIKit
import StoreKit

@IBDesignable
final class SubscriptionPriceView: UIView {
  
  @IBOutlet private weak var _priceLabel: UILabel!
  @IBOutlet private weak var _periodLabel: UILabel!
  @IBOutlet private weak var _descriptionLabel: UILabel!

  var contentView:UIView?
  var selectionHandler: (()->Void)?
  
  private var _isSelected: Bool = false
  
  override func awakeFromNib() {
    super.awakeFromNib()
    xibSetup()
  }
  
  func xibSetup() {
    guard let view = loadViewFromNib() else { return }
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
    contentView = view
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
    contentView?.addGestureRecognizer(tap)
  }
  
  @objc func tap() {
    select()
    selectionHandler?()
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "SubscriptionPriceView", bundle: bundle)
    return nib.instantiate(
      withOwner: self,
      options: nil).first as? UIView
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    xibSetup()
    contentView?.prepareForInterfaceBuilder()
  }
  
  func setProduct(_ product: ProductInfo?) {
    guard let product = product, let period = product.period else {
      contentView?.isHidden = true
      return
    }
    
    _priceLabel.text = _price(from: product.price, locale: product.priceLocale)
    
    switch period.unit {
    case .year:
      _periodLabel.text = "Billed annualy"
      _descriptionLabel.text =  String(format: "%@ per month", _price(from: product.price / 12, locale: product.priceLocale))
    case .month:
      _periodLabel.text = "Billed monthly"
      _descriptionLabel.text = String(format: "%@ per year", _price(from: product.price * 12, locale: product.priceLocale))
   
    case .week:
      _periodLabel.text = "Billed weekly"
      _descriptionLabel.text = String(format: "%@ per year", _price(from: product.price * 52, locale: product.priceLocale))
  
    case .day where period.numberOfUnits == 7:
      _periodLabel.text = "Billed weekly"
      _descriptionLabel.text = String(format: "%@ per year", _price(from: product.price * 52, locale: product.priceLocale))

    case .day:
      _periodLabel.text = "Billed dayly"
      _descriptionLabel.text = String(format: "%@ per year", _price(from: product.price * 365, locale: product.priceLocale))

    @unknown default:
      _descriptionLabel.text = nil
    }
  }
  
  func select() {
    contentView?.backgroundColor = .accentColor
    _priceLabel.textColor = .white
    _periodLabel.textColor = .white.withAlphaComponent(0.8)
    _descriptionLabel.textColor = .white.withAlphaComponent(0.7)
  }
  
  func deselect() {
    contentView?.backgroundColor = .clear
    _priceLabel.textColor = .accentColor
    _periodLabel.textColor = .label
    _descriptionLabel.textColor = .secondaryLabel
  }
  
  private func _price(from value: Double, locale: Locale) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .currency
    return formatter.string(from: value as NSNumber) ?? ""
  }
  
  private func _description(from value: Double, locale: Locale) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .currency
    return String(format: "%@ per month", formatter.string(from: value/12 as NSNumber) ?? "")
  }
}

private extension SKProduct.PeriodUnit {
  var duration: String {
    switch self {
    case .day: return "Billed dayly"
    case .week: return "Billed weekly"
    case .month: return "Billed monthly"
    case .year: return "Billed annualy"
    @unknown default: return ""
    }
  }
}
