//
//  Bush.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

class Bush: SpriteRenderable {
    var sprite = Bush.createSprite()

    /// Creates the sprite
    ///
    /// - Returns: an SKSpriteNode (for creating the sprite)
    public static func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture.bushes.random)
        node.setScale(Constants.scale)

        return node
    }

}
