//
//  AVAsset+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import AVFoundation

enum TranscribeError: Error {
  case unknown
  case waiting
  case exporting
  case failed
  case cancelled
  case notAvailable
  case noPermission
  case timer
  
  init?(status: AVAssetExportSession.Status) {
    switch status {
    case .unknown: self = .unknown
    case .waiting: self = .waiting
    case .exporting: self = .exporting
    case .failed: self = .failed
    case .cancelled: self = .cancelled
    default: return nil
    }
  }
}

extension AVAsset {
  
  func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, TranscribeError?) -> ()) {
    do {
      let audioAsset = try self.audioAsset()
      audioAsset.writeToURL(url, completion: completion)
    } catch {
      completion(false, .failed)
    }
  }
  
  func writeToURL(_ url: URL, completion: @escaping (Bool, TranscribeError?) -> ()) {
    
    guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetLowQuality) else {
      completion(false, nil)
      return
    }
    
    exportSession.outputFileType = .mp4
    exportSession.outputURL      = url
    
    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .completed:
        completion(true, nil)
      case .unknown, .waiting, .exporting, .failed, .cancelled:
        completion(false, TranscribeError(status: exportSession.status))
      @unknown default:
        completion(false, nil)
      }
    }
  }
  
  func audioAsset() throws -> AVAsset {
    
    let composition = AVMutableComposition()
    let audioTracks = tracks(withMediaType: .audio)
    
    for track in audioTracks {
      
      let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
      try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
      compositionTrack?.preferredTransform = track.preferredTransform
    }
    return composition
  }
}
