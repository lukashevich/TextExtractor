//
//  NewDocument.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit
import UICircularProgressRing
import VisionKit
import Vision

final class NewDocumentController: UIViewController {
  
  @IBOutlet weak var fileView: TitledActionView!
  @IBOutlet weak var locationView: TitledActionView!
  
  @IBOutlet weak var newDocumentTextView: UITextView!
  @IBOutlet weak var progressView: UIProgressView!

  @IBOutlet weak var actionProgressView: ActionView!
  @IBOutlet weak var cancelButton: UIButton!
  
  var viewModel: NewDocumentViewModel!
  private var _expandedCell: ExpandableCell?
  private var _document: Document?
  private lazy var _router = NewDocRouter(controller: self)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cancelButton.isHidden = true
    
    self.viewModel.processStepHandler = { step in
      switch step {
      case .start:
        self.progressView.progress = 0.0
        self.progressView.isHidden = false
        self.newDocumentTextView.text = ""
        self.newDocumentTextView.textColor = .label
        self.cancelButton.isHidden = false
      case .recognized(let text):
        self.newDocumentTextView.typeOn(string: text)
      case .progress(let progress):
        print(Float(progress))
        self.progressView.setProgress(Float(progress), animated: true)
      case .finish(let document):
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.progressView.progress = 1.0
          self.progressView.isHidden = true
          self.cancelButton.isHidden = true
          guard let doc = document, !doc.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self._showExtractErrorWarning()
            return
          }
          self._finalizeExtracting(doc)
        }
      }
    }
    
    _clearFileViews()
    
    _updateLocaleView()
  }
  
  private func _finalizeExtracting(_ doc: Document) {
    func success() {
      guard let doc = viewModel.document else { return }
      self._clearFileViews()
      self._router.navigate(to: .preview(doc))
    }
    
    func deny() {
      self._clearFileViews()
    }
    
    guard !UserDefaults.standard.shouldShowPaywall else {
      self._router.navigate(to: .paywall(PaywallHandlers(success: success, deny: deny)))
      return
    }
    
    success()
  }
  
  @IBAction func cancelPressed() {
    self._clearFileViews()
    self.viewModel.stopExtracting()
  }
  
  private func _showExtractErrorWarning() {
    let alert = UIAlertController(title: "Sorry", message: "Unable to extract text from this file and in this Locale", preferredStyle: .alert)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func _clearFileViews() {
    fileView.title = "Choose File..."
    fileView.subtitle = ""
    viewModel.clearData()
    self.cancelButton.isHidden = true
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
    let alert = UIAlertController(title: "Choose file", message: "from", preferredStyle: .actionSheet)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "Files", style: .default , handler:{ _ in
      self._clearFileViews()
      self.pickFileFromCloud()
    }))
    
    alert.addAction(UIAlertAction(title: "Library", style: .default , handler:{ _ in
      self._clearFileViews()
      self.pickFileLibrary()
    }))
    
    alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ _ in
      self._clearFileViews()
      self.viewModel.setupVision()
      self.selectFromCamera()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func chooseLocationPressed() {
    let handler: LocalePickerHandler = { locale in
      UserDefaults.standard.extractingLocale = locale
      self._updateLocaleView()
    }
    self._router.navigate(to: .locales(handler))
  }
  
  @IBAction func actionButtonPressed() {
//    self._finalizeExtracting()
  }
}

extension NewDocumentController: LibraryFilePicker {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
      self.fileView.title = videoURL.deletingPathExtension().lastPathComponent
      self.fileView.subtitle = videoURL.pathExtension
      self.viewModel.fileUrl = videoURL
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
