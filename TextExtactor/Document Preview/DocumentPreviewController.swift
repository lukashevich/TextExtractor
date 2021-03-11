//
//  DocumentPreviewController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import UIKit

final class DocumentPreviewController: UIViewController {
  
  @IBOutlet weak var titleText: UITextField!
  @IBOutlet weak var text: UITextView!
  @IBOutlet weak var player: PlayerView!

  var viewModel: DocumentPreviewViewModel! 
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.modalPresentationStyle = .fullScreen
    
    self.titleText.text = viewModel.document.name
    self.text.text = viewModel.document.text
    self.player.fileUrl = viewModel.document.audioLink
//    FileManager.tmpFolder.appendingPathComponent("temp").appendingPathExtension("m4a")
    print("---> ", FileManager.content(from: FileManager.tmpFolder))

  }
  
  @IBAction func cancel() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save() {
    
    guard let name = titleText.text, !name.isEmpty,
          let text = text.text, !text.isEmpty else {
      self.dismiss(animated: true, completion: nil)
      return
    }
    
    let doc = viewModel.document.copy(name: name, text: text)

//    guard !doc.isEqual(viewModel.document) else {
//      self.dismiss(animated: true, completion: nil)
//      return
//    }

    doc.createFile()
    self.dismiss(animated: true, completion: AppStoreReviewHelper.askForReviewIfNeeded)
  }
}
