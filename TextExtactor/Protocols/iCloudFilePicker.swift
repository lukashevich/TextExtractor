//
//  iCloudFilePicker.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 16.02.2021.
//

import UIKit

protocol iCloudFilePicker: UIDocumentPickerDelegate {
  func pickFileFromCloud()
}

extension iCloudFilePicker where Self: UIViewController {
  func pickFileFromCloud() {
    let picker = UIDocumentPickerViewController(documentTypes: ["public.audiovisual-content"], in: .open)
    picker.delegate = self
    picker.modalPresentationStyle = .formSheet
    self.present(picker, animated: true, completion: nil)
  }
}

