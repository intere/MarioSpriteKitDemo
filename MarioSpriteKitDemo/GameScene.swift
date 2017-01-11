//
//  GameScene.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Constants {
    static let scale: CGFloat = 1
    static let marioScale: CGFloat = 2
}

/// Responsible for managing the Scene
public class GameScene: SKScene {
    var mario = Mario.shared
    var engine: LevelEngine?

    public init(view: SKView, spriteModels: [SpriteModel]) {
        super.init(size: view.frame.size)
        let engine = LevelEngine(scene: self, spriteModels: spriteModels)
        engine.renderAll()
        let camera = PlayerCameraNode(player: mario.sprite, blockSize: engine.blockSize)
        addChild(camera)
        self.camera = camera
        self.engine = engine
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Overrides

extension GameScene {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = view else {
            return
        }
        for touch in touches {
            let location = touch.location(in: view)

            if location.y <= view.frame.size.height / 2 {
                // User touched upper half of the screen
                mario.jump()
            } else if location.x <= view.frame.size.width / 2 {
                // User touched left side of the screen
                mario.runLeft()
            } else {
                // User touched right side of the screen
                mario.runRight()
            }
        }
    }

    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        for node in children {
            node.update(currentTime)
        }
    }

}

// MARK: - Helpers

private extension GameScene {

}

