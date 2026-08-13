//
//  ShareViewController.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 12.04.2021.
//

import UIKit
import Social
import AVFoundation

@objc(MessageTranscriber)
class MessageTranscriber: UIViewController, AlertPresenter {

  private lazy var _router = MessageTranscriberRouter(controller: self)
  
  @IBOutlet weak var textView: TypenTextView!
  @IBOutlet weak var localeButton: UIButton!

  @IBOutlet private weak var _statusLabel: UILabel!
  @IBOutlet private weak var _statusActivity: UIActivityIndicatorView!
  @IBOutlet private weak var _saveButton: UIButton!
  @IBOutlet private weak var _contentView: UIView!
  @IBOutlet private weak var _progressView: UIProgressView!

  private let _accentColor = UIColor(red: 0.33, green: 0.67, blue: 1.0, alpha: 1.0)
  private let _circularProgress = CircularProgressIndicator()
  private var _progressHideWorkItem: DispatchWorkItem?

  private var _exportedFiles: [ExportedFile] = []
  private let _placeholder = "Extracted text"
  private var _extractingLocale: Locale = UserDefaults.standard.extractingLocale {
    didSet {
      UserDefaults.standard.extractingLocale = _extractingLocale
      Analytics.setUser(property: .extractionLocale(_extractingLocale.titleForButton))
      _updateLocaleButtonTitle()
    }
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()

    _configureGlassAppearance()
  
    _completeTransactions()
    
    FileManager.createDefaults()
    FileManager.clearTmpFolder()

    _showPaywallIfNeeded()
    
    _extractingLocale = UserDefaults.standard.extractingLocale

    self._handleSharedFile(completion: _processExported)
  }
  
  private func _completeTransactions() {
    SubscriptionHelper.completeTransactions()
  }
  
