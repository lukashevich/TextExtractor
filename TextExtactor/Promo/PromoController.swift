//
//  PromoController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 27.05.2022.
//

import Foundation
import UIKit

final class PromoController: UIViewController, ParalaxBackgrounded {
    
  @IBOutlet private weak var resultIcon: UIImageView!

  @IBOutlet private weak var number_1: UITextField!
  @IBOutlet private weak var number_2: UITextField!
  @IBOutlet private weak var number_3: UITextField!
  @IBOutlet private weak var number_4: UITextField!
  @IBOutlet private weak var number_5: UITextField!
  @IBOutlet private weak var number_6: UITextField!

  private var inputs: [String?] {
    [number_1, number_2, number_3, number_4, number_5, number_6].map(\.?.text)
  }
  var viewModel: PromoViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    number_1.becomeFirstResponder()
    
    viewModel.resultHandler = { [unowned self] in
      switch $0 {
      case .success:
        TapticHelper.strong()
        resultIcon.isHidden = false
        resultIcon.image = UIImage(systemName: "checkmark.circle")
        resultIcon.tintColor = .accentColor
        view.endEditing(true)
        viewModel.markUserAsPromoted()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [unowned self] in
          dismiss(animated: true)
        })
      case .fail:
        TapticHelper.triple()
        resultIcon.isHidden = false
        resultIcon.image = UIImage(systemName: "multiply.circle")
        resultIcon.tintColor = .systemRed
      }
    }
  }
}

extension PromoController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    switch textField {
    case number_1:
      textField.text = string
      number_2.becomeFirstResponder()
    case number_2:
      textField.text = string
      number_3.becomeFirstResponder()
    case number_3:
      textField.text = string
      number_4.becomeFirstResponder()
    case number_4:
      textField.text = string
      number_5.becomeFirstResponder()
    case number_5:
      textField.text = string
      number_6.becomeFirstResponder()
    case number_6:
      textField.text = ""
    default: break
    }
    return true
  }
  
  func textFieldDidChangeSelection(_ textField: UITextField) {
    viewModel.checkPromo(inputs)
  }
}
