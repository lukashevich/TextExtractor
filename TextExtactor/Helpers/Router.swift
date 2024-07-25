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
  case toPresentation = "toPresentation"
  
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
    case .toExportedDoc:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? ExportedDocPreviewController
    case .toDateStylePicker:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? DateStylePicker
    case .toPresentation:
      let navigation = segue.destination as? UINavigationController
      return navigation?.viewControllers.first as? PresentationController
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
    case .toPresentation: return "toPresentation"
    case .toDoublePaywall: return "toDoublePaywall"
    }
  }
}
