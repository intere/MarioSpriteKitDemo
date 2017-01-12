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
    var spriteModels: [SpriteModel]

    public init(view: SKView, spriteModels: [SpriteModel]) {
        self.spriteModels = spriteModels
        super.init(size: view.frame.size)
        let engine = LevelEngine(scene: self, spriteModels: spriteModels)
        engine.renderAll()
        let camera = PlayerCameraNode(player: mario.sprite, blockSize: LevelEngine.blockSize)
        addChild(camera)
        self.camera = camera
        self.engine = engine
    }

    required public init?(coder aDecoder: NSCoder) {
        spriteModels = []
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

        if mario.sprite.position.y < -50 {
            print("Mario is dead")
            for child in children {
                child.removeAllActions()
            }
            Mario.shared.reset()
            removeAllChildren()
            guard let view = view else {
                return
            }
            view.presentScene(GameScene(view: view, spriteModels: spriteModels), transition: .doorway(withDuration: 2))
        }
    }

}

// MARK: - Helpers

private extension GameScene {

}

