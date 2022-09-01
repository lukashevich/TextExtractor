//
//  AudioFileSplitter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import AVFoundation
import DSWaveformImage

struct AudioFileSplitter {
  static private func _split(asset: AVURLAsset, completion: @escaping ([AudioChunk], TranscribeError?) -> Void ) {
    let pathWhereToSave = FileManager.tmpFolder.path + "/temp.m4a"
    
    FileManager.clearTmpFolder()
    
    asset.writeAudioTrackToURL(URL(fileURLWithPath: pathWhereToSave)) { (success, error) -> () in
      guard success else {
        completion([], .failed)
        return
      }
      
      let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: URL(fileURLWithPath: pathWhereToSave))
      waveformAnalyzer?.samples(count: Int(asset.duration.miliseconds)) { samples in
        completion(_splitSource(samples), nil)
      }
    }
  }

  static func split(file at: URL, completion: @escaping ([URL]) -> ()) {
    let asset = AVURLAsset(url: at, options: nil)
    self._split(asset: asset) { (chunks, error) in
      AudioEditHelper.split(asset: asset, chunks: chunks) {
        completion($0)
      }
    }
  }
  
  static private func _splitSource(_ source: [Float]?) -> [AudioChunk] {
    guard let source = source else { return [AudioChunk]() }

    let smallestSamples = source.sorted().dropFirst(source.count - 10)

    var result = [[Float]()]
  
    source.enumerated().forEach { index, item in
      if smallestSamples.contains(item) {
        result.append([item])
      } else {
        result[result.count - 1].append(item)
      }
    }
    
    var final = result
      .filter { $0.count > 300 }
      .map(\.count)
      .map{ AudioChunk(start: 0, duration: $0) }
    
    for i in 1..<final.count {
      final[i] = final[i].copy(with: final[i - 1].start + final[i - 1].duration)
    }

    return final
  }
}

