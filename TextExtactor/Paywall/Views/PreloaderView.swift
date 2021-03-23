//
//  PreloaderView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 17.03.2021.
//

import UIKit

@IBDesignable
final class PreloaderView: UIView {
  
  @IBOutlet private weak var _preloader: UIActivityIndicatorView!

  var contentView:UIView?
    
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
    self._preloader.startAnimating()
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "PreloaderView", bundle: bundle)
    return nib.instantiate(
      withOwner: self,
      options: nil).first as? UIView
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    xibSetup()
    contentView?.prepareForInterfaceBuilder()
  }
}
