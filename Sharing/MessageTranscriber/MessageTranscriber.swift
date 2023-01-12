//
//  ShareViewController.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 12.04.2021.
//

import UIKit
import Social
import AVFoundation
import DrawerView

@objc(MessageTranscriber)
class MessageTranscriber: UIViewController, AlertPresenter {
  
  var positionHandler: ((DrawerPosition)->Void)?

  private lazy var _router = MessageTranscriberRouter(controller: self)
  
  @IBOutlet weak var textView: TypenTextView!
  @IBOutlet weak var localeButton: UIButton!

  @IBOutlet private weak var _statusLabel: UILabel!
  @IBOutlet private weak var _statusActivity: UIActivityIndicatorView!
  @IBOutlet private weak var _saveButton: UIButton!
  @IBOutlet private weak var _contentView: UIView!
  @IBOutlet private weak var _progressView: UIProgressView!

  private var _exportedFiles: [ExportedFile] = []
  private let _placeholder = "Extracted text"
  private var _extractingLocale: Locale = UserDefaults.standard.extractingLocale {
    didSet {
      UserDefaults.standard.extractingLocale = _extractingLocale
      Analytics.setUser(property: .extractionLocale(_extractingLocale.titleForButton))
      localeButton.setTitle(_extractingLocale.titleForButton, for: .normal)
    }
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
  
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
  
  private func _localeChanged(to locale: Locale) {
    Recognizer.stopRecognizing()
    Analytics.setUser(property: .extractionLocale(locale.titleForButton))
    localeButton.setTitle(locale.titleForButton, for: .normal)
    _clearTrancribedText()
    _progressView.setProgress(0, animated: true)
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
      _progressView.setProgress(progress, animated: true)
      
      guard !text.isEmpty else { return }
      
      if textView.text == _placeholder { textView.text = "" }
      
      textView.textColor = .label
      DispatchQueue.main.async {
        self.textView.isHidden = false
        self.textView.text = self.textView.text + "\n" + text
        self._hidePreloader()
      }
     
    }, completion: { [weak self] in
      
      guard let weakSelf = self else { return }
      
      weakSelf._hidePreloader()
      
      guard let currText = weakSelf.textView.text else {
        weakSelf.showAlert(.cantTranscribe)
        return
      }
      
      Analytics.log(MessageTranscriberEvent.recognizeResult(!currText.isEmpty))
      
      switch currText.isEmpty {
      case true:
        weakSelf.showAlert(.cantTranscribe)
      case false:
        UserDefaults.standard.transcriptionsCount += 1
        Analytics.setUser(property: .transcriptionsCount(UserDefaults.standard.transcriptionsCount ))
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
    positionHandler?(.partiallyOpen)
    _statusActivity.isHidden = false
    _statusLabel.text = "processing..."
    _statusLabel.textAlignment = .left
    _statusLabel.isHidden = false
    _saveButton.isHidden = true
  }
  
  private func _hidePreloader() {
    _statusActivity.isHidden = true
    _statusLabel.text = "Transcriber"
    _statusLabel.textAlignment = .center
    
    _saveButton.isEnabled = !textView.text.isEmpty

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

