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
class ImportController: UIViewController {
  override func viewDidLoad() {
      super.viewDidLoad()

    FileManager.createDefaults()

      setupNavBar()
    
    self.handleSharedFile()
  }

  // 2: Set the title and the navigation items
  private func setupNavBar() {
      self.navigationItem.title = "My app"

      let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
      self.navigationItem.setLeftBarButton(itemCancel, animated: false)

      let itemDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
      self.navigationItem.setRightBarButton(itemDone, animated: false)
  }

  // 3: Define the actions for the navigation items
  @objc private func cancelAction () {
      let error = NSError(domain: "some.bundle.identifier", code: 0, userInfo: [NSLocalizedDescriptionKey: "An error description"])
      extensionContext?.cancelRequest(withError: error)
  }

  @objc private func doneAction() {
      extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
  
  private func handleSharedFile() {
    // extracting the path to the URL that is being shared
    let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
    
    print(attachments.map(\.suggestedName))
    
    attachments.forEach { attachment in
      if attachment.hasItemConformingToTypeIdentifier("public.file-url" as String) {
        // extension is being called e.g. from Mail app
        attachment.loadItem(forTypeIdentifier: "public.file-url" as String, options: nil) { (data, error) in
          if let sourcePKPassURL = data as? URL {
            print("preparing...")

            self.prepareFile(at: sourcePKPassURL) { url in
              Recognizer.recognizeMedia(at: url, in: .current) { text in
                print("FUCKING", text)
              }
            }
          }
        }
      }
    }
//    let contentType = kUTTypeData as String
//    for provider in attachments {
//      // Check if the content type is the same as we expected
//      if provider.hasItemConformingToTypeIdentifier(contentType) {
//        provider.loadItem(forTypeIdentifier: contentType,
//                          options: nil) { [unowned self] (data, error) in
//        // Handle the error here if you want
//        guard error == nil else { return }
//
//        if let url = data as? URL,
//           let imageData = try? Data(contentsOf: url) {
//             self.save(imageData, key: "imageData", value: imageData)
//        } else {
//          // Handle this situation as you prefer
//          fatalError("Impossible to save image")
//        }
//      }}
//    }
  }
  
  
  func prepareFile(at url: URL, completion: @escaping ((URL) -> Void) ) {
    let asset = AVURLAsset(url: url)
    FileManager.clearTmpFolder()
    print("start writte...")

    let pathWhereToSave = FileManager.tmpFolder.path + "/temp.mp4"
    asset.writeAudioTrackToURL(URL(fileURLWithPath: pathWhereToSave)) { (success, error) -> () in
      print("writed AudioTrackToURL", success, error)

      if success {
        completion(url)
      }
    }
  }
}
