//
//  ImportControllerRouter.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 17.05.2021.
//

import Foundation

class ImportControllerRouter {
  
  private let _controller: ImportController
  required init(controller: ImportController) {
    self._controller = controller
  }
  
  enum Segue {
    case locales(LocalePickerHandler)
    
    var identifier: String {
      switch self {
      case .locales: return Destination.toLocalePicker.rawValue
      }
    }
    
    var senderVM: Any? {
      switch self {
      case .locales(let handler): return LocalesViewModel(onSelect: handler)
      }
    }
  }
  
  func navigate(to segue: Segue) {
    _controller.performSegue(withIdentifier: segue.identifier, sender: segue.senderVM)
  }
}

extension ImportController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let identifier = segue.identifier,
            let destination = Destination(rawValue: identifier),
              let vModel = sender else { return }
    
    switch destination {
    case .toLocalePicker:
      if let controller = destination.destinationController(for: segue) as? LocalesController {
        controller.viewModel = vModel as? LocalesViewModel
      }
    }
  }
}


