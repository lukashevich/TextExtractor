//
//  VideoPlayerController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.08.2021.
//

import Foundation
import AVKit

@IBDesignable class VideoPlayerController: AVPlayerViewController {
  
  private var _videoName: String? = nil
  private var _observer: NSKeyValueObservation?

  @IBOutlet private weak var _phoneBackground: UIImageView!

  private var _videoLooper: AVPlayerLooper?
  
  @IBInspectable var source: String {
    get { return _videoName ?? "" }
    set(source) {
      _videoName = source
      play()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    showsPlaybackControls = false
    videoGravity = .resizeAspectFill
  }
  
  func play() {
    guard let videoURL = Bundle.main.url(forResource: source.fileName,
                                         withExtension: source.fileExtension) else { return }
    
    view.alpha = 0.0
    let asset = AVAsset(url: videoURL)
    let playerItem = AVPlayerItem(asset: asset)
    player = AVPlayer(playerItem: playerItem)
    
    player?.actionAtItemEnd = .none
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(playerDidEnd(notification:)),
                                           name: .AVPlayerItemDidPlayToEndTime,
                                           object: player?.currentItem)

    
    _observer = playerItem.observe(\.status, options:  [.new, .old], changeHandler: { [unowned self] (playerItem, change) in
      switch playerItem.status {
      case .readyToPlay: view.alpha = 1.0
      default: view.alpha = 0.0
      }
    })
    player?.play()
  }
  
  @objc func playerDidEnd(notification: Notification) {
    if let playerItem = notification.object as? AVPlayerItem {
      playerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
  }
  
  func stop() {
    
  }
}
