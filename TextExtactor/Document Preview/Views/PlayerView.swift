//
//  PlayerView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 11.03.2021.
//

import Foundation
import AVFoundation
import DSWaveformImage
import UIKit

@IBDesignable
final class PlayerView: UIControl {
  
  @IBOutlet private weak var _playButton: UIButton!
  @IBOutlet private weak var _waveformImage: WaveformImageView!

  var contentView:UIView?
  private var _player: AVAudioPlayer?

  var fileUrl: URL? {
    didSet {
      guard let url = fileUrl else {
        _player = nil
        return
      }
      _player = try? AVAudioPlayer(contentsOf: url)
      _player?.delegate = self
      _waveformImage.waveformAudioURL = url
    }
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    xibSetup()
  }
  
  func xibSetup() {
    guard let view = loadViewFromNib() else { return }
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
    contentView = view
    _waveformImage.waveformStyle = .striped(.accentColor)
  }
  
  func loadViewFromNib() -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "PlayerView", bundle: bundle)
    return nib.instantiate(
      withOwner: self,
      options: nil).first as? UIView
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    xibSetup()
    contentView?.prepareForInterfaceBuilder()
  }
  
 
  @IBAction func action(_ sender: Any) {
    guard let player = _player else {
      return
    }
    
    switch player.isPlaying {
    case true:
      player.pause()
      _playButton.pause()
    case false:
      player.play()
      _playButton.play()
    }
  }
}

extension PlayerView: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    _playButton.pause()
  }
}


private extension UIButton {
  func play() {
    setImage(UIImage(systemName: "pause.fill"), for: .normal)
  }
  
  func pause() {
    setImage(UIImage(systemName: "play.fill"), for: .normal)
  }
}
