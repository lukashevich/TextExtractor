//
//  ParalaxBackgrounded.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 28.08.2021.
//

import UIKit

protocol ParalaxBackgrounded {}

extension ParalaxBackgrounded where Self: UIViewController {
  func setParalaxBackground(with relativeValue: CGFloat = 64) {
    let _backgroundView = UIView()
    let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    horizontal.minimumRelativeValue = -relativeValue
    horizontal.maximumRelativeValue = relativeValue
    
    let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    vertical.minimumRelativeValue = -relativeValue
    vertical.maximumRelativeValue = relativeValue
    
    let group = UIMotionEffectGroup()
    group.motionEffects = [horizontal, vertical]
        
    view.addSubview(_backgroundView)
    view.sendSubviewToBack(_backgroundView)
    
    _backgroundView.translatesAutoresizingMaskIntoConstraints = false
    let horizontalConstraint = NSLayoutConstraint(item: _backgroundView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
    let verticalConstraint = NSLayoutConstraint(item: _backgroundView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)

    let heightConstraint = NSLayoutConstraint(item: _backgroundView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.2, constant: 0.0)
    let widthConstraint = NSLayoutConstraint(item: _backgroundView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.2, constant: 0.0)

    NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    
    _backgroundView.addMotionEffect(group)
    _backgroundView.alpha = 0.1
    _backgroundView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "icon-pattern"))
  }
}
