//
//  ActionView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 24.02.2021.
//

import UIKit

protocol ActionViewDelegate {
  func action()
}

@IBDesignable
final class ActionView: UIControl {
  
  enum State: String {
    case empty = "Empty"
    case save = "Save"
    case cancel = "Cancel"
  }
  
  @IBOutlet private weak var _actionButton: UIButton!

  var contentView:UIView?
  
  var viewState: State = .cancel {
    didSet {
      _actionButton.setTitle(viewState.rawValue, for: .normal)
      _update(for: viewState)
    }
  }
  var delegate: ActionViewDelegate?
  
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
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "ActionView", bundle: bundle)
    return nib.instantiate(
      withOwner: self,
      options: nil).first as? UIView
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    xibSetup()
    contentView?.prepareForInterfaceBuilder()
  }
  
  private func _update(for state: State) {
    self.isUserInteractionEnabled = true
    
    UIView.animate(withDuration: 0.161) {
      switch state {
      case .save:
        self.contentView?.backgroundColor = .accentColor
        self._actionButton.setTitleColor(.white, for: .normal)
        self.contentView?.borderColor = .accentColor
      case .cancel:
        self.contentView?.backgroundColor = .secondaryAccentColor
        self._actionButton.setTitleColor(.accentColor, for: .normal)
        self.contentView?.borderColor = .accentColor
      case .empty:
        self.contentView?.backgroundColor = .clear
        self._actionButton.setTitleColor(.clear, for: .normal)
        self.isUserInteractionEnabled = false
        self.contentView?.borderColor = .clear
      }
    }
  }
 
  @IBAction func action(_ sender: Any) {
    sendActions(for: .touchUpInside)
  }
}
