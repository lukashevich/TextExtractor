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
    case .video, .audio:
      self.titleText.text = doc.name
      self.text.text = doc.text
      self.player.fileUrl = viewModel.isNew ? AudioEditHelper.preparedAudioURL : doc.audioLink
    case .picture:
      self.player.isHidden = true
      self.titleText.text = doc.name
      self.text.text = doc.text
    }

    _configureTimelineMenu()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    guard isBeingDismissed || navigationController?.isBeingDismissed == true else { return }
    player.stopPlayback()
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
    
    let oldDoc = self.viewModel.document
    let newDoc = self.viewModel.document.copy(name: name, text: text)

    guard !oldDoc.isEqual(newDoc) || viewModel.isNew else {
      self.dismiss(animated: true, completion: nil)
      return
    }

    let audioSourceURL: URL?
    switch oldDoc.source {
    case .audio, .video:
      audioSourceURL = viewModel.isNew ? AudioEditHelper.preparedAudioURL : oldDoc.audioLink
    case .picture:
      audioSourceURL = nil
    }

    do {
      try newDoc.saveReplacing(
        viewModel.isNew ? nil : oldDoc,
        audioSourceURL: audioSourceURL,
        timeline: viewModel.timeline
      )
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

  private func _configureTimelineMenu() {
    guard !viewModel.timeline.isEmpty else { return }

    let actions = viewModel.timeline.map { item in
      UIAction(title: "\(_formattedTime(item.startTime))  \(_timelinePreview(item.text))") { [weak self] _ in
        self?.player.seek(to: item.startTime)
      }
    }
    let button = UIBarButtonItem(
      title: "Timeline",
      image: UIImage(systemName: "list.bullet"),
      primaryAction: nil,
      menu: UIMenu(title: "Timeline", children: actions)
    )
    navigationItem.rightBarButtonItems = [navigationItem.rightBarButtonItem, button].compactMap { $0 }
  }

  private func _formattedTime(_ time: TimeInterval) -> String {
    let totalSeconds = Int(time.rounded(.down))
    return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
  }

  private func _timelinePreview(_ text: String) -> String {
    let singleLine = text.replacingOccurrences(of: "\n", with: " ")
    let preview = String(singleLine.prefix(48))
    return singleLine.count > preview.count ? preview + "…" : preview
  }
}
