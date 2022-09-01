//
//  Router.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 27.05.2021.
//

import UIKit

private let _initialKey = "Initial"

enum Destination: String {
  case toNewDocument = "toNewDocument"
  case toDocPreview = "toDocumentPreview"
  case toPaywall = "toPaywall"
  case toChristmasPaywall = "toChristmasPaywall"
  case toLocalePicker = "toLocalePicker"
  case toExportedDoc = "toExportedDoc"
  case toDoublePaywall = "toDoublePaywall"
  case toDateStylePicker = "toDateStylePicker"
  case toFeedback = "toFeedback"
  case toPresentation = "toPresentation"
  case toPromo = "toPromo"

//  var destination: UIViewController {
////
////    let navigation = segue.destination as? UINavigationController
////      navigation?.viewControllers.first as? ExportedDocPreviewController
//
////    let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
////    return storyboard.instantiateViewController(withIdentifier: _initialKey)
//  }
  
  func destinationController(for segue: UIStoryboardSegue) -> UIViewController? {
    switch self {
    case .toNewDocument:
      return segue.destination as? NewDocumentController
    case .toDocPreview:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? DocumentPreviewController
    case .toPaywall, .toChristmasPaywall:
      return segue.destination as? PaywallController
    case .toDoublePaywall:
      return segue.destination as? DoublePaywallController
    case .toLocalePicker:
      return segue.destination as? LocalesController
    case .toFeedback:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? FeedbackController
    case .toExportedDoc:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? ExportedDocPreviewController
    case .toDateStylePicker:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? DateStylePicker
    case .toPresentation:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? PresentationController
    case .toPromo:
      return segue.destination as? PromoController
    }
  }
  
  var storyboardName: String {
    switch self {
    case .toNewDocument: return "NewDocument"
    case .toDocPreview: return "DocumentPreview"
    case .toPaywall, .toChristmasPaywall: return "Paywall"
    case .toLocalePicker: return "Locales"
    case .toExportedDoc: return "ExportedDocPreview"
    case .toDateStylePicker: return "DateStylePicker"
    case .toFeedback: return "Feedback"
    case .toPresentation: return "toPresentation"
    case .toPromo: return "toPromo"
    case .toDoublePaywall: return "toDoublePaywall"
    }
  }
}
