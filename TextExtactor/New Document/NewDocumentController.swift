//
//  NewDocument.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit
import VisionKit
import Vision

final class NewDocumentController: UIViewController {
  
  @IBOutlet weak var fileView: TitledActionView!
  @IBOutlet weak var locationView: TitledActionView!
  
  @IBOutlet weak var newDocumentTextView: TypenTextView!
  @IBOutlet weak var progressView: UIProgressView!

  @IBOutlet weak var preloader: TitledPreloader!
  @IBOutlet weak var bottomView: UIView!
  
  var viewModel: NewDocumentViewModel!
  private var _expandedCell: ExpandableCell?
  private var _document: Document?
  private lazy var _router = NewDocRouter(controller: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    self.viewModel.processStepHandler = { step in
      switch step {
      case .start:
        TapticHelper.weak()
        self.newDocumentTextView.text = ""
        self.newDocumentTextView.textColor = .label
      case .recognized(let text):
        self.bottomView.isHidden = false
        self.progressView.progress = 0.0
        self.preloader.isHidden = true
        self.newDocumentTextView.type(text)
      case .progress(let progress):
        self.progressView.setProgress(Float(progress), animated: true)
      case .finish(let document):
        TapticHelper.triple()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.progressView.progress = 1.0
          self.bottomView.isHidden = true
          guard let doc = document, !doc.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self._showExtractErrorWarning()
            return
          }
          self._finalizeExtracting()
        }
      }
    }
    
    _clearFileViews()
    
    _updateLocaleView()
  }
  
  private func _finalizeExtracting() {
    func success() {
      guard let doc = viewModel.document else { return }
      self._clearFileViews()
      self._router.navigate(to: .preview(doc))
    }
    
    func deny() {
      self._clearFileViews()
    }
    
    guard !UserDefaults.standard.shouldShowPaywall else {
      self._router.navigate(to: .paywall(.monthly, PaywallHandlers(success: success, deny: deny)))
      return
    }
    
    success()
  }
  
  @IBAction func cancelPressed() {
    self._clearFileViews()
    self.viewModel.stopExtracting()
  }
  
  @IBAction func savePressed() {
    self.viewModel.stopExtractingAndSaveDocument()
  }
  
  private func _showExtractErrorWarning() {
    let alert = UIAlertController(title: "Sorry", message: "UNABLE_TO_EXTRACT_MESSAGE".localized, preferredStyle: .alert)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func _clearFileViews() {
    fileView.title = "CHOOSE_FILE...".localized
    fileView.subtitle = ""
    viewModel.clearData()
    self.bottomView.isHidden = true
    newDocumentTextView.text = nil
  }
  
  private func _updateLocaleView() {
    locationView.title = UserDefaults.standard.extractingLocale.country ?? ""
    locationView.subtitle = UserDefaults.standard.extractingLocale.identifier
    viewModel.prepareForLocalize()
    guard viewModel.fileUrl != nil else { return }
    viewModel.startProcessing()
  }
  
  @IBAction func chooseFilePressed() {
    let alert = UIAlertController(title: "CHOOSE_FILE".localized, message: "FROM".localized, preferredStyle: .actionSheet)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "FILES".localized, style: .default , handler:{ _ in
      self._clearFileViews()
      self.pickFileFromCloud()
    }))
    
    alert.addAction(UIAlertAction(title: "LIBRARY".localized, style: .default , handler:{ _ in
      self._clearFileViews()
      self.pickFileLibrary()
    }))
    
    alert.addAction(UIAlertAction(title: "CAMERA".localized, style: .default , handler:{ _ in
      self._clearFileViews()
      self.viewModel.setupVision()
      self.selectFromCamera()
    }))
    
    alert.addAction(UIAlertAction(title: "CANCEL".localized, style: .cancel , handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func chooseLocationPressed() {
    let handler: LocalePickerHandler = { locale in
      UserDefaults.standard.extractingLocale = locale
      self._updateLocaleView()
    }
    self._router.navigate(to: .locales(handler))
  }
}

extension NewDocumentController: LibraryFilePicker {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
      self.fileView.title = videoURL.deletingPathExtension().lastPathComponent
      self.fileView.subtitle = videoURL.pathExtension
      self.viewModel.fileUrl = videoURL
      self.preloader.isHidden = false
      picker.dismiss(animated: true, completion: nil)
    }
  }
}

extension NewDocumentController: iCloudFilePicker {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first,
          url.startAccessingSecurityScopedResource()
    else {
      return
    }
    
    self.fileView.title = url.deletingPathExtension().lastPathComponent
    self.fileView.subtitle = url.pathExtension
    self.preloader.isHidden = false
    self.viewModel.fileUrl = url
    url.stopAccessingSecurityScopedResource()
  }
}

extension NewDocumentController: CameraTextFinder {
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    guard scan.pageCount >= 1 else {
      controller.dismiss(animated: true)
      return
    }
    
    let originalImage = scan.imageOfPage(at: 0)
    let newImage = self.viewModel.compressedImage(originalImage)
    controller.dismiss(animated: true)
    
    self.viewModel.processImage(newImage)
  }
}
