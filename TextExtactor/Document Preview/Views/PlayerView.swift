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
  private let _playedWaveformContainer = UIView()
  private let _playedWaveformImage = UIImageView()
  private let _waveformDrawer = WaveformImageDrawer()
  private var _playedWaveformWidth: NSLayoutConstraint?
  private var _playbackProgress: CGFloat = 0
  private var _displayLink: CADisplayLink?
  private var _waveformURL: URL?
  private var _waveformRenderID = UUID()
  private var _renderedWaveformSize: CGSize = .zero

  var fileUrl: URL? {
    didSet {
      _loadAudio()
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
    contentView?.layer.cornerRadius = 14
    contentView?.layer.cornerCurve = .continuous
    contentView?.clipsToBounds = true
    _configurePlayedWaveform()
    _playButton.pause()
    _playButton.isEnabled = false
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
      _stopProgressUpdates()
      _playButton.pause()
    case false:
      if player.currentTime >= player.duration {
        player.currentTime = 0
        _setPlaybackProgress(0)
      }
      if player.play() {
        _startProgressUpdates()
        _playButton.play()
      }
    }
  }

  func seek(to time: TimeInterval) {
    guard let player = _player, player.duration > 0 else { return }

    let duration = player.duration
    guard duration.isFinite, duration > 0 else { return }

    player.currentTime = min(max(0, time), duration)
    _setPlaybackProgress(_progress(for: player, duration: duration))
    if player.play() {
      _startProgressUpdates()
      _playButton.play()
    }
  }

  func stopPlayback() {
    _player?.stop()
    _player?.currentTime = 0
    _stopProgressUpdates()
    _setPlaybackProgress(0)
    _playButton.pause()
  }

  private func _loadAudio() {
    _player?.stop()
    _player = nil
    _stopProgressUpdates()
    _setPlaybackProgress(0)
    _waveformRenderID = UUID()
    _waveformURL = nil
    _renderedWaveformSize = .zero
    _waveformImage.image = nil
    _playedWaveformImage.image = nil
    _playButton.pause()
    _playButton.isEnabled = false

    guard let url = fileUrl,
          FileManager.default.fileExists(atPath: url.path)
    else {
      return
    }

    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, mode: .default)
      try audioSession.setActive(true)

      let player = try AVAudioPlayer(contentsOf: url)
      player.delegate = self
      player.prepareToPlay()
      _player = player
      _playButton.isEnabled = true
      _waveformURL = url
      _renderWaveformsIfPossible()
    } catch {
      print("Could not load audio player: \(error)")
    }
  }

  private func _configurePlayedWaveform() {
    guard _playedWaveformContainer.superview == nil else { return }

    _waveformImage.clipsToBounds = true
    _playedWaveformContainer.translatesAutoresizingMaskIntoConstraints = false
    _playedWaveformContainer.clipsToBounds = true
    _playedWaveformImage.translatesAutoresizingMaskIntoConstraints = false
    _playedWaveformImage.contentMode = .scaleToFill
    _playedWaveformContainer.addSubview(_playedWaveformImage)
    _waveformImage.addSubview(_playedWaveformContainer)

    _playedWaveformWidth = _playedWaveformContainer.widthAnchor.constraint(equalToConstant: 0)
    NSLayoutConstraint.activate([
      _playedWaveformContainer.leadingAnchor.constraint(equalTo: _waveformImage.leadingAnchor),
      _playedWaveformContainer.topAnchor.constraint(equalTo: _waveformImage.topAnchor),
      _playedWaveformContainer.bottomAnchor.constraint(equalTo: _waveformImage.bottomAnchor),
      _playedWaveformWidth!,
      _playedWaveformImage.leadingAnchor.constraint(equalTo: _playedWaveformContainer.leadingAnchor),
      _playedWaveformImage.topAnchor.constraint(equalTo: _playedWaveformContainer.topAnchor),
      _playedWaveformImage.bottomAnchor.constraint(equalTo: _playedWaveformContainer.bottomAnchor),
      _playedWaveformImage.widthAnchor.constraint(equalTo: _waveformImage.widthAnchor)
    ])
  }

  private func _startProgressUpdates() {
    guard _displayLink == nil else { return }
    let displayLink = CADisplayLink(target: self, selector: #selector(_updatePlaybackProgress))
    displayLink.add(to: .main, forMode: .common)
    _displayLink = displayLink
  }

  private func _stopProgressUpdates() {
    _displayLink?.invalidate()
    _displayLink = nil
  }

  @objc private func _updatePlaybackProgress() {
    guard let player = _player else { return }
    let duration = player.duration
    _setPlaybackProgress(_progress(for: player, duration: duration))
  }

  private func _progress(for player: AVAudioPlayer, duration: TimeInterval) -> CGFloat {
    guard duration.isFinite, duration > 0,
          player.currentTime.isFinite
    else {
      return 0
    }
    return CGFloat(player.currentTime / duration)
  }

  private func _setPlaybackProgress(_ progress: CGFloat) {
    _playbackProgress = min(max(progress, 0), 1)
    _playedWaveformWidth?.constant = _waveformImage.bounds.width * _playbackProgress
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    _setPlaybackProgress(_playbackProgress)
    _renderWaveformsIfPossible()
  }

  private func _renderWaveformsIfPossible() {
    guard let url = _waveformURL,
          _waveformImage.bounds.width > 0,
          _waveformImage.bounds.height > 0,
          _waveformImage.bounds.size != _renderedWaveformSize
    else {
      return
    }

    let size = _waveformImage.bounds.size
    let renderID = UUID()
    _waveformRenderID = renderID
    _renderedWaveformSize = size

    _waveformDrawer.waveformImage(
      fromAudioAt: url,
      size: size,
      style: .striped(.tertiaryLabel)
    ) { [weak self] image in
      DispatchQueue.main.async {
        guard let self, self._waveformRenderID == renderID else { return }
        self._waveformImage.image = image
      }
    }
    _waveformDrawer.waveformImage(
      fromAudioAt: url,
      size: size,
      style: .striped(.accentColor)
    ) { [weak self] image in
      DispatchQueue.main.async {
        guard let self, self._waveformRenderID == renderID else { return }
        self._playedWaveformImage.image = image
      }
    }
  }

  deinit {
    stopPlayback()
  }
}

extension PlayerView: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    _stopProgressUpdates()
    _setPlaybackProgress(1)
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
