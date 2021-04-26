//
//  iCloudFilePicker.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 16.02.2021.
//

import UIKit
import CoreServices

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
  
  private func _getUTTypeCreateAllIdentifiers(for tag: String) -> [String] {
      let cfArray = UTTypeCreateAllIdentifiersForTag(
        kUTTagClassFilenameExtension,
        tag as CFString,
        nil
      )?.takeRetainedValue()
      let utis: [String] = cfArray as? [String] ?? []
      return utis;
    }
}

