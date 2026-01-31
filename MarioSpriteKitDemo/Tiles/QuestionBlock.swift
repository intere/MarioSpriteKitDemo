//
//  QuestionBlock.swift
//  MarioSpriteKitDemo
//
//  Question mark blocks with items
//

import SpriteKit

/// What a block contains
enum BlockContents {
    case empty
    case coin
    case multiCoin    // Multiple coins
    case mushroom
    case fireFlower   // Becomes mushroom if small Mario
    case star
    case oneUp
}

class QuestionBlock: Tile {

    // MARK: - Properties

    /// What this block contains
    var contents: BlockContents = .coin

    /// Has this block been used?
    var isUsed: Bool = false

    // MARK: - Initialization

    init(gridPosition: (x: Int, y: Int), contents: BlockContents = .coin) {
        self.contents = contents
        super.init(type: .questionBlock, gridPosition: gridPosition)
        setupAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAnimation() {
        // Question block shimmer animation
        let shimmerTextures = [
            SKTexture(imageNamed: "item_block"),
            SKTexture(imageNamed: "item_block_2"),
            SKTexture(imageNamed: "item_block_3"),
            SKTexture(imageNamed: "item_block")
        ]

        // Check if alternate textures exist, if not just use the main one
        let animation = SKAction.animate(with: shimmerTextures,
                                          timePerFrame: GameConstants.Animation.questionBlock)
        run(SKAction.repeatForever(animation), withKey: "shimmer")
    }

    // MARK: - Interactions

    override func hitFromBelow(by player: Mario) {
        guard !isUsed else { return }

        // Bounce animation
        bounce()

        // Release contents
        releaseContents()

        // Mark as used
        isUsed = true
        removeAction(forKey: "shimmer")
        texture = SKTexture(imageNamed: "item_used")
    }

    // MARK: - Actions

    private func bounce() {
        let bounceUp = SKAction.moveBy(x: 0, y: GameConstants.Blocks.bounceHeight, duration: GameConstants.Blocks.bounceDuration / 2)
        bounceUp.timingMode = .easeOut

        let bounceDown = SKAction.moveBy(x: 0, y: -GameConstants.Blocks.bounceHeight, duration: GameConstants.Blocks.bounceDuration / 2)
        bounceDown.timingMode = .easeIn

        run(SKAction.sequence([bounceUp, bounceDown]))

        // Bump enemies on top
        bumpEnemiesAbove()
    }

    private func releaseContents() {
        switch contents {
        case .coin:
            spawnCoin()

        case .multiCoin:
            // This shouldn't happen for question blocks typically
            spawnCoin()

        case .mushroom:
            spawnPowerup(.mushroom)

        case .fireFlower:
            if GameState.shared.powerState == .small {
                spawnPowerup(.mushroom)
            } else {
                spawnPowerup(.fireFlower)
            }

        case .star:
            spawnPowerup(.star)

        case .oneUp:
            spawnPowerup(.oneUp)

        case .empty:
            break
        }
    }

    private func spawnCoin() {
        guard let scene = self.scene else { return }

        let coin = CollectibleCoin(position: CGPoint(x: position.x, y: position.y + GameConstants.tileSize))
        coin.physicsBody?.categoryBitMask = 0
        scene.addChild(coin)

        // Coin pop animation
        let popUp = SKAction.moveBy(x: 0, y: GameConstants.tileSize * 2, duration: 0.3)
        popUp.timingMode = .easeOut
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
        powerup.riseFromBlock()

        run(SKAction.playSoundFileNamed("powerup_appears.wav", waitForCompletion: false))
    }

    private func bumpEnemiesAbove() {
        guard let scene = self.scene else { return }

        let checkPoint = CGPoint(x: position.x, y: position.y + GameConstants.tileSize)
        let checkSize = CGSize(width: size.width * 0.8, height: GameConstants.tileSize * 0.5)

        scene.enumerateChildNodes(withName: "enemy") { node, _ in
            if let enemy = node as? Enemy {
                let enemyFrame = enemy.frame
                let checkFrame = CGRect(origin: CGPoint(x: checkPoint.x - checkSize.width/2,
                                                         y: checkPoint.y - checkSize.height/2),
                                        size: checkSize)
                if enemyFrame.intersects(checkFrame) {
                    enemy.hitByShell()
                }
            }
        }
    }
}
