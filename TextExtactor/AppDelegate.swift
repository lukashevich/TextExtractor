//
//  AppDelegate.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    print(FileManager.content(from: FileManager.documentsFolder.appendingPathComponent("trim.89BCAA65-6866-4A03-A7D7-B1D0577A8AD2")))
    print(FileManager.content(from: FileManager.documentsFolder.appendingPathComponent("trim.87755BAB-4992-4F74-A90C-328E8D20A3E0")))
    print(FileManager.content(from: FileManager.documentsFolder.appendingPathComponent("trim.B5ECC20F-3721-4049-8596-30D8CF0B351A")))
//    FileManager.clearDocFolder()
    _createDefaultsFolders()

    return true
  }

  private func _createDefaultsFolders() {
    FileManager.createDefaults()
  }
  
  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}

