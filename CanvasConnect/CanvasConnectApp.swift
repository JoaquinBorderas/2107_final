//
//  CanvasConnectApp.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-04-05.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct CanvasConnectApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @State private var loggedIn = false
  @State private var isUserNameSet: Bool = UserDefaults.standard.string(forKey: "userName") != nil

  var body: some Scene {
    WindowGroup {
      NavigationView {
        if loggedIn {
          if isUserNameSet {
            ContentView(loggedIn: $loggedIn) // Pass the binding here
          } else {
            UserNameView(userNameSet: $isUserNameSet)
          }
        } else {
          LoginPage(loggedIn: $loggedIn)
        }
      }
    }
  }
}
