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

final class NewDocumentController: UIViewController, TabBared {
  
  @IBOutlet weak var fileView: TitledActionView!
  @IBOutlet weak var locationView: TitledActionView!
  
  @IBOutlet weak var newDocumentTextView: UITextView!
  
  @IBOutlet weak var actionProgressView: ActionView!
  @IBOutlet weak var actionButton: UIButton!
  
  var viewModel = NewDocumentViewModel()
  private var _expandedCell: ExpandableCell?
  private var _document: Document?
  
  private var _textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
  private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    actionProgressView.viewState = .empty
    
    self.viewModel.processStepHandler = { step in
      switch step {
      case .start:
        self.newDocumentTextView.text = ""
        self.newDocumentTextView.textColor = .label
        self.actionProgressView.viewState = .cancel
      case .recognized(let text):
        self.newDocumentTextView.typeOn(string: text)
      case .progress(let progress): break
      //        self.actionProgressView.startProgress(to: progress, duration: 0.2)
      case .finish:
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          guard let text = self.newDocumentTextView.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.actionProgressView.viewState = .save
            self._finalizeExtracting()
            return
          }
          self.actionProgressView.viewState = .empty
          self._showExtractErrorWarning()
        }
      }
    }
    
    _clearFileViews()
    
    _updateLocaleView()
    
    guard !FileManager.savedDocuments.isEmpty else { return }
    select(tab: .recents)
  }
  
  private func _finalizeExtracting() {
    func success() {
      guard let doc = viewModel.document else {
        return
      }
      
      self._clearFileViews()
      toPreview(with: doc)
      select(tab: .recents)
    }
    
    func deny() {
      self._clearFileViews()
    }
    
    switch actionProgressView.viewState {
    case .save, .empty:
      guard !UserDefaults.standard.shouldShowPaywall else {
        self.showPaywall(handlers: PaywallHandlers(success: success, deny: deny))
        return
      }
      success()
    case .cancel:
      self._clearFileViews()
      self.viewModel.stopExtracting()
    }
  }
  private func _showExtractErrorWarning() {
    let alert = UIAlertController(title: "Sorry", message: "Unable to extract text from this file and in this Locale", preferredStyle: .alert)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    hideTabbarSeparator()
  }
  
  private func _clearFileViews() {
    fileView.title = "Choose File..."
    fileView.subtitle = ""
    viewModel.clearData()
    actionProgressView.viewState = .empty
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
    //    viewModel.loadVideo()
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
      self._setupVision()
      self.selectFromCamera()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
      self.dismiss(animated: true, completion: nil)
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func chooseLocationPressed() {
    performSegue(withIdentifier: "toLocationPicker", sender: nil)
  }
  
  @IBAction func actionButtonPressed() {
    self._finalizeExtracting()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toLocationPicker",
       let controller = segue.destination as? LocalesController {
      controller.onSelect = { locale in
        UserDefaults.standard.extractingLocale = locale
        self._updateLocaleView()
      }
    }
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
  private func _processImage(_ image: UIImage) {
    self._recognizeTextInImage(image)
  }
  
  private func _recognizeTextInImage(_ image: UIImage) {
    guard let cgImage = image.cgImage else { return }
    
    textRecognitionWorkQueue.async {
      let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      do {
        try requestHandler.perform([self._textRecognitionRequest])
      } catch {
        print(error)
      }
    }
  }
  
  private func _setupVision() {
    self._textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
      
      var detectedText = ""
      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { return }
        print("text \(topCandidate.string) has confidence \(topCandidate.confidence)")
        
        detectedText += topCandidate.string
        detectedText += "\n"
      }
      
      DispatchQueue.main.async {
        self.viewModel.document = Document(name: "New", text: detectedText, createdAt: Date(), modifiedAt: Date())
        print("detectedText", detectedText)
        self._finalizeExtracting()
      }
    }
    
    self._textRecognitionRequest.recognitionLevel = .accurate
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    guard scan.pageCount >= 1 else {
      controller.dismiss(animated: true)
      return
    }
    
    let originalImage = scan.imageOfPage(at: 0)
    let newImage = _compressedImage(originalImage)
    controller.dismiss(animated: true)
    
    self._processImage(newImage)
  }
  
  private func _compressedImage(_ originalImage: UIImage) -> UIImage {
    guard let imageData = originalImage.jpegData(compressionQuality: 1),
          let reloadedImage = UIImage(data: imageData) else {
      return originalImage
    }
    return reloadedImage
  }
}
