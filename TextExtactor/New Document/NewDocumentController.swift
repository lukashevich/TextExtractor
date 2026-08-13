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

final class NewDocumentController: UIViewController, AlertPresenter {
  
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
  private let _accentColor = UIColor.accentColor
  
  override func viewDidLoad() {
    super.viewDidLoad()

    _configureAppearance()
    
    self.viewModel.processStepHandler = { step in
      switch step {
      case .error:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
          self.bottomView.isHidden = true
          self.preloader.isHidden = true
          self._clearFileViews()
          self.showAlert(.cantTranscribe)
        })
        
      case .start:
        TapticHelper.weak()
        self.newDocumentTextView.text = ""
        self.newDocumentTextView.textColor = .label
      case .recognized(let text):
        self.bottomView.isHidden = false
        self.preloader.isHidden = true
        self.newDocumentTextView.type(text)
      case .progress:
        break
      case .finish(let document):
        TapticHelper.triple()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
      self._router.navigate(to: .paywall(Subscription.currentGroup.main, PaywallHandlers(success: success, deny: deny)))
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
    self.preloader.isHidden = true
    newDocumentTextView.text = nil
  }

  private func _configureAppearance() {
    view.backgroundColor = .clear

    let backdrop = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    backdrop.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(backdrop, at: 0)
    NSLayoutConstraint.activate([
      backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backdrop.topAnchor.constraint(equalTo: view.topAnchor),
      backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    _styleGlassSurface(fileView, cornerRadius: 18)
    _styleGlassSurface(locationView, cornerRadius: 18)

    if let textSurface = newDocumentTextView.superview {
      _styleGlassSurface(textSurface, cornerRadius: 24)
    }
    newDocumentTextView.backgroundColor = .clear
    newDocumentTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    newDocumentTextView.font = .systemFont(ofSize: 22, weight: .regular)

    _styleGlassSurface(preloader, cornerRadius: 20)
    preloader.preloader.color = _accentColor

    _styleGlassSurface(bottomView, cornerRadius: 22)
    _styleBottomActions()
    progressView.isHidden = true
  }

  private func _styleGlassSurface(_ surface: UIView, cornerRadius: CGFloat) {
    surface.backgroundColor = .clear
    surface.layer.cornerRadius = cornerRadius
    surface.layer.cornerCurve = .continuous
    surface.layer.borderWidth = 1
    surface.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
    surface.clipsToBounds = true

    let material = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    material.translatesAutoresizingMaskIntoConstraints = false
    surface.insertSubview(material, at: 0)
    NSLayoutConstraint.activate([
      material.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
      material.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
      material.topAnchor.constraint(equalTo: surface.topAnchor),
      material.bottomAnchor.constraint(equalTo: surface.bottomAnchor)
    ])
    _clearBackgrounds(in: surface, excluding: material)
  }

  private func _clearBackgrounds(in view: UIView, excluding excludedView: UIView? = nil) {
    view.subviews.forEach { subview in
      guard subview !== excludedView else { return }
      subview.backgroundColor = .clear
      _clearBackgrounds(in: subview, excluding: excludedView)
    }
  }

  private func _styleBottomActions() {
    guard let actionStack = bottomView.subviews.compactMap({ $0 as? UIStackView }).first else { return }
    let buttons = actionStack.arrangedSubviews.compactMap { $0 as? UIButton }

    for button in buttons {
      button.layer.cornerRadius = 14
      button.layer.cornerCurve = .continuous
      button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }

    guard buttons.count >= 2 else { return }
    buttons[0].backgroundColor = _accentColor
    buttons[0].setTitleColor(.white, for: .normal)
    buttons[1].backgroundColor = UIColor.white.withAlphaComponent(0.08)
    buttons[1].layer.borderWidth = 1
    buttons[1].layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
    buttons[1].setTitleColor(.secondaryLabel, for: .normal)
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
