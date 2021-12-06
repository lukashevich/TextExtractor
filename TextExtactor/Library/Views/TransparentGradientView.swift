//
//  TransparentGradientView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 25.03.2021.
//

import UIKit

@IBDesignable
final class TransparentGradientView: UIView {
  var contentView:UIView?
  
  private let _gradientMaskLayer = CAGradientLayer()
  
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
    
    let backColor = contentView?.backgroundColor?.cgColor
    
    _gradientMaskLayer.frame = contentView?.bounds ?? .zero
    _gradientMaskLayer.colors = [UIColor.clear.cgColor, backColor]
    _gradientMaskLayer.locations = [0, 0.5, 1]
    contentView?.layer.mask = _gradientMaskLayer
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "TransparentGradientView", bundle: bundle)
    return nib.instantiate(
      withOwner: self,
      options: nil).first as? UIView
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    _gradientMaskLayer.frame = contentView?.bounds ?? .zero
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    xibSetup()
    contentView?.prepareForInterfaceBuilder()
  }
}
