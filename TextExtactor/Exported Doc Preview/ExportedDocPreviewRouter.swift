//
//  ExportedDocPreviewRouter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 07.04.2021.
//

import UIKit

final class ExportedDocPreviewRouter {
  
  private let _controller: ExportedDocPreviewController
  required init(controller: ExportedDocPreviewController) {
    self._controller = controller
  }
  
  enum Segue {
    case toDateStylePicker(DateStylePicker.DismissHandler?)
  
    var identifier: String {
      switch self {
      case .toDateStylePicker: return Destination.toDateStylePicker.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .toDateStylePicker(let handler): return DateStylePickerViewModel(dismissHandler: handler)
      }
    }
  }
  
  func navigate(to segue: Segue) {
    _controller.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
  }
}

extension ExportedDocPreviewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier,
            let destination = Destination(rawValue: identifier),
              let vModel = sender else { return }
    
    switch destination {
    case .toDateStylePicker:
      if let controller = destination.destinationController(for: segue) as? DateStylePicker {
        controller.viewModel = vModel as? DateStylePickerViewModel
      }
    default: break
    }
  }
}
