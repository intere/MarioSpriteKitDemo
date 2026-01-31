//
//  KoopaTroopa.swift
//  MarioSpriteKitDemo
//
//  Koopa Troopa enemy with shell mechanics
//

import SpriteKit

/// Koopa state
enum KoopaState {
    case walking
    case shell       // In shell, stationary
    case sliding     // Shell sliding
    case emerging    // Coming out of shell
}

class KoopaTroopa: Enemy {

    // MARK: - Properties

    var koopaState: KoopaState = .walking
    var shellTimer: TimeInterval = 0
    let shellRecoveryTime: TimeInterval = 5.0
    var isRedKoopa: Bool = false // Red koopas turn at edges

    // MARK: - Initialization

    init(position: CGPoint, isRed: Bool = false) {
        self.isRedKoopa = isRed
        super.init(type: isRed ? .koopaRed : .koopa, position: position)
        self.moveSpeed = GameConstants.Enemy.koopaSpeed
        self.pointValue = 100
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func setupAnimation() {
        let walkTextures = [
            SKTexture(imageNamed: "koopa_1"),
            SKTexture(imageNamed: "koopa_2")
        ]

        let walkAnimation = SKAction.animate(with: walkTextures,
                                              timePerFrame: GameConstants.Animation.koopaWalk)
        run(SKAction.repeatForever(walkAnimation), withKey: "walk")
    }

    // MARK: - Update

    override func update(deltaTime: TimeInterval) {
        guard isAlive else { return }

        switch koopaState {
        case .walking:
            physicsBody?.velocity.dx = moveDirection * moveSpeed

        case .shell:
            physicsBody?.velocity.dx = 0
            shellTimer += deltaTime

            // Start wiggling when about to emerge
            if shellTimer > shellRecoveryTime - 2.0 {
                if action(forKey: "wiggle") == nil {
                    let wiggle = SKAction.sequence([
                        SKAction.rotate(byAngle: 0.1, duration: 0.1),
                        SKAction.rotate(byAngle: -0.2, duration: 0.1),
                        SKAction.rotate(byAngle: 0.1, duration: 0.1)
                    ])
                    run(SKAction.repeatForever(wiggle), withKey: "wiggle")
                }
            }

            // Emerge from shell
            if shellTimer >= shellRecoveryTime {
                emerge()
            }

        case .sliding:
            physicsBody?.velocity.dx = moveDirection * GameConstants.Enemy.shellSpeed

        case .emerging:
            // Animation handles this
            break
        }
    }

    // MARK: - Actions

    override func stomp() {
        guard isAlive && canBeStomped else { return }

        switch koopaState {
        case .walking:
            // Go into shell
            enterShell()
            GameState.shared.addScore(pointValue)

        case .shell:
            // Kick the shell
            kickShell(direction: 1) // Direction based on where Mario is

        case .sliding:
            // Stop the shell
            enterShell()
            GameState.shared.addScore(pointValue)

        case .emerging:
            // Push back into shell
            enterShell()
            GameState.shared.addScore(pointValue)
        }

        run(SKAction.playSoundFileNamed("stomp.wav", waitForCompletion: false))
    }

    func enterShell() {
        koopaState = .shell
        shellTimer = 0
        moveSpeed = 0

        removeAction(forKey: "walk")
        removeAction(forKey: "wiggle")

        // Change to shell texture
        texture = SKTexture(imageNamed: "koopa_shell")

        // Resize to shell
        let shellSize = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize)
        size = shellSize

        // Update physics body
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: shellSize.width * 0.8, height: shellSize.height * 0.8))
        physicsBody?.categoryBitMask = PhysicsCategory.shell
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.block | PhysicsCategory.pipe
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.5
        physicsBody?.restitution = 0.5
    }

    func kickShell(direction: CGFloat) {
        koopaState = .sliding
        moveDirection = direction
        moveSpeed = GameConstants.Enemy.shellSpeed

        // Shells can kill enemies
        physicsBody?.categoryBitMask = PhysicsCategory.shell
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.player | PhysicsCategory.block

        run(SKAction.playSoundFileNamed("kick.wav", waitForCompletion: false))
    }

    func emerge() {
        koopaState = .emerging
        removeAction(forKey: "wiggle")
        zRotation = 0

        // Animation to emerge from shell
        let emergeSequence = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.texture = SKTexture(imageNamed: "koopa_emerging")
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                // Restore to walking state
                self.koopaState = .walking
                self.moveSpeed = GameConstants.Enemy.koopaSpeed

                // Restore size
                let koopaSize = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize * 1.5)
                self.size = koopaSize

                // Restore physics
                self.setupPhysics()
                self.setupAnimation()
            }
        ])
        run(emergeSequence)
    }

    override func hitByShell() {
        // Koopa hit by another shell
        isAlive = false
        GameState.shared.addScore(pointValue)

        let flip = SKAction.sequence([
            SKAction.group([
                SKAction.scaleY(to: -1, duration: 0),
                SKAction.moveBy(x: 0, dy: 100, duration: 0.3)
            ]),
            SKAction.moveBy(x: 0, dy: -300, duration: 0.5),
            SKAction.removeFromParent()
        ])
        run(flip)
    }

    /// Called when shell hits a wall
    func shellBounce() {
        if koopaState == .sliding {
            moveDirection *= -1
        }
    }
}
