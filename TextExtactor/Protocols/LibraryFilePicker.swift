//
//  LibraryFilePicker.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 11.03.2021.
//

import UIKit

protocol LibraryFilePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func pickFileLibrary()
}

extension LibraryFilePicker where Self: UIViewController {
  func pickFileLibrary() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .savedPhotosAlbum
    imagePickerController.delegate = self
    imagePickerController.mediaTypes = ["public.movie"]
    present(imagePickerController, animated: true, completion: nil)
  }
}
