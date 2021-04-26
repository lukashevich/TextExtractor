//
//  ShareViewController.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 12.04.2021.
//

import UIKit
import Social
import AVFoundation

@objc(ImportController)
class ImportController: UIViewController, AlertPresenter {
  
  var _locale: Locale {
    UserDefaults.standard.extractingLocale
  }
  
  @IBOutlet weak var textView: TypenTextView!
  @IBOutlet private weak var _fullPreloader: UIView!
  @IBOutlet private weak var _fullPreloaderActivity: UIActivityIndicatorView!
  @IBOutlet private weak var _progressView: UIProgressView!

  override func viewDidLoad() {
      super.viewDidLoad()
    FileManager.createDefaults()
    FileManager.clearTmpFolder()
//      setupNavBar()
    
    func sharedDirectoryURL() -> URL {
      return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constant.groupID)!
    }
    
    self._handleSharedFile { (exported) in
      
      guard !exported.isEmpty else {
        self.showAlert(.somethingWentWrong) { _ in
          let error = NSError(domain: "com.textr", code: 0, userInfo: [NSLocalizedDescriptionKey: "Undefined file"])
          self.extensionContext?.cancelRequest(withError: error)
        }
        return
      }
      
      let group = DispatchGroup()

      var audios = [ExportedFile]()
      var texts = [ExportedFile]()
      
      exported.forEach {
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
        var transcribedItemsCount = 0
        let result = (audios + texts).sorted(by: < )

        Recognizer.recognizeExported(files: result, in: UserDefaults.standard.extractingLocale) { text in
          transcribedItemsCount += 1
          print(CGFloat(transcribedItemsCount / result.count))
          print(Float(transcribedItemsCount / result.count))
          let progress: Float = Float(transcribedItemsCount) / Float(result.count)
          self._progressView.setProgress(progress, animated: true)
          guard !text.isEmpty else { return }
          self._hidePreloader()
          self.textView.text = self.textView.text + "\n" + text
        }
      }
    }
  }
  
  // 3: Define the actions for the navigation items
  @IBAction private func _cancelAction () {
    let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
    extensionContext?.cancelRequest(withError: error)
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
    UserDefaults.standard.documentsToImport = [document]
    
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
  
  
  private func _showPreloader() {
    self._fullPreloaderActivity.startAnimating()
    self._fullPreloader.showAnimated()
  }
  
  private func _hidePreloader() {
    self._fullPreloader.hideAnimated()
  }
  
  private func _handleSharedFile(completion: @escaping (([ExportedFile]) -> Void)) {
    
    self._showPreloader()
    // extracting the path to the URL that is being shared
    let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        
    let group = DispatchGroup()
    var exported = [ExportedFile]()
    
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
      completion([])

//      completion(exported)
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
