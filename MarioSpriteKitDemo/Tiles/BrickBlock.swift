//
//  BrickBlock.swift
//  MarioSpriteKitDemo
//
//  Breakable brick blocks
//

import SpriteKit

class BrickBlock: Tile {

    // MARK: - Properties

    /// What this brick contains (if anything)
    var contents: BlockContents = .empty

    /// Has this brick been broken/used?
    var isBroken: Bool = false

    /// Number of coins (for multi-coin bricks)
    var coinCount: Int = 0

    // MARK: - Initialization

    init(gridPosition: (x: Int, y: Int), contents: BlockContents = .empty) {
        self.contents = contents
        super.init(type: .brick, gridPosition: gridPosition)

        if contents == .multiCoin {
            coinCount = 10 // 10 coins in multi-coin blocks
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interactions

    override func hitFromBelow(by player: Mario) {
        guard !isBroken else { return }

        let gameState = GameState.shared

        // Check if Mario can break bricks
        if gameState.powerState.canBreakBricks && contents == .empty {
            breakBrick()
        } else {
            // Bounce animation
            bounce()

            // Release contents if any
            if contents != .empty {
                releaseContents()
            }
        }
    }

    // MARK: - Actions

    private func bounce() {
        let bounceUp = SKAction.moveBy(x: 0, y: GameConstants.Blocks.bounceHeight, duration: GameConstants.Blocks.bounceDuration / 2)
        bounceUp.timingMode = .easeOut

        let bounceDown = SKAction.moveBy(x: 0, y: -GameConstants.Blocks.bounceHeight, duration: GameConstants.Blocks.bounceDuration / 2)
        bounceDown.timingMode = .easeIn

        let bounceSequence = SKAction.sequence([bounceUp, bounceDown])
        run(bounceSequence)

        // Check for enemies standing on top
        bumpEnemiesAbove()
    }

    private func breakBrick() {
        isBroken = true

        // Play break sound
        run(SKAction.playSoundFileNamed("brick_break.wav", waitForCompletion: false))

        // Create brick particles
        createBreakParticles()

        // Add points
        GameState.shared.addScore(50)

        // Remove brick
        removeFromParent()
    }

    private func createBreakParticles() {
        guard let scene = self.scene else { return }

        // Create 4 brick fragment pieces
        for i in 0..<GameConstants.Blocks.brickParticles {
            let fragment = SKSpriteNode(color: .brown, size: CGSize(width: 8, height: 8))
            fragment.position = position
            fragment.zPosition = GameConstants.ZPosition.effects

            // Give each fragment a different velocity
            let xVelocity: CGFloat = (i % 2 == 0) ? -100 : 100
            let yVelocity: CGFloat = (i < 2) ? 300 : 200

            scene.addChild(fragment)

            // Animate the fragment
            let physics = SKPhysicsBody(rectangleOf: fragment.size)
            physics.categoryBitMask = 0
            physics.collisionBitMask = 0
            physics.velocity = CGVector(dx: xVelocity, dy: yVelocity)
            physics.affectedByGravity = true
            fragment.physicsBody = physics

            // Remove after falling
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ])
            fragment.run(removeAction)
        }
    }

    private func releaseContents() {
        switch contents {
        case .coin:
            spawnCoin()
            convertToUsedBlock()

        case .multiCoin:
            spawnCoin()
            coinCount -= 1
            if coinCount <= 0 {
                convertToUsedBlock()
            }

        case .mushroom:
            spawnPowerup(.mushroom)
            convertToUsedBlock()

        case .fireFlower:
            // Spawn mushroom if small, fire flower if big
            if GameState.shared.powerState == .small {
                spawnPowerup(.mushroom)
            } else {
                spawnPowerup(.fireFlower)
            }
            convertToUsedBlock()

        case .star:
            spawnPowerup(.star)
            convertToUsedBlock()

        case .oneUp:
            spawnPowerup(.oneUp)
            convertToUsedBlock()

        case .empty:
            break
        }
    }

    private func spawnCoin() {
        guard let scene = self.scene else { return }

        let coin = CollectibleCoin(position: CGPoint(x: position.x, y: position.y + GameConstants.tileSize))
        coin.physicsBody?.categoryBitMask = 0 // No collision for spawned coin
        scene.addChild(coin)

        // Coin pop animation
        let popUp = SKAction.moveBy(x: 0, y: GameConstants.tileSize * 2, duration: 0.3)
        let popDown = SKAction.moveBy(x: 0, y: -GameConstants.tileSize * 0.5, duration: 0.2)
        let remove = SKAction.removeFromParent()

        coin.run(SKAction.sequence([popUp, popDown, remove]))

        GameState.shared.addCoins(1)
        run(SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false))
    }

    private func spawnPowerup(_ type: PowerupType) {
        guard let scene = self.scene else { return }

        let powerup = Powerup(type: type, position: CGPoint(x: position.x, y: position.y))
        scene.addChild(powerup)

        // Rise out of block
        powerup.riseFromBlock()

        run(SKAction.playSoundFileNamed("powerup_appears.wav", waitForCompletion: false))
    }

    private func convertToUsedBlock() {
        contents = .empty
        texture = SKTexture(imageNamed: "item_used")
    }

    private func bumpEnemiesAbove() {
        guard let scene = self.scene else { return }

        // Check for enemies directly above this block
        let checkPoint = CGPoint(x: position.x, y: position.y + GameConstants.tileSize)
        let checkSize = CGSize(width: size.width * 0.8, height: GameConstants.tileSize * 0.5)

        scene.enumerateChildNodes(withName: "enemy") { node, _ in
            if let enemy = node as? Enemy {
                let enemyFrame = enemy.frame
                let checkFrame = CGRect(origin: CGPoint(x: checkPoint.x - checkSize.width/2,
                                                         y: checkPoint.y - checkSize.height/2),
                                        size: checkSize)
                if enemyFrame.intersects(checkFrame) {
                    enemy.hitByShell() // Same effect as being hit by shell
                }
            }
        }
    }
}
