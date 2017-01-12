//
//  GameViewController.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    let models = [
        SpriteModel(type: "brick", index: 0, endIndex: 9, height: 2),

        SpriteModel(type: "empty", index: 10, endIndex: 13, height: 2),
        SpriteModel(type: "pad_top", index: 14, height: 2),
        SpriteModel(type: "empty", index: 15, endIndex: 18, height: 2),

        SpriteModel(type: "brick", index: 19, endIndex: 250, height: 2),

        SpriteModel(type: "bush", index: 7, height: 3),
        SpriteModel(type: "bush", index: 30, height: 3),
        SpriteModel(type: "bush", index: 55, height: 3),
        SpriteModel(type: "bush", index: 100, height: 3),
        SpriteModel(type: "bush", index: 125, height: 3),

        SpriteModel(type: "cloud", index: 15, height: 10),
        SpriteModel(type: "cloud", index: 33, height: 10),
        SpriteModel(type: "cloud", index: 45, height: 10),
        SpriteModel(type: "cloud", index: 58, height: 10),
        SpriteModel(type: "cloud", index: 66, height: 10),
        SpriteModel(type: "cloud", index: 105, height: 10),
        SpriteModel(type: "cloud", index: 125, height: 10),
        SpriteModel(type: "cloud", index: 175, height: 10),

        SpriteModel(type: "block", index: 25, height: 6),
        SpriteModel(type: "mario", index: 15, height: 3),

        SpriteModel(type: "pipe", index: 30, height: 2),
        SpriteModel(type: "goomba", index: 49, height: 3),
        SpriteModel(type: "pipe", index: 50, height: 2)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(view: view, spriteModels: models)
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
