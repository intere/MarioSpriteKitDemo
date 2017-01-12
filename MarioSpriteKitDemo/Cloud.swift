//
//  Cloud.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/11/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

class Cloud: SpriteRenderable {
    var sprite = Cloud.createSprite()

    /// Creates the sprite
    ///
    /// - Returns: an SKSpriteNode (for creating the sprite)
    public static func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture.clouds.random)
        node.setScale(Constants.scale)
        node.zPosition = 1

        return node
    }
    
}

