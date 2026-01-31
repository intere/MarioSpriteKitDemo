//
//  Goomba.swift
//  MarioSpriteKitDemo
//
//  The classic Goomba enemy
//

import SpriteKit

class Goomba: Enemy {

    // MARK: - Initialization

    init(position: CGPoint) {
        super.init(type: .goomba, position: position)
        self.moveSpeed = GameConstants.Enemy.goombaSpeed
        self.pointValue = 100
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func setupAnimation() {
        let walkTextures = [
            SKTexture(imageNamed: "goomba_1"),
            SKTexture(imageNamed: "goomba_2")
        ]

        let walkAnimation = SKAction.animate(with: walkTextures,
                                              timePerFrame: GameConstants.Animation.goombaWalk)
        run(SKAction.repeatForever(walkAnimation), withKey: "walk")
    }

    // MARK: - Death

    override func performDeathAnimation() {
        removeAction(forKey: "walk")

        // Change to flattened texture
        texture = SKTexture(imageNamed: "goomba_dead")

        physicsBody?.categoryBitMask = 0
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 0
        physicsBody?.velocity = .zero

        // Flatten and remove
        let deathSequence = SKAction.sequence([
            SKAction.scaleY(to: 0.3, duration: 0.1),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])
        run(deathSequence)
    }
}
