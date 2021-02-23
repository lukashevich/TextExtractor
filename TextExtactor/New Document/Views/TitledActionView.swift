//
//  TitledActionView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 19.02.2021.
//

import Foundation
import UIKit

protocol TitledActionViewDelegate {
  func action()
}

@IBDesignable
final class TitledActionView: UIControl {
  
  @IBOutlet private weak var _titleLabel: UILabel!
  @IBOutlet private weak var _subtitleLabel: UILabel!

  var contentView:UIView?
  
  var title: String = "" {
    didSet {
      _titleLabel.isHidden = title.isEmpty
      _titleLabel.text = title
    }
  }
  
  var subtitle: String = "" {
    didSet {
      _subtitleLabel.isHidden = subtitle.isEmpty
      _subtitleLabel.text = subtitle
    }
  }
  
  var delegate: TitledActionViewDelegate?
  
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

  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "TitledActionView", bundle: bundle)
    return nib.instantiate(
      withOwner: self,
      options: nil).first as? UIView
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    xibSetup()
    contentView?.prepareForInterfaceBuilder()
  }
  
 
  @IBAction func action(_ sender: Any) {
    sendActions(for: .touchUpInside)
  }
}
