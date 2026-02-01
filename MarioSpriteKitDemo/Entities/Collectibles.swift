//
//  Collectibles.swift
//  MarioSpriteKitDemo
//
//  Coins and power-ups
//

import SpriteKit

// MARK: - Collectible Coin

class CollectibleCoin: SKSpriteNode {

    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: "coin_1")
        let size = CGSize(width: GameConstants.tileSize * 0.8, height: GameConstants.tileSize)

        super.init(texture: texture, color: .clear, size: size)

        self.position = position
        self.name = "coin"
        self.zPosition = GameConstants.ZPosition.collectibles

        setupPhysics()
        setupAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
    }

    private func setupAnimation() {
        let textures = [
            SKTexture(imageNamed: "coin_1"),
            SKTexture(imageNamed: "coin_2"),
            SKTexture(imageNamed: "coin_3"),
            SKTexture(imageNamed: "coin_4")
        ]

        // If textures don't exist, just use a shimmer effect
        let animation = SKAction.animate(with: textures, timePerFrame: GameConstants.Animation.coinSpin)
        run(SKAction.repeatForever(animation))
    }

    func collect() {
        GameState.shared.addCoins(1)

        // Collection effect
        let sparkle = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.1)
            ]),
            SKAction.removeFromParent()
        ])

        run(sparkle)
        run(SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false))
    }
}

// MARK: - Powerup Types

enum PowerupType: String {
    case mushroom
    case fireFlower
    case star
    case oneUp
}

// MARK: - Powerup

class Powerup: SKSpriteNode {

    let powerupType: PowerupType
    var moveDirection: CGFloat = 1

    init(type: PowerupType, position: CGPoint) {
        self.powerupType = type

        let textureName: String
        switch type {
        case .mushroom:
            textureName = "mushroom_red"
        case .fireFlower:
            textureName = "fire_flower"
        case .star:
            textureName = "star"
        case .oneUp:
            textureName = "mushroom_green"
        }

        let texture = SKTexture(imageNamed: textureName)
        let size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize)

        super.init(texture: texture, color: .clear, size: size)

        self.position = position
        self.name = "powerup"
        self.zPosition = GameConstants.ZPosition.collectibles

        setupPhysics()

        if type == .star {
            setupStarAnimation()
        } else if type == .fireFlower {
            setupFlowerAnimation()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: size.height * 0.8))
        physicsBody?.categoryBitMask = PhysicsCategory.powerup
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.block | PhysicsCategory.pipe
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 0

        // Mushrooms and stars move, flowers don't
        physicsBody?.isDynamic = powerupType != .fireFlower
    }

    private func setupStarAnimation() {
        // Color shimmer for star
        let colors: [SKColor] = [.yellow, .orange, .white]
        var colorActions: [SKAction] = []
        for color in colors {
            colorActions.append(SKAction.colorize(with: color, colorBlendFactor: 0.3, duration: 0.1))
        }
        run(SKAction.repeatForever(SKAction.sequence(colorActions)))
    }

    private func setupFlowerAnimation() {
        // Subtle animation for fire flower
        let textures = [
            SKTexture(imageNamed: "fire_flower"),
            SKTexture(imageNamed: "fire_flower_2"),
            SKTexture(imageNamed: "fire_flower_3"),
            SKTexture(imageNamed: "fire_flower_4")
        ]
        let animation = SKAction.animate(with: textures, timePerFrame: 0.15)
        run(SKAction.repeatForever(animation))
    }

    func riseFromBlock() {
        // Start hidden
        let originalY = position.y

        // Rise up out of block
        let rise = SKAction.moveTo(y: originalY + GameConstants.tileSize, duration: 0.5)
        rise.timingMode = .easeOut

        run(rise) { [weak self] in
            self?.startMoving()
        }
    }

    private func startMoving() {
        guard powerupType == .mushroom || powerupType == .oneUp || powerupType == .star else {
            return
        }

        physicsBody?.affectedByGravity = true

        // Start moving
        if powerupType == .star {
            // Stars bounce
            physicsBody?.restitution = 1.0
            physicsBody?.velocity = CGVector(dx: 100, dy: 200)
        } else {
            // Mushrooms slide
            physicsBody?.velocity = CGVector(dx: 80, dy: 0)
        }
    }

    func update(deltaTime: TimeInterval) {
        guard powerupType == .mushroom || powerupType == .oneUp else { return }

        // Keep moving in current direction
        physicsBody?.velocity.dx = moveDirection * 80
    }

    func turnAround() {
        moveDirection *= -1
    }

    func collect(by player: Mario) {
        player.collectPowerup(powerupType)

        // Collection effect
        let effect = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.1)
            ]),
            SKAction.removeFromParent()
        ])
        run(effect)
    }
}
