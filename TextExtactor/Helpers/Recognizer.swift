//
//  Recognizer.swift
//  TextExtactor
//

import Foundation
import Speech

final class Recognizer {
  static var locales: [Locale] { Array(SFSpeechRecognizer.supportedLocales()) }
  static var groupedLocales: [String?: [Locale]] {
    locales.group(by: \.language.languageCode?.identifier)
  }

  private static let _stateQueue = DispatchQueue(label: "com.textextractor.speech-state")
  private static var _stopped = false
  private static var _activeTask: SFSpeechRecognitionTask?

  static func checkStatus(completion: @escaping (Bool) -> Void) {
    SFSpeechRecognizer.requestAuthorization { status in
      completion(status == .authorized)
    }
  }

  static func isAvailable(for locale: Locale) -> Bool {
    SFSpeechRecognizer(locale: locale)?.isAvailable == true
  }

  static func validateRecord(at url: URL, in locale: Locale, completion: ((Bool) -> Void)? = nil) {
    guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
      completion?(false)
      return
    }

    let request = SFSpeechURLRecognitionRequest(url: url)
    recognizer.recognitionTask(with: request) { result, _ in
      completion?(result?.isFinal == true)
    }
  }

  static func recognizeMedia(at url: URL, in locale: Locale, completion: ((String?, TranscribeError?) -> Void)? = nil) {
    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
      completion?(nil, .noPermission)
      return
    }

    guard recognizer.isAvailable else {
      completion?(nil, .notAvailable)
      return
    }

    let request = SFSpeechURLRecognitionRequest(url: url)
    request.taskHint = .dictation
    request.addsPunctuation = true
    request.shouldReportPartialResults = false

    var didFinish = false
    var task: SFSpeechRecognitionTask?
    task = recognizer.recognitionTask(with: request) { result, error in
      guard !didFinish else { return }

      if let result, result.isFinal {
        didFinish = true
        _complete(task)
        completion?(result.bestTranscription.formattedString, nil)
        return
      }

      if error != nil {
        didFinish = true
        _complete(task)
        completion?(nil, _isStopped ? .cancelled : .failed)
      }
    }
    _activate(task)
  }

  static func recognizeMedia(
    at urls: [URL],
    in locale: Locale,
    newText: @escaping (String, Int) -> Void,
    didProcess: ((Int) -> Void)? = nil,
    completion: ((TranscribeError?) -> Void)? = nil
  ) {
    var remainingURLs = urls
    var firstError: TranscribeError?

    func recognizeNext(at index: Int) {
      guard let url = remainingURLs.first else {
        completion?(firstError)
        return
      }

      guard !_isStopped else {
        completion?(.cancelled)
        return
      }

      recognizeMedia(at: url, in: locale) { text, error in
        guard !_isStopped else {
          completion?(.cancelled)
          return
        }

        remainingURLs.removeFirst()
        if let text, !text.isEmpty {
          newText(text, index)
        } else if firstError == nil {
          firstError = error ?? .failed
        }

        didProcess?(index)
        recognizeNext(at: index + 1)
      }
    }

    guard !urls.isEmpty else {
      completion?(.failed)
      return
    }

    recognizeNext(at: 0)
  }

  static func enableRecognizing() {
    _stateQueue.sync {
      _stopped = false
    }
  }

  static func stopRecognizing() {
    _stateQueue.sync {
      _stopped = true
      _activeTask?.cancel()
      _activeTask = nil
    }
  }

  private static var _isStopped: Bool {
    _stateQueue.sync { _stopped }
  }

  private static func _activate(_ task: SFSpeechRecognitionTask?) {
    _stateQueue.sync {
      _activeTask?.cancel()
      _activeTask = task
    }
  }

  private static func _complete(_ task: SFSpeechRecognitionTask?) {
    _stateQueue.sync {
      guard let task, _activeTask === task else { return }
      _activeTask = nil
    }
  }
}
