//
//  PlayerCamera.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/11/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

public class PlayerCameraNode: SKCameraNode {

    let player: SKSpriteNode
    let blockSize: CGFloat

    public init(player: SKSpriteNode, blockSize: CGFloat) {
        self.player = player
        self.blockSize = blockSize
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func update(_ currentTime: TimeInterval) {
        position = CGPoint(x: player.position.x, y: player.position.y + blockSize * 2)
    }

}
