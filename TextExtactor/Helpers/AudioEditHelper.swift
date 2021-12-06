//
//  AudioEditHelper.swift
//  RnDVAT
//
//  Created by Oleksandr Lukashevych on 12.01.2021.
//

import Foundation
import AVFoundation

struct AudioEditHelper {
  
  static func moveTempAudioFile(to url: URL) {
    let tempURL = FileManager.tmpFolder.appendingPathComponent("temp").appendingPathExtension("m4a")
    let asset = AVURLAsset(url: tempURL)
    asset.writeToURL(url) { _,_  in }
  }
  
  static func prepareFile(at url: URL, completion: @escaping (([URL]) -> Void) ) {
    let asset = AVURLAsset(url: url)
    guard asset.duration.seconds > 60 else {
      FileManager.clearTmpFolder()
      let pathWhereToSave = FileManager.tmpFolder.path + "/temp.m4a"
      asset.writeAudioTrackToURL(URL(fileURLWithPath: pathWhereToSave)) { (success, error) -> () in
        if success {
          completion([url])
        } else {
          completion([])
        }
      }
      return
    }
    AudioFileSplitter.split(file: url, completion: completion)
  }
  
  static func split(asset: AVURLAsset, chunks: [AudioChunk], completion: (([URL]) -> Void)? = nil) {
    let chunksGroup = DispatchGroup()
    var urls = [Int: URL]()
    chunks.enumerated().forEach { (index, chunk) in
      chunksGroup.enter()
      cutAsset(asset, chunk: chunk, index: index)  { index, url in
        urls[index] = url
        chunksGroup.leave()
      }
      chunksGroup.wait()
    }
    
    completion?(urls.sorted(by: { $0.0 < $1.0 }).map{ $0.1 })
  }
  
  private static func cutAsset(_ asset: AVAsset, chunk: AudioChunk, index: Int, completion: ((Int, URL) -> Void)? = nil) {
    
    let trimmedSoundFileURL = FileManager.tmpFolder.appendingPathComponent("chunk_\(index).m4a")
    
    if FileManager.default.fileExists(atPath: trimmedSoundFileURL.path) {
      do {
        if try trimmedSoundFileURL.checkResourceIsReachable() {
          print("is reachable")
        }
        
        try FileManager.default.removeItem(atPath: trimmedSoundFileURL.path)
      } catch {
        print("could not remove \(trimmedSoundFileURL)")
        print(error.localizedDescription)
      }
      
    }
    
    if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
      
      let outputURL = URL(fileURLWithPath: trimmedSoundFileURL.path)
      exporter.outputFileType = AVFileType.m4a
      exporter.outputURL = outputURL
      exporter.shouldOptimizeForNetworkUse = false
      
      let startTime = CMTimeMake(value: Int64(chunk.start), timescale: 1000)
      let duration = CMTimeMake(value: Int64(chunk.duration), timescale: 1000)
      
      exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: startTime + duration)
      
      exporter.exportAsynchronously(completionHandler: {
        switch exporter.status {
        case  .failed:
          completion?(index, outputURL)
          if let e = exporter.error {
            print("export failed \(e)", e.localizedDescription)
          }
          
        case .cancelled:
          completion?(index, outputURL)
          print("export cancelled \(String(describing: exporter.error))")
        case .completed:
          completion?(index, outputURL)
        default:
          completion?(index, outputURL)
          print("export complete")
        }
      })
    } else {
      completion?(index, URL(string: "")!)
      print("cannot create AVAssetExportSession for asset \(asset)")
    }
  }
}
