//
//  PadBottom.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

public class PadBottom: SpriteRenderable {

    public var sprite = PadBottom.createSprite()

    /// Creates the sprite
    ///
    /// - Returns: an SKSpriteNode (for creating the sprite)
    public static func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture.padBottom)
        node.setScale(Constants.scale)

        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.density = 1
        node.physicsBody?.isDynamic = false
        node.physicsBody?.allowsRotation = false

        return node
    }
    
}
