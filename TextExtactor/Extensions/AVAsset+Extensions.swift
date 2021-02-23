//
//  AVAsset+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import AVFoundation

extension AVAsset {
  
  func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
    do {
      let audioAsset = try self.audioAsset()
      audioAsset.writeToURL(url, completion: completion)
    } catch (let error as NSError){
      completion(false, error)
    }
  }
  
  func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
    
    guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
      completion(false, nil)
      return
    }
    
    exportSession.outputFileType = .m4a
    exportSession.outputURL      = url
    
    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .completed:
        completion(true, nil)
      case .unknown, .waiting, .exporting, .failed, .cancelled:
        completion(false, nil)
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
