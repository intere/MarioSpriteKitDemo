//
//  GameViewController.swift
//  MarioSpriteKitDemo
//
//  Main view controller for the game
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else {
            fatalError("View is not an SKView")
        }

        // Use the view's bounds for the scene size
        // This ensures the scene fills the screen properly
        let sceneSize = view.bounds.size

        // Create menu scene that fills the view
        let scene = MenuScene(size: sceneSize)
        scene.scaleMode = .aspectFit

        // Present the scene
        view.presentScene(scene)

        // Configure view
        view.ignoresSiblingOrder = true
        view.isMultipleTouchEnabled = true

        // Debug info
        #if DEBUG
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = false
        #endif
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
