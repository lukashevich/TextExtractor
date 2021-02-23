//
//  NewDocument.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit
import UICircularProgressRing

final class NewDocumentController: UIViewController, TabBared {
  
  @IBOutlet weak var fileView: TitledActionView!
  @IBOutlet weak var locationView: TitledActionView!

  @IBOutlet weak var newDocumentTextView: UITextView!
  
  @IBOutlet weak var actionProgressView: UICircularProgressRing!
  @IBOutlet weak var actionButton: UIButton!
      
  var viewModel = NewDocumentViewModel()
  private var _expandedCell: ExpandableCell?

  private var _document: Document?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.actionProgressView.maxValue = 1.0

    self.viewModel.splittingHandlder = {
      self.actionProgressView.enable()
    }
    
    self.viewModel.processStepHandler = { step in
      switch step {
      case .start:
        self.newDocumentTextView.text = ""
        self.newDocumentTextView.textColor = .label
        self.actionProgressView.disable()
      case .recognized(let text):
        self.newDocumentTextView.typeOn(string: text)
      case .progress(let progress):
        self.actionProgressView.startProgress(to: progress, duration: 0.2)
      case .finish:
        self.actionProgressView.enable()
      
        guard let text = self.newDocumentTextView.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        self._showExtractErrorWarning()
      }
    }
    
    _clearFileViews()
    
    _updateLocaleView()
    
    guard !FileManager.savedDocuments.isEmpty else { return }
    select(tab: .recents)
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
    actionProgressView.disable()
    newDocumentTextView.text = nil
  }
  
  private func _updateLocaleView() {
    locationView.title = UserDefaults.standard.extractingLocale.country ?? ""
    locationView.subtitle = UserDefaults.standard.extractingLocale.identifier
    viewModel.prepareForLocalize()
    guard viewModel.fileUrl != nil else { return }
    
    actionProgressView.enable()
  }

  @IBAction func chooseFilePressed() {
    //    viewModel.loadVideo()
    let alert = UIAlertController(title: "Choose file", message: "from", preferredStyle: .actionSheet)
    alert.view.tintColor = UIColor.accentColor
    alert.addAction(UIAlertAction(title: "Files", style: .default , handler:{ (UIAlertAction)in
      self._clearFileViews()
      self.pickFileFromCloud()
    }))
    
    alert.addAction(UIAlertAction(title: "Library", style: .default , handler:{ (UIAlertAction)in
      self._clearFileViews()
      self.pickFileLibrary()
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
    switch viewModel.isDocumentReady {
    case false: viewModel.startProcessing()
    case true:
      
      func success() {
        viewModel.saveDocument()
        select(tab: .recents)
      }
      
      guard !UserDefaults.standard.shouldShowPaywall else {
        self.showPaywall(successHandler: success)
        return
      }
      
      success()
    }
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
