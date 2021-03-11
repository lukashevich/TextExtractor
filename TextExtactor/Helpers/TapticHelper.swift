//
//  TapticHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 24.02.2021.
//

import AudioToolbox

struct TapticHelper {
  static func triple() {
    let cancelled = SystemSoundID(1521)
    AudioServicesPlaySystemSound(cancelled)
  }
  
  static func strong() {
    let pop = SystemSoundID(1520)
    AudioServicesPlaySystemSound(pop)
  }
  
  static func weak() {
    let peek = SystemSoundID(1519)
    AudioServicesPlaySystemSound(peek)
  }
}