  private func _showPaywallIfNeeded() {
    guard UserDefaults.standard.transcriptionsCount > 2 &&
            !UserDefaults.standard.userSubscribed &&
              !UserDefaults.standard.userPromoted else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
      let handlers = PaywallHandlers(
        success: { [unowned self] in dismiss(animated: true, completion: nil) },
        deny: { [unowned self] in extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
      })
//      _router.navigate(to: .paywall(handlers))
      _router.navigate(to: .doublePaywall(Subscription.currentDoubleGroup, handlers))
    }
  }
  
  private func _processExported(files: [ExportedFile]) {
    Analytics.log(MessageTranscriberEvent.proccess(files.count))
    guard !files.isEmpty else {
      self.showAlert(.somethingWentWrong) { _ in
        let error = NSError(domain: "com.textr", code: 0, userInfo: [NSLocalizedDescriptionKey: "Undefined file"])
        self.extensionContext?.cancelRequest(withError: error)
      }
      return
    }
    
    let group = DispatchGroup()

    var audios = [ExportedFile]()
    var texts = [ExportedFile]()
    
    files.forEach {
      group.enter()
      switch $0 {
      case .audio(let index, let url):
        let copiedFileURL = AudioConverter.convertOGG(at: url, with: index)
        self.prepareFile(at: copiedFileURL, index: index) { url in
          audios.append(.audio(index: index, url: url))
          group.leave()
        }
      case .text:
        texts.append($0)
        group.leave()
      }
    }
    
    group.notify(queue: .main) {
      let result = (audios + texts).sorted(by: < )
      self._exportedFiles = result
      self._recognize(files: result)
    }
  }
  
  @IBAction private func _cancelAction () { close() }
  
  func close() {
    let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
    extensionContext?.cancelRequest(withError: error)
  }
  
  private func _clearTrancribedText() {
    textView.textColor = .tertiaryLabel
    textView.text = _placeholder
  }

  private func _updateLocaleButtonTitle() {
    let title = _extractingLocale.languageFlag
      ?? _extractingLocale.languageCode?.uppercased()
      ?? _extractingLocale.identifier
    localeButton.setTitle(title, for: .normal)
  }
  
  private func _localeChanged(to locale: Locale) {
    Recognizer.stopRecognizing()
    Analytics.setUser(property: .extractionLocale(locale.titleForButton))
    _clearTrancribedText()
    _setProgress(0, animated: false)
    _extractingLocale = locale
    _showPreloader()
    _recognize(files: _exportedFiles)
  }
  
  private func _recognize(files: [ExportedFile]) {
    _showPreloader()
    textView.text = nil
    var transcribedItemsCount = 0
    
    Recognizer.recognizeExported(files: _exportedFiles, in: _extractingLocale, newText: { [unowned self] text in
      transcribedItemsCount += 1
      let progress: Float = Float(transcribedItemsCount) / Float(_exportedFiles.count)
      _setProgress(progress, animated: true)
      
      guard !text.isEmpty else { return }
      
      if textView.text == _placeholder { textView.text = "" }
      
      textView.textColor = .label
      DispatchQueue.main.async {
        self.textView.isHidden = false
        self.textView.text = self.textView.text + "\n" + text
      }
     
    }, completion: { [weak self] in
      DispatchQueue.main.async {
        guard let self else { return }

        self._hidePreloader()

        let currText = self.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        Analytics.log(MessageTranscriberEvent.recognizeResult(!currText.isEmpty))

        if currText.isEmpty {
          self.showAlert(.cantTranscribe)
        } else {
          UserDefaults.standard.transcriptionsCount += 1
          Analytics.setUser(property: .transcriptionsCount(UserDefaults.standard.transcriptionsCount))
        }
      }
    })
  }
  
  @IBAction private func _toLocales() {
    _router.navigate(to: .locales(_localeChanged))
  }
  
  @IBAction private func _doneAction() {
    guard let text = textView.text else {
      self._hidePreloader()
      return
    }
    
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    let docName = formatter.string(from: Date())
    
    let document = Document(name: docName, text: text, createdAt: Date(), modifiedAt: Date(), source: .audio)
    UserDefaults.standard.documentsToImport.append(document)
    
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
  
  private func _showPreloader() {
    _progressHideWorkItem?.cancel()
    _progressHideWorkItem = nil
    _progressView.isHidden = true
    _circularProgress.isHidden = false
    _circularProgress.alpha = 1
    _setProgress(0, animated: false)
    _statusActivity.stopAnimating()
    _statusActivity.isHidden = true
    _statusLabel.text = "Transcribing…"
    _statusLabel.textAlignment = .center
    _statusLabel.isHidden = false
    _saveButton.isHidden = true
  }
  
  private func _hidePreloader() {
    _statusActivity.stopAnimating()
    _statusActivity.isHidden = true
    _statusLabel.text = "Transcript ready"
    _statusLabel.textAlignment = .center
    _saveButton.isEnabled = !textView.text.isEmpty

    _setProgress(1, animated: true)
    let hideWorkItem = DispatchWorkItem { [weak self] in
      guard let self else { return }
      UIView.animate(withDuration: 0.2, animations: {
        self._circularProgress.alpha = 0
      }, completion: { _ in
        self._circularProgress.isHidden = true
      })
    }
    _progressHideWorkItem = hideWorkItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: hideWorkItem)

  }

  private func _setProgress(_ progress: Float, animated: Bool) {
    let update = { [weak self] in
      self?._circularProgress.setProgress(CGFloat(progress), animated: animated)
    }

    if Thread.isMainThread {
      update()
    } else {
      DispatchQueue.main.async {
        update()
      }
    }
  }
  
  private func _handleSharedFile(completion: @escaping (([ExportedFile]) -> Void)) {
    
    self._showPreloader()
    // extracting the path to the URL that is being shared
    let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        
    let group = DispatchGroup()
    var exported = [ExportedFile]()
    
    Analytics.log(MessageTranscriberEvent.getAttachments(attachments.count))
    
    attachments.enumerated().forEach { index, attachment in
      group.enter()
        if attachment.hasItemConformingToTypeIdentifier("public.file-url" as String) {
          // extension is being called e.g. from Mail app
          attachment.loadItem(forTypeIdentifier: "public.file-url" as String, options: nil) { (data, error) in
            if let sourceURL = data as? URL {
              exported.append(.audio(index: index, url: sourceURL))
              group.leave()
            }
          }
        } else if attachment.hasItemConformingToTypeIdentifier("public.plain-text" as String) {
          attachment.loadItem(forTypeIdentifier: "public.plain-text" as String, options: nil) { (data, error) in
            if let sourceText = data as? String {
              exported.append(.text(index: index, text: sourceText))
            }
            group.leave()
          }
        } else {
          group.leave()
        }
    }
    
    group.notify(queue: .main) {
      completion(exported)
    }
  }
  
  func prepareFile(at url: URL, index: Int, completion: @escaping ((URL) -> Void) ) {
    let asset = AVURLAsset(url: url)
    let pathWhereToSave = FileManager.tmpFolder.path + "/temp_\(index).mp4"
    asset.writeAudioTrackToURL(URL(fileURLWithPath: pathWhereToSave)) { (success, error) -> () in
      if success {
        completion(url)
      }
    }
  }
}

