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

final class NewDocumentController: UIViewController, AlertPresenter, ShareControllerPresenter {
  
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
  private let _emptyStateView = UIView()
  private let _emptyStateTitle = UILabel()
  private let _emptyStateSubtitle = UILabel()
  private var _resultPlayer: PlayerView?
  private var _resultDocument: Document?
  private var _resultPlayerTopConstraint: NSLayoutConstraint?
  private var _defaultActionTopConstraint: NSLayoutConstraint?
  private var _mediaActionTopConstraint: NSLayoutConstraint?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    _configureAppearance()
    
    self.viewModel.processStepHandler = { step in
      switch step {
      case .preparing(let status):
        self._setEmptyStateVisible(false)
        self.bottomView.isHidden = true
        self.preloader.setStatus(status)
        self.preloader.isHidden = false
      case .error:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
          self.newDocumentTextView.cancelTyping()
          self.bottomView.isHidden = true
          self.preloader.isHidden = true
          self._clearFileViews()
          self.showAlert(.cantTranscribe)
        })
        
      case .start:
        TapticHelper.weak()
        self._setEmptyStateVisible(false)
        self.newDocumentTextView.cancelTyping()
        self.newDocumentTextView.text = ""
        self.newDocumentTextView.textColor = .label
        self.bottomView.isHidden = true
        self.preloader.setStatus(self.viewModel.fileUrl == nil ? "Reading text…" : "Transcribing…")
        self.preloader.isHidden = false
      case .recognized(let text):
        // The transcript is still incomplete here. Keeping the progress state visible
        // prevents a partial document from being opened before all chunks are processed.
        self.bottomView.isHidden = true
        self.preloader.isHidden = false
        self.newDocumentTextView.type(text)
      case .progress(let completed, let total):
        self.preloader.setStatus("Transcribing \(completed) of \(total)…")
      case .finish(let document):
        TapticHelper.triple()
        self.newDocumentTextView.completeTyping()
        self.preloader.setStatus("Preparing your transcript…")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.preloader.isHidden = true
          guard let doc = document, !doc.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self._showExtractErrorWarning()
            return
          }
          self._showFinishedResult(doc)
        }
      }
    }
    
    _clearFileViews()
    
    _updateLocaleView()
  }
  
  private func _showFinishedResult(_ document: Document) {
    func success() {
      self._resultDocument = document
      self._configureResultActions(for: document)
      self.bottomView.isHidden = false
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
    shareResult()
  }
  
  @IBAction func savePressed() {
    saveResult()
  }
  
  private func _showExtractErrorWarning() {
    let alert = UIAlertController(title: "Sorry", message: "UNABLE_TO_EXTRACT_MESSAGE".localized, preferredStyle: .alert)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  private func _configureResultActions(for document: Document) {
    guard let actionStack = bottomView.subviews.compactMap({ $0 as? UIStackView }).first else { return }
    let buttons = actionStack.arrangedSubviews.compactMap { $0 as? UIButton }
    guard buttons.count >= 2 else { return }

    buttons[0].setTitle("Save", for: .normal)
    buttons[1].setTitle("Share", for: .normal)

    switch document.source {
    case .audio, .video:
      _configureResultPlayer(with: AudioEditHelper.preparedAudioURL, actionStack: actionStack)
    case .picture:
      _hideResultPlayer()
    }
  }

  private func _configureResultPlayer(with url: URL, actionStack: UIStackView) {
    let player: PlayerView
    if let existingPlayer = _resultPlayer {
      player = existingPlayer
    } else {
      let newPlayer = PlayerView(frame: .zero)
      newPlayer.translatesAutoresizingMaskIntoConstraints = false
      newPlayer.xibSetup()
      bottomView.addSubview(newPlayer)

      let defaultTop = bottomView.constraints.first {
        $0.firstItem === actionStack && $0.firstAttribute == .top
      }
      _defaultActionTopConstraint = defaultTop
      defaultTop?.isActive = false

      let playerTop = newPlayer.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16)
      let actionTop = actionStack.topAnchor.constraint(equalTo: newPlayer.bottomAnchor, constant: 16)
      NSLayoutConstraint.activate([
        playerTop,
        actionTop,
        newPlayer.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 20),
        newPlayer.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20),
        newPlayer.heightAnchor.constraint(equalToConstant: 44)
      ])
      _resultPlayerTopConstraint = playerTop
      _mediaActionTopConstraint = actionTop
      _resultPlayer = newPlayer
      player = newPlayer
    }

    player.isHidden = false
    _resultPlayerTopConstraint?.isActive = true
    _mediaActionTopConstraint?.isActive = true
    _defaultActionTopConstraint?.isActive = false
    player.fileUrl = url
  }

  private func _hideResultPlayer() {
    _resultPlayer?.fileUrl = nil
    _resultPlayer?.isHidden = true
    _resultPlayerTopConstraint?.isActive = false
    _mediaActionTopConstraint?.isActive = false
    _defaultActionTopConstraint?.isActive = true
  }

  private func saveResult() {
    guard let document = _resultDocument,
          let text = newDocumentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          !text.isEmpty
    else {
      return
    }

    let documentToSave = document.copy(text: text)
    let audioURL: URL?
    switch document.source {
    case .audio, .video:
      audioURL = AudioEditHelper.preparedAudioURL
    case .picture:
      audioURL = nil
    }

    do {
      try documentToSave.saveReplacing(nil, audioSourceURL: audioURL, timeline: viewModel.timeline)
      UIApplication.dismissToRoot()
    } catch {
      let alert = UIAlertController(
        title: "Couldn’t Save Document",
        message: error.localizedDescription,
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      present(alert, animated: true)
    }
  }

  private func shareResult() {
    guard let document = _resultDocument else { return }
    let text = newDocumentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    share(object: text?.isEmpty == false ? text! : document.text)
  }
  
  private func _clearFileViews() {
    newDocumentTextView.cancelTyping()
    _resultDocument = nil
    _hideResultPlayer()
    fileView.title = "Source"
    fileView.subtitle = "Choose below"
    viewModel.clearData()
    self.bottomView.isHidden = true
    self.preloader.isHidden = true
    newDocumentTextView.text = nil
    _setEmptyStateVisible(true)
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
    newDocumentTextView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
    newDocumentTextView.font = .systemFont(ofSize: 22, weight: .regular)

    if let contentStack = newDocumentTextView.superview?.superview as? UIStackView {
      contentStack.spacing = 16
    }

    _styleGlassSurface(preloader, cornerRadius: 20)
    preloader.preloader.color = _accentColor

    _styleGlassSurface(bottomView, cornerRadius: 22)
    _styleBottomActions()
    _configureEmptyState()
    progressView.isHidden = true
  }

  private func _configureEmptyState() {
    guard let surface = newDocumentTextView.superview else { return }

    _emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    surface.addSubview(_emptyStateView)
    NSLayoutConstraint.activate([
      _emptyStateView.leadingAnchor.constraint(equalTo: surface.leadingAnchor, constant: 24),
      _emptyStateView.trailingAnchor.constraint(equalTo: surface.trailingAnchor, constant: -24),
      _emptyStateView.centerYAnchor.constraint(equalTo: surface.centerYAnchor)
    ])

    _emptyStateTitle.text = "Start a transcription"
    _emptyStateTitle.font = .systemFont(ofSize: 25, weight: .bold)
    _emptyStateTitle.textAlignment = .center
    _emptyStateTitle.textColor = .label

    _emptyStateSubtitle.text = "Choose where your content comes from"
    _emptyStateSubtitle.font = .systemFont(ofSize: 15, weight: .regular)
    _emptyStateSubtitle.textAlignment = .center
    _emptyStateSubtitle.textColor = .secondaryLabel
    _emptyStateSubtitle.numberOfLines = 0

    let sourceStack = UIStackView(arrangedSubviews: [
      _sourceButton(title: "Files", subtitle: "Audio or video", symbol: "folder.fill", action: #selector(_pickFromFiles)),
      _sourceButton(title: "Library", subtitle: "Video from Photos", symbol: "photo.on.rectangle.angled", action: #selector(_pickFromLibrary)),
      _sourceButton(title: "Scan text", subtitle: "Use the camera", symbol: "doc.text.viewfinder", action: #selector(_scanText))
    ])
    sourceStack.axis = .vertical
    sourceStack.spacing = 12

    let content = UIStackView(arrangedSubviews: [_emptyStateTitle, _emptyStateSubtitle, sourceStack])
    content.axis = .vertical
    content.spacing = 10
    content.setCustomSpacing(18, after: _emptyStateSubtitle)
    content.translatesAutoresizingMaskIntoConstraints = false
    _emptyStateView.addSubview(content)
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: _emptyStateView.leadingAnchor),
      content.trailingAnchor.constraint(equalTo: _emptyStateView.trailingAnchor),
      content.topAnchor.constraint(equalTo: _emptyStateView.topAnchor),
      content.bottomAnchor.constraint(equalTo: _emptyStateView.bottomAnchor)
    ])
  }

  private func _sourceButton(title: String, subtitle: String, symbol: String, action: Selector) -> UIButton {
    var configuration = UIButton.Configuration.tinted()
    configuration.title = title
    configuration.subtitle = subtitle
    configuration.image = UIImage(systemName: symbol)
    configuration.imagePlacement = .leading
    configuration.imagePadding = 12
    configuration.titleAlignment = .leading
    configuration.baseForegroundColor = _accentColor
    configuration.background.cornerRadius = 16
    configuration.background.backgroundColor = _accentColor.withAlphaComponent(0.12)

    let button = UIButton(configuration: configuration)
    button.contentHorizontalAlignment = .leading
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraint(equalToConstant: 64).isActive = true
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }

  private func _setEmptyStateVisible(_ visible: Bool) {
    _emptyStateView.isHidden = !visible
    fileView.isUserInteractionEnabled = !visible
  }

  @objc private func _pickFromFiles() {
    _clearFileViews()
    pickFileFromCloud()
  }

  @objc private func _pickFromLibrary() {
    _clearFileViews()
    pickFileLibrary()
  }

  @objc private func _scanText() {
    _clearFileViews()
    viewModel.setupVision()
    selectFromCamera()
  }

  private func _showSelectedFile(_ url: URL) {
    _setEmptyStateVisible(false)
    fileView.title = url.deletingPathExtension().lastPathComponent
    fileView.subtitle = url.pathExtension
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
    buttons[1].backgroundColor = .secondarySystemGroupedBackground
    buttons[1].layer.borderWidth = 1
    buttons[1].layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
    buttons[1].setTitleColor(.secondaryLabel, for: .normal)
  }

  
  private func _updateLocaleView() {
    locationView.title = UserDefaults.standard.extractingLocale.country ?? ""
    locationView.subtitle = UserDefaults.standard.extractingLocale.identifier
    let hasSelectedFile = viewModel.fileUrl != nil
    viewModel.prepareForLocalize()

    guard hasSelectedFile else { return }

    // A locale change starts a fresh recognition pass over the same prepared audio.
    // Never leave the old transcript or player active while that pass is running.
    _resultDocument = nil
    _hideResultPlayer()
    bottomView.isHidden = true
    newDocumentTextView.cancelTyping()
    newDocumentTextView.text = nil
    preloader.setStatus("Updating language…")
    preloader.isHidden = false
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
      self._showSelectedFile(videoURL)
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
    
    self._showSelectedFile(url)
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

    self._setEmptyStateVisible(false)
    self.viewModel.processImage(newImage)
  }
}
