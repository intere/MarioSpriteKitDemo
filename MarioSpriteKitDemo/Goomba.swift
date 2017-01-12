//
//  Goomba.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/11/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

class Goomba: SpriteRenderable {

    public var sprite = Goomba.createSprite()

    static func createSprite() -> SKSpriteNode {
        let texture = SKTexture.goomba[0]
        let node = SKSpriteNode(texture: texture)
        node.setScale(Constants.scale)
        node.zPosition = 5

        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.density = 1
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = false

        return node
    }
    
}

// MARK: - Enemy

extension Goomba: Enemy {

    func startMoving() {
        sprite.run(SKAction.animate(with: SKTexture.goomba, timePerFrame: 0.2, resize: true, restore: true))
        sprite.run(SKAction.repeatForever(SKAction.moveBy(x: -15, y: 0, duration: 0.2)))
    }
}
