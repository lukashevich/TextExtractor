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
    case start
    case recognized(String)
    case progress(CGFloat)
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
      AudioEditHelper.prepareFile(at: url) { urls, error in
        
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
  
  private var _recognizedTexts: [String] = []
  private var _splittedSource: [URL] = []
  
  private func _processFile() {
    guard !_splittedSource.isEmpty else { return }
    
    self._recognizedTexts = []
    
    DispatchQueue.main.async {
      self.processStepHandler?(.start)
    }
    let step = CGFloat(1.0 / Float(_splittedSource.count))
    Recognizer.recognizeMedia(at: _splittedSource, in: _locale) { text in
      DispatchQueue.main.async {
        self._recognizedTexts.append(text)
        DispatchQueue.main.async {
          self.processStepHandler?(.recognized(text))
          let progress = CGFloat(self._recognizedTexts.count) * step
          self.processStepHandler?(.progress(progress))
        }
        guard self._recognizedTexts.count == self._splittedSource.count else { return }
        self._finishProcessing(text: self._recognizedTexts.joined(separator: " "))
      }
    }
    
//    Recognizer.recognizeMediaConcurrently(at: _splittedSource, in: _locale) { (newText, index) in
//    }
  }
  
  func clearData() {
    fileUrl = nil
    document = nil
    _recognizedTexts = []
    _splittedSource = []
  }
  
  func stopExtracting() {
    Recognizer.stopRecognizing()
  }
  
  func prepareForLocalize() {
    document = nil
    _recognizedTexts = []
  }
  
  func startProcessing() {
    Recognizer.checkStatus { (authorized) in
      switch authorized {
      case true:  self._processFile()
      case false: break
      }
    }
  }
  
  func stopExtractingAndSaveDocument() {
    self.stopExtracting()
    self._finishProcessing(text: self._recognizedTexts.joined(separator: " "))
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
