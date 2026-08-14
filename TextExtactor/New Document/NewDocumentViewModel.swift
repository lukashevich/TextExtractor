//
//  NewDocumentViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit
import VisionKit
import Vision
import UniformTypeIdentifiers

final class NewDocumentViewModel {
  
  enum ProcessStep {
    case preparing(String)
    case start
    case recognized(String)
    case progress(completed: Int, total: Int)
    case finish(Document?)
    case error(TranscribeError)
  }
  
  private var _textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
  private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  var processStepHandler: ((ProcessStep) -> Void)?
  var isDocumentReady: Bool = false
  var _locale: Locale {
    UserDefaults.standard.extractingLocale
  }
  
  var document: Document? {
    didSet {
      self.isDocumentReady = self.document != nil
    }
  }
  
  var fileUrl: URL? {
    didSet {
      guard let url = fileUrl else { return }
      DispatchQueue.main.async {
        self.processStepHandler?(.preparing("Preparing audio…"))
      }
      AudioEditHelper.prepareFile(at: url) { urls, error in
        DispatchQueue.main.async {
          guard self.fileUrl == url else { return }

          switch error {
          case .none:
            Recognizer.enableRecognizing()
            self._splittedSource = urls
            self.startProcessing()
          case .some(let error):
            self.processStepHandler?(.error(error))
          }
        }
      }
    }
  }
  
  private var _recognizedTexts: [String] = []
  private var _recognizedTimeline: [TranscriptTimelineItem] = []
  private var _splittedSource: [URL] = []
  private var _processingID: UUID?

  var timeline: [TranscriptTimelineItem] { _recognizedTimeline }
  
  private func _processFile(processingID: UUID) {
    guard !_splittedSource.isEmpty else { return }
    
    self._recognizedTexts = []
    self._recognizedTimeline = []
    
    DispatchQueue.main.async {
      self.processStepHandler?(.start)
    }
    let chunkCount = _splittedSource.count
    Recognizer.recognizeMedia(at: _splittedSource, in: _locale) { text, index in
      DispatchQueue.main.async {
        guard self._processingID == processingID else { return }
        let newText = self._textWithoutOverlap(text)
        guard !newText.isEmpty else { return }
        let separator = self._separator(after: self._recognizedTexts.last ?? "")
        self._recognizedTexts.append(newText)
        self._recognizedTimeline.append(
          TranscriptTimelineItem(
            startTime: AudioEditHelper.timelineStart(forSegmentAt: index),
            text: newText
          )
        )
        self.processStepHandler?(.recognized(separator + newText))
      }
    } didProcess: { index in
      DispatchQueue.main.async {
        guard self._processingID == processingID else { return }
        self.processStepHandler?(.progress(completed: index + 1, total: chunkCount))
      }
    } completion: { error in
      DispatchQueue.main.async {
        guard self._processingID == processingID else { return }
        self._processingID = nil

        guard !self._recognizedTexts.isEmpty else {
          self.processStepHandler?(.error(error ?? .failed))
          return
        }

        self._finishProcessing(text: self._formattedTranscript())
      }
    }
  }
  
  func clearData() {
    stopExtracting()
    fileUrl = nil
    document = nil
    _recognizedTexts = []
    _recognizedTimeline = []
    _splittedSource = []
  }
  
  func stopExtracting() {
    _processingID = nil
    Recognizer.stopRecognizing()
  }
  
  func prepareForLocalize() {
    stopExtracting()
    document = nil
    _recognizedTexts = []
    _recognizedTimeline = []
  }
  
  func startProcessing() {
    guard !_splittedSource.isEmpty else { return }
    let processingID = UUID()
    _processingID = processingID
    Recognizer.enableRecognizing()
    Recognizer.checkStatus { (authorized) in
      DispatchQueue.main.async {
        guard self._processingID == processingID else { return }
        switch authorized {
        case true:
          guard Recognizer.isAvailable(for: self._locale) else {
            self._processingID = nil
            self.processStepHandler?(.error(.notAvailable))
            return
          }
          self._processFile(processingID: processingID)
        case false:
          self._processingID = nil
          self.processStepHandler?(.error(.noPermission))
        }
      }
    }
  }
  
  func stopExtractingAndSaveDocument() {
    self.stopExtracting()
    self._finishProcessing(text: self._formattedTranscript())
  }
 
  private func _finishProcessing(text: String) {
    
    switch fileUrl?.type {
    case .none:
      self.document = Document(
        name: String.newIncrementedName,
        text: text,
        createdAt: Date(),
        modifiedAt: Date(),
        source: .picture)
    case .some(let type):
      self.document = Document(
        name: fileUrl?.deletingPathExtension().lastPathComponent ?? "",
        text: text,
        createdAt: Date(),
        modifiedAt: Date(),
        source: type)
    }
    
    DispatchQueue.main.async {
      self.processStepHandler?(.finish(self.document))
    }
  }

  private func _textWithoutOverlap(_ text: String) -> String {
    let incomingWords = text
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(whereSeparator: \.isWhitespace)
      .map(String.init)
    guard let previousText = _recognizedTexts.last, !incomingWords.isEmpty else {
      return incomingWords.joined(separator: " ")
    }

    let previousWords = previousText
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(whereSeparator: \.isWhitespace)
      .map(String.init)
    let maximumOverlap = min(20, previousWords.count, incomingWords.count)

    for overlap in stride(from: maximumOverlap, through: 1, by: -1) {
      let suffix = previousWords.suffix(overlap).map { $0.lowercased() }
      let prefix = incomingWords.prefix(overlap).map { $0.lowercased() }
      if suffix == prefix {
        return incomingWords.dropFirst(overlap).joined(separator: " ")
      }
    }

    return incomingWords.joined(separator: " ")
  }

  private func _formattedTranscript() -> String {
    _recognizedTexts.reduce("") { transcript, part in
      transcript + (transcript.isEmpty ? "" : _separator(after: transcript)) + part
    }
  }

  private func _separator(after text: String) -> String {
    guard let previousCharacter = text.trimmingCharacters(in: .whitespacesAndNewlines).last else {
      return ""
    }

    switch previousCharacter {
    case ".", "!", "?", "…", "。", "！", "？":
      return "\n\n"
    default:
      return " "
    }
  }
}

extension NewDocumentViewModel {
  func processImage(_ image: UIImage) {
    self.recognizeTextInImage(image)
  }
  
  func recognizeTextInImage(_ image: UIImage) {
    guard let cgImage = image.cgImage else { return }
    
    DispatchQueue.main.async {
      self.processStepHandler?(.start)
    }
    
    textRecognitionWorkQueue.async {
      let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      do {
        try requestHandler.perform([self._textRecognitionRequest])
      } catch {
        print(error)
      }
    }
  }
  
  func setupVision() {
    self._textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
      
      var detectedText = ""
      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { return }
        
        detectedText += topCandidate.string
        detectedText += "\n"
        
        DispatchQueue.main.async {
          self.processStepHandler?(.recognized(topCandidate.string))
        }
      }
      
      DispatchQueue.main.async {
        self._finishProcessing(text: detectedText)
      }
    }
    
    self._textRecognitionRequest.recognitionLevel = .accurate
  }
  
  func compressedImage(_ originalImage: UIImage) -> UIImage {
    guard let imageData = originalImage.jpegData(compressionQuality: 1),
          let reloadedImage = UIImage(data: imageData) else {
      return originalImage
    }
    return reloadedImage
  }
}