private extension MessageTranscriber {
  func _configureGlassAppearance() {
    view.backgroundColor = .clear
    view.subviews.first?.backgroundColor = .clear

    let backdrop = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    backdrop.translatesAutoresizingMaskIntoConstraints = false
    backdrop.isUserInteractionEnabled = false
    view.insertSubview(backdrop, at: 0)
    NSLayoutConstraint.activate([
      backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backdrop.topAnchor.constraint(equalTo: view.topAnchor),
      backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    let headerSurface = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    headerSurface.translatesAutoresizingMaskIntoConstraints = false
    headerSurface.isUserInteractionEnabled = false
    headerSurface.layer.cornerRadius = 22
    headerSurface.clipsToBounds = true
    headerSurface.layer.borderWidth = 1
    headerSurface.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
    view.insertSubview(headerSurface, at: 2)
    NSLayoutConstraint.activate([
      headerSurface.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      headerSurface.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      headerSurface.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
      headerSurface.heightAnchor.constraint(equalToConstant: 68)
    ])

    _circularProgress.translatesAutoresizingMaskIntoConstraints = false
    _circularProgress.configure(progressColor: _accentColor)
    view.addSubview(_circularProgress)
    NSLayoutConstraint.activate([
      _circularProgress.leadingAnchor.constraint(equalTo: headerSurface.leadingAnchor, constant: 8),
      _circularProgress.centerYAnchor.constraint(equalTo: headerSurface.centerYAnchor),
      _circularProgress.widthAnchor.constraint(equalToConstant: 40),
      _circularProgress.heightAnchor.constraint(equalTo: _circularProgress.widthAnchor)
    ])

    if let headerStack = _statusLabel.superview as? UIStackView {
      headerStack.removeArrangedSubview(_statusLabel)
      _statusLabel.removeFromSuperview()
    }
    _statusLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_statusLabel)
    NSLayoutConstraint.activate([
      _statusLabel.centerXAnchor.constraint(equalTo: headerSurface.centerXAnchor),
      _statusLabel.centerYAnchor.constraint(equalTo: headerSurface.centerYAnchor)
    ])

    _contentView.backgroundColor = .clear
    _contentView.layer.cornerRadius = 24
    _contentView.layer.borderWidth = 1
    _contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    _contentView.clipsToBounds = true

    let transcriptSurface = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    transcriptSurface.translatesAutoresizingMaskIntoConstraints = false
    transcriptSurface.isUserInteractionEnabled = false
    _contentView.insertSubview(transcriptSurface, at: 0)
    NSLayoutConstraint.activate([
      transcriptSurface.leadingAnchor.constraint(equalTo: _contentView.leadingAnchor),
      transcriptSurface.trailingAnchor.constraint(equalTo: _contentView.trailingAnchor),
      transcriptSurface.topAnchor.constraint(equalTo: _contentView.topAnchor),
      transcriptSurface.bottomAnchor.constraint(equalTo: _contentView.bottomAnchor)
    ])

    _statusLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    _statusLabel.textColor = .secondaryLabel
    _statusActivity.isHidden = true

    localeButton.tintColor = .secondaryLabel
    localeButton.backgroundColor = UIColor.white.withAlphaComponent(0.08)
    localeButton.layer.cornerRadius = 20
    localeButton.layer.borderWidth = 1
    localeButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
    localeButton.setTitleColor(.secondaryLabel, for: .normal)
    localeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    _updateLocaleButtonTitle()

    _saveButton.tintColor = _accentColor
    _saveButton.backgroundColor = _accentColor.withAlphaComponent(0.14)
    _saveButton.layer.cornerRadius = 15
    _saveButton.layer.borderWidth = 1
    _saveButton.layer.borderColor = _accentColor.withAlphaComponent(0.35).cgColor
    _saveButton.setImage(UIImage(systemName: "square.and.arrow.down.fill"), for: .normal)

    _progressView.isHidden = true

    textView.backgroundColor = .clear
    textView.textColor = .label
    textView.font = .systemFont(ofSize: 20, weight: .regular)
    textView.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 16, right: 14)
    textView.textContainer.lineFragmentPadding = 0
    textView.indicatorStyle = .white
  }
}

private final class CircularProgressIndicator: UIView {
  private let _trackLayer = CAShapeLayer()
  private let _progressLayer = CAShapeLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = false
    backgroundColor = UIColor.white.withAlphaComponent(0.08)
    layer.cornerRadius = 20
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor

    [_trackLayer, _progressLayer].forEach {
      $0.fillColor = UIColor.clear.cgColor
      $0.lineWidth = 2.5
      $0.lineCap = .round
      layer.addSublayer($0)
    }
    _trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.16).cgColor
    _progressLayer.strokeEnd = 0
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let inset = _progressLayer.lineWidth / 2 + 5
    let circleRect = bounds.insetBy(dx: inset, dy: inset)
    let path = UIBezierPath(ovalIn: circleRect).cgPath
    _trackLayer.frame = bounds
    _progressLayer.frame = bounds
    _trackLayer.path = path
    _progressLayer.path = path
  }

  func configure(progressColor: UIColor) {
    _progressLayer.strokeColor = progressColor.cgColor
  }

  func setProgress(_ progress: CGFloat, animated: Bool) {
    let clampedProgress = min(max(progress, 0), 1)
    let fromValue = _progressLayer.presentation()?.strokeEnd ?? _progressLayer.strokeEnd
    _progressLayer.strokeEnd = clampedProgress

    guard animated else {
      _progressLayer.removeAnimation(forKey: "progress")
      return
    }

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = fromValue
    animation.toValue = clampedProgress
    animation.duration = 0.2
    _progressLayer.add(animation, forKey: "progress")
  }
}
