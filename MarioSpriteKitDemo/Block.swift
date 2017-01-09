//
//  Block.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

public class Block: SpriteRenderable {
    /// The Sprite Node instance for this type
    public var sprite = Block.createSprite()


    /// Creates the Sprite
    ///
    /// - Returns: A SpriteNode for mario.
    public static func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture.block)
        node.setScale(Constants.scale)

        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.density = 1
        node.physicsBody?.isDynamic = false
        node.physicsBody?.allowsRotation = false

        return node
    }
}
