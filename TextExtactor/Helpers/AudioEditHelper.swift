//
//  AudioEditHelper.swift
//  TextExtactor
//

import AVFoundation
import Foundation

struct AudioEditHelper {
  private static let segmentDuration: Double = 45
  private static let overlapDuration: Double = 1.5

  static var preparedAudioURL: URL {
    FileManager.tmpFolder.appendingPathComponent("source").appendingPathExtension("m4a")
  }

  static func timelineStart(forSegmentAt index: Int) -> TimeInterval {
    Double(index) * (segmentDuration - overlapDuration)
  }

  static func moveTempAudioFile(to url: URL) {
    guard FileManager.default.fileExists(atPath: preparedAudioURL.path) else { return }

    do {
      try? FileManager.default.removeItem(at: url)
      try FileManager.default.copyItem(at: preparedAudioURL, to: url)
    } catch {
      print("Could not save audio: \(error)")
    }
  }

  static func prepareFile(at url: URL, completion: @escaping ([URL], TranscribeError?) -> Void) {
    FileManager.clearTmpFolder()

    let asset = AVURLAsset(url: url)
    asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
      var error: NSError?
      guard asset.statusOfValue(forKey: "duration", error: &error) == .loaded,
            asset.statusOfValue(forKey: "tracks", error: &error) == .loaded,
            asset.duration.seconds.isFinite,
            asset.duration.seconds > 0,
            !asset.tracks(withMediaType: .audio).isEmpty
      else {
        completion([], .failed)
        return
      }

      _exportAudioTrack(from: asset, to: preparedAudioURL) { result in
        switch result {
        case .failure(let error):
          completion([], error)
        case .success:
          let chunks = _makeChunks(for: asset.duration.seconds)
          guard !chunks.isEmpty else {
            completion([], .failed)
            return
          }
          _exportChunks(from: AVURLAsset(url: preparedAudioURL), chunks: chunks, completion: completion)
        }
      }
    }
  }

  private static func _makeChunks(for duration: Double) -> [AudioChunk] {
    let durationInMilliseconds = Int((duration * 1_000).rounded(.up))
    let chunkDuration = Int(segmentDuration * 1_000)
    let overlap = Int(overlapDuration * 1_000)
    let step = chunkDuration - overlap

    guard durationInMilliseconds > 0, step > 0 else { return [] }
    guard durationInMilliseconds > chunkDuration else {
      return [AudioChunk(start: 0, duration: durationInMilliseconds)]
    }

    var chunks: [AudioChunk] = []
    var start = 0

    while start < durationInMilliseconds {
      let remaining = durationInMilliseconds - start
      chunks.append(AudioChunk(start: start, duration: min(chunkDuration, remaining)))
      guard remaining > chunkDuration else { break }
      start += step
    }

    return chunks
  }

  private static func _exportAudioTrack(from asset: AVAsset, to outputURL: URL, completion: @escaping (Result<Void, TranscribeError>) -> Void) {
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
      completion(.failure(.failed))
      return
    }

    try? FileManager.default.removeItem(at: outputURL)
    exportSession.outputURL = outputURL
    exportSession.outputFileType = .m4a
    exportSession.exportAsynchronously {
      guard exportSession.status == .completed,
            FileManager.default.fileExists(atPath: outputURL.path)
      else {
        completion(.failure(TranscribeError(status: exportSession.status) ?? .failed))
        return
      }
      completion(.success(()))
    }
  }

  private static func _exportChunks(from asset: AVAsset, chunks: [AudioChunk], completion: @escaping ([URL], TranscribeError?) -> Void) {
    var urls: [URL] = []

    func exportChunk(at index: Int) {
      guard index < chunks.count else {
        completion(urls, nil)
        return
      }

      let outputURL = FileManager.tmpFolder.appendingPathComponent("chunk_\(index)").appendingPathExtension("m4a")
      guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
        completion([], .failed)
        return
      }

      try? FileManager.default.removeItem(at: outputURL)
      exportSession.outputURL = outputURL
      exportSession.outputFileType = .m4a
      let chunk = chunks[index]
      exportSession.timeRange = CMTimeRange(
        start: CMTime(value: Int64(chunk.start), timescale: 1_000),
        duration: CMTime(value: Int64(chunk.duration), timescale: 1_000)
      )

      exportSession.exportAsynchronously {
        guard exportSession.status == .completed,
              FileManager.default.fileExists(atPath: outputURL.path)
        else {
          completion([], TranscribeError(status: exportSession.status) ?? .failed)
          return
        }
        urls.append(outputURL)
        exportChunk(at: index + 1)
      }
    }

    exportChunk(at: 0)
  }
}
