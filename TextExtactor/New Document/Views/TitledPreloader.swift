//
//  TitledPreloader.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.03.2021.
//

import UIKit

@IBDesignable
final class TitledPreloader: UIView {
  var contentView:UIView?
  
  @IBOutlet weak var preloader: UIActivityIndicatorView!

  override func awakeFromNib() {
    super.awakeFromNib()
    xibSetup()
  }
  
  func xibSetup() {
    guard let view = loadViewFromNib() else { return }
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
    view.cornerRadius = bounds.size.height / 2
    contentView = view
    preloader.startAnimating()
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "TitledPreloader", bundle: bundle)
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
