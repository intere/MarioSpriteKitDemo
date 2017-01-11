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
        SpriteModel(type: "brick", index: 0, height: 2),
        SpriteModel(type: "brick", index: 1, height: 2),
        SpriteModel(type: "brick", index: 2, height: 2),
        SpriteModel(type: "brick", index: 3, height: 2),
        SpriteModel(type: "brick", index: 4, height: 2),
        SpriteModel(type: "brick", index: 5, height: 2),
        SpriteModel(type: "brick", index: 6, height: 2),
        SpriteModel(type: "brick", index: 7, height: 2),
        SpriteModel(type: "brick", index: 8, height: 2),
        SpriteModel(type: "brick", index: 9, height: 2),
        SpriteModel(type: "empty", index: 10, height: 2),
        SpriteModel(type: "empty", index: 11, height: 2),
        SpriteModel(type: "empty", index: 12, height: 2),
        SpriteModel(type: "pad_top", index: 13, height: 2),
        SpriteModel(type: "empty", index: 14, height: 2),
        SpriteModel(type: "empty", index: 15, height: 2),
        SpriteModel(type: "empty", index: 16, height: 2),
        SpriteModel(type: "brick", index: 17, height: 2),

        SpriteModel(type: "bush", index: 7, height: 3),

        SpriteModel(type: "block", index: 4, height: 6),
        SpriteModel(type: "mario", index: 4, height: 3)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            var models = [SpriteModel]()
            self.models.forEach { models.append($0) }
            for i in 18...250 {
                models.append(SpriteModel(type: "brick", index: i, height: 2))
            }
            let scene = GameScene(view: view, spriteModels: models )
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
