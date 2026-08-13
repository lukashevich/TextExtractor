//
//  DrawerWrapper.swift
//  Sharing
//

import UIKit

/// Hosts the transcriber directly so the share extension has one continuous surface.
final class DrawerWrapper: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    _embedTranscriber()
  }

  private func _embedTranscriber() {
    guard let transcriber = storyboard?.instantiateViewController(withIdentifier: "ImportController") else {
      assertionFailure("MessageTranscriber scene is missing from the storyboard")
      return
    }

    addChild(transcriber)
    transcriber.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(transcriber.view)
    NSLayoutConstraint.activate([
      transcriber.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      transcriber.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      transcriber.view.topAnchor.constraint(equalTo: view.topAnchor),
      transcriber.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    transcriber.didMove(toParent: self)
  }
}
