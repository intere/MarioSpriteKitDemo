//
//  Enemy.swift
//  MarioSpriteKitDemo
//
//  Base enemy class and enemy types
//

import SpriteKit

/// Types of enemies
enum EnemyType: String {
    case goomba
    case koopa
    case koopaRed
    case piranha
    case bulletBill
    case hammerBro
}

/// Base class for all enemies
class Enemy: SKSpriteNode {

    // MARK: - Properties

    let enemyType: EnemyType
    var isAlive: Bool = true
    var moveDirection: CGFloat = -1 // -1 = left, 1 = right
    var moveSpeed: CGFloat = 50
    var canBeStomped: Bool = true
    var pointValue: Int = 100

    // MARK: - Initialization

    init(type: EnemyType, position: CGPoint) {
        self.enemyType = type

        let textureName: String
        let size: CGSize

        switch type {
        case .goomba:
            textureName = "goomba_1"
            size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize)
        case .koopa, .koopaRed:
            textureName = "koopa_1"
            size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize * 1.5)
        case .piranha:
            textureName = "piranha_1"
            size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize * 1.5)
        case .bulletBill:
            textureName = "bullet_bill"
            size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize)
        case .hammerBro:
            textureName = "goomba_1" // Placeholder
            size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize * 1.5)
        }

        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: size)

        self.position = position
        self.name = "enemy"
        self.zPosition = GameConstants.ZPosition.enemies

        setupPhysics()
        setupAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setupPhysics() {
        let bodySize = CGSize(width: size.width * 0.8, height: size.height * 0.8)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.fireball | PhysicsCategory.shell
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.block | PhysicsCategory.pipe | PhysicsCategory.enemy
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 0

        // Add top sensor for stomp detection
        let topSensor = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.6, height: 4),
                                       center: CGPoint(x: 0, y: size.height * 0.4))
        topSensor.categoryBitMask = PhysicsCategory.enemyTop
        topSensor.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.playerFeet
        topSensor.collisionBitMask = 0
    }

    func setupAnimation() {
        // Override in subclasses
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        guard isAlive else { return }

        // Basic movement
        physicsBody?.velocity.dx = moveDirection * moveSpeed
    }

    // MARK: - Actions

    func stomp() {
        guard isAlive && canBeStomped else { return }

        isAlive = false
        GameState.shared.addScore(pointValue)

        // Play stomp sound
        run(SKAction.playSoundFileNamed("stomp.wav", waitForCompletion: false))

        // Death animation (override in subclasses for specific behavior)
        performDeathAnimation()
    }

    func hitByFireball() {
        guard isAlive else { return }

        isAlive = false
        GameState.shared.addScore(pointValue)

        // Flip and fall
        let deathAction = SKAction.sequence([
            SKAction.group([
                SKAction.scaleY(to: -1, duration: 0),
                SKAction.moveBy(x: 0, dy: 50, duration: 0.3)
            ]),
            SKAction.moveBy(x: 0, dy: -200, duration: 0.5),
            SKAction.removeFromParent()
        ])
        run(deathAction)
    }

    func hitByShell() {
        hitByFireball() // Same behavior
    }

    func turnAround() {
        moveDirection *= -1
        xScale = moveDirection > 0 ? -1 : 1
    }

    func performDeathAnimation() {
        // Default death animation - flatten
        physicsBody?.categoryBitMask = 0
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 0

        let flatten = SKAction.sequence([
            SKAction.scaleY(to: 0.2, duration: 0.1),
            SKAction.wait(forDuration: 0.5),
            SKAction.removeFromParent()
        ])
        run(flatten)
    }

    func activate() {
        // Called when enemy comes on screen
        // Override in subclasses for specific activation behavior
    }

    func deactivate() {
        // Called when enemy goes off screen
        removeFromParent()
    }
}
