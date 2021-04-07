//
//  DocSourceIconView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 25.03.2021.
//

import UIKit

@IBDesignable
final class DocSourceIconView: UIView {
  var contentView: UIView?
  
  @IBOutlet private weak var icon: UIImageView?

  var docType = DocumentSource.video {
    didSet {
      switch docType {
      case .video:
        icon?.image = UIImage.videoIcon
        contentView?.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
      case .audio:
        icon?.image = UIImage.audioIcon
        contentView?.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.9)
      case .picture:
        icon?.image = UIImage.pictureIcon
        contentView?.backgroundColor = .systemTeal
      }
    }
  }
  
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
    let nib = UINib(nibName: "DocSourceIconView", bundle: bundle)
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

extension UIImage {
  static var videoIcon: UIImage {
    UIImage(systemName: "play") ?? UIImage()
  }
  
  static var audioIcon: UIImage {
    UIImage(systemName: "waveform") ?? UIImage()
  }
  
  static var pictureIcon: UIImage {
    UIImage(systemName: "photo") ?? UIImage()
  }
}
