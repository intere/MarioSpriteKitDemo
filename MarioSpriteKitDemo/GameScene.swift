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
    static let scale: CGFloat = 2.0
}

/// Responsible for managing the Scene
public class GameScene: SKScene {
    var mario = Mario.shared

    public init(view: SKView) {
        super.init(size: view.frame.size)
        setUp()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
}

// MARK: - Overrides

extension GameScene {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y >= frame.size.height / 2 {
                // User touched upper half of the screen
                mario.jump()
            } else if location.x <= frame.size.width / 2 {
                // User touched left side of the screen
                mario.runLeft()
            } else {
                // User touched right side of the screen
                mario.runRight()
            }
        }
    }

}

// MARK: - Helpers

private extension GameScene {

    /// Sets up the scene
    func setUp() {
        addMario()
        addBricks()
    }

    /// Adds Mario to the Scene
    func addMario() {
        let sprite = mario.sprite
        sprite.position = CGPoint(x: frame.minX + sprite.frame.size.width, y: frame.midY)
        addChild(sprite)
    }

    /// Adds the bricks to the bottom of the scene
    func addBricks() {
        guard let brickNode = Brick().sprite else {
            print("ERROR: Couldn't get the brick sprite")
            return
        }
        let brickCount = Int(size.width / brickNode.size.width) + 2  // Let's add a couple extra

        for i in 0..<brickCount {
            guard let brick = Brick().sprite else {
                print("ERROR: Couldn't get the brick sprite")
                continue
            }
            brick.position = CGPoint(x: frame.minX + CGFloat(i) * brickNode.size.width, y: frame.minY)
            addChild(brick)
        }
    }
    
}

