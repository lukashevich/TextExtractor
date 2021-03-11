//
//  CameraTextFinder.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 11.03.2021.
//

import UIKit
import Vision
import VisionKit

protocol CameraTextFinder: VNDocumentCameraViewControllerDelegate {
  func selectFromCamera()
}

extension CameraTextFinder where Self: UIViewController {
  func selectFromCamera() {
    let cameraPickerController = VNDocumentCameraViewController()
    cameraPickerController.delegate = self
    present(cameraPickerController, animated: true, completion: nil)
  }
}
