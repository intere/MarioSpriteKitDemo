//
//  AppDelegate.swift
//  MarioSpriteKitDemo
//
//  Super Mario Bros Clone - SpriteKit Edition
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause game when app becomes inactive
        GameState.shared.gameMode = .paused
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save game state if needed
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Prepare to resume
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Resume game if it was paused
        if GameState.shared.gameMode == .paused {
            GameState.shared.gameMode = .playing
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save any final state
    }
}
