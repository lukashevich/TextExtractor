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
    
    self.isModalInPresentation = true
    
    let doc = viewModel.document
    switch doc.source {
    case .media:
      self.titleText.text = doc.name
      self.text.text = doc.text
      self.player.fileUrl = doc.audioLink
    case .photo:
      self.player.isHidden = true
      self.titleText.text = doc.name
      self.text.text = doc.text
    }
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
    
    let document = self.viewModel.document.copy(name: name, text: text)

//    guard !doc.isEqual(viewModel.document) else {
//      self.dismiss(animated: true, completion: nil)
//      return
//    }

    document.createFile()
    UIApplication.dismissToRoot()
  }
}
