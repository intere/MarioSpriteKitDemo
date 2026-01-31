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

        // Create and configure the menu scene
        let scene = MenuScene(size: CGSize(
            width: GameConstants.sceneWidth,
            height: GameConstants.sceneHeight
        ))
        scene.scaleMode = .aspectFill

        // Present the scene
        view.presentScene(scene)

        // Configure view
        view.ignoresSiblingOrder = true

        // Debug info (disable for release)
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
