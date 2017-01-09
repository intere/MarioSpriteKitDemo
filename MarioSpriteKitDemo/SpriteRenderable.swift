//
//  SpriteRenderable.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

public protocol SpriteRenderable {
    /// The Sprite Node instance for this type
    var sprite: SKSpriteNode { get }


    /// Creates the sprite
    ///
    /// - Returns: an SKSpriteNode (for creating the sprite)
    static func createSprite() -> SKSpriteNode
}
