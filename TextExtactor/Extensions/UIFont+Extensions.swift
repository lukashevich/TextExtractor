//
//  UIFont+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

extension UIFont {
  var withSmallCaps: UIFont {
    let upperCaseFeature = [
      UIFontDescriptor.FeatureKey.featureIdentifier : kUpperCaseType,
      UIFontDescriptor.FeatureKey.typeIdentifier : kUpperCaseSmallCapsSelector
    ]
    let lowerCaseFeature = [
      UIFontDescriptor.FeatureKey.featureIdentifier : kLowerCaseType,
      UIFontDescriptor.FeatureKey.typeIdentifier : kLowerCaseSmallCapsSelector
    ]
    let features = [upperCaseFeature, lowerCaseFeature]
    let smallCapsDescriptor = self.fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.featureSettings : features])
    return UIFont(descriptor: smallCapsDescriptor, size: pointSize)
  }
}
