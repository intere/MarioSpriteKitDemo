//
//  Mario.swift
//  MarioSpriteKitDemo
//
//  The player character - Mario!
//

import SpriteKit

/// Mario's current action state
enum MarioState {
    case idle
    case walking
    case running
    case jumping
    case falling
    case skidding
    case crouching
    case climbing
    case dying
    case flagSlide
    case enteringPipe
}

/// Mario player class
class Mario: SKSpriteNode {

    // MARK: - Properties

    /// Current action state
    var state: MarioState = .idle {
        didSet {
            if state != oldValue {
                updateAnimation()
            }
        }
    }

    /// Direction Mario is facing (true = right)
    var facingRight: Bool = true {
        didSet {
            xScale = facingRight ? 1.0 : -1.0
        }
    }

    /// Is Mario on the ground?
    var isGrounded: Bool = false

    /// Is the jump button being held?
    var isJumpHeld: Bool = false

    /// Can Mario jump? (prevents double jump)
    var canJump: Bool = true

    /// Is Mario currently invincible (after damage)?
    var isInvincible: Bool = false

    /// Current horizontal movement input (-1 = left, 0 = none, 1 = right)
    var moveInput: CGFloat = 0

    /// Is run button pressed?
    var isRunning: Bool = false

    /// Ground detection sensor
    private var groundSensor: SKNode?

    /// Reference to animations
    private var animations: [String: SKAction] = [:]

    // MARK: - Initialization

    init() {
        // Start with small Mario texture (standing pose)
        let texture = SKTexture(imageNamed: "mario_003_0043")
        let size = CGSize(width: GameConstants.tileSize * 0.8, height: GameConstants.tileSize * 0.95)

        super.init(texture: texture, color: .clear, size: size)

        self.name = "mario"
        self.zPosition = GameConstants.ZPosition.player

        setupPhysics()
        setupAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics() {
        // Main physics body - slightly smaller than sprite for better feel
        let bodySize = CGSize(width: size.width * 0.7, height: size.height * 0.9)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.enemyTop |
                                          PhysicsCategory.coin | PhysicsCategory.powerup |
                                          PhysicsCategory.hazard | PhysicsCategory.flagpole
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.block | PhysicsCategory.pipe
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0
        physicsBody?.mass = 1.0
        physicsBody?.linearDamping = 0
    }

    private func setupAnimations() {
        // Small Mario animations (using available sprite frames)
        // Frame 43 = idle, 44-46 = walk, 47 = skid, 50 = jump
        animations["small_idle"] = SKAction.setTexture(SKTexture(imageNamed: "mario_003_0043"))

        animations["small_walk"] = createAnimation(
            baseNames: ["mario_003_0044", "mario_003_0045", "mario_003_0046"],
            duration: GameConstants.Animation.marioWalk
        )

        animations["small_run"] = createAnimation(
            baseNames: ["mario_003_0044", "mario_003_0045", "mario_003_0046"],
            duration: GameConstants.Animation.marioRun
        )

        animations["small_jump"] = SKAction.setTexture(SKTexture(imageNamed: "mario_003_0050"))

        animations["small_skid"] = SKAction.setTexture(SKTexture(imageNamed: "mario_003_0047"))

        // Big Mario animations (using same for now, would need separate sprites)
        animations["big_idle"] = animations["small_idle"]
        animations["big_walk"] = animations["small_walk"]
        animations["big_run"] = animations["small_run"]
        animations["big_jump"] = animations["small_jump"]
        animations["big_skid"] = animations["small_skid"]

        // Fire Mario animations (using same for now)
        animations["fire_idle"] = animations["small_idle"]
        animations["fire_walk"] = animations["small_walk"]
        animations["fire_run"] = animations["small_run"]
        animations["fire_jump"] = animations["small_jump"]
        animations["fire_skid"] = animations["small_skid"]
    }

    private func createAnimation(baseNames: [String], duration: TimeInterval) -> SKAction {
        let textures = baseNames.map { SKTexture(imageNamed: $0) }
        return SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: duration))
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        guard state != .dying && state != .flagSlide && state != .enteringPipe else { return }

        updateMovement(deltaTime: deltaTime)
        updateState()
        checkGrounded()
    }

    private func updateMovement(deltaTime: TimeInterval) {
        guard let body = physicsBody else { return }

        let targetSpeed = isRunning ? GameConstants.Mario.runSpeed : GameConstants.Mario.walkSpeed
        let acceleration = isGrounded ? GameConstants.Mario.acceleration : GameConstants.Mario.acceleration * GameConstants.Mario.airControlFactor

        var velocity = body.velocity

        if moveInput != 0 {
            // Accelerate towards target speed
            let targetVelocity = moveInput * targetSpeed
            let velocityDiff = targetVelocity - velocity.dx

            if abs(velocityDiff) > 1 {
                velocity.dx += velocityDiff.sign * acceleration * CGFloat(deltaTime)
            } else {
                velocity.dx = targetVelocity
            }

            // Clamp to max speed
            velocity.dx = velocity.dx.clamped(to: -GameConstants.Mario.maxVelocityX...GameConstants.Mario.maxVelocityX)

            // Update facing direction
            facingRight = moveInput > 0

        } else if isGrounded {
            // Decelerate when no input (only on ground)
            if abs(velocity.dx) > 1 {
                velocity.dx -= velocity.dx.sign * GameConstants.Mario.deceleration * CGFloat(deltaTime)
            } else {
                velocity.dx = 0
            }
        }

        body.velocity = velocity
    }

    private func updateState() {
        guard let body = physicsBody else { return }

        if state == .dying { return }

        // Check for skidding (moving opposite to velocity)
        let isSkidding = isGrounded && moveInput != 0 && (moveInput * body.velocity.dx < 0) && abs(body.velocity.dx) > 50

        if !isGrounded {
            if body.velocity.dy > 0 {
                state = .jumping
            } else {
                state = .falling
            }
        } else if isSkidding {
            state = .skidding
        } else if abs(body.velocity.dx) > 10 {
            state = isRunning && abs(body.velocity.dx) > GameConstants.Mario.walkSpeed * 0.9 ? .running : .walking
        } else {
            state = .idle
        }
    }

    private func checkGrounded() {
        // Simple ground check based on vertical velocity
        // In a full implementation, this would use raycasting or a sensor
        guard let body = physicsBody else { return }

        let wasGrounded = isGrounded

        // Consider grounded if vertical velocity is very low
        if abs(body.velocity.dy) < 1 && state != .jumping {
            isGrounded = true
            canJump = true
        }

        // Reset jump if we just landed
        if isGrounded && !wasGrounded {
            canJump = true
        }
    }

    // MARK: - Actions

    func jump() {
        guard canJump && isGrounded && state != .dying else { return }

        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: GameConstants.Mario.jumpForce))
        isGrounded = false
        canJump = false
        state = .jumping

        // Play jump sound
        run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
    }

    func variableJump() {
        // Called when jump button is released early for variable jump height
        guard let body = physicsBody, body.velocity.dy > 0 else { return }

        // Reduce upward velocity for shorter jump
        body.velocity.dy *= 0.5
    }

    func takeDamage() {
        guard !isInvincible && state != .dying else { return }

        let gameState = GameState.shared

        if gameState.isStarPowered { return }

        if gameState.powerState == .small {
            // Die
            die()
        } else {
            // Power down
            gameState.powerState = .small
            updateSizeForPowerState()
            becomeInvincible()

            // Play power down sound
            run(SKAction.playSoundFileNamed("powerdown.wav", waitForCompletion: false))
        }
    }

    func collectPowerup(_ type: PowerupType) {
        let gameState = GameState.shared

        switch type {
        case .mushroom:
            if gameState.powerState == .small {
                gameState.powerState = .big
                updateSizeForPowerState()
                gameState.addScore(GameConstants.Collectibles.mushroomPoints)
            }

        case .fireFlower:
            if gameState.powerState != .fire {
                gameState.powerState = .fire
                updateSizeForPowerState()
                gameState.addScore(GameConstants.Collectibles.fireFlowerPoints)
            }

        case .star:
            gameState.isStarPowered = true
            gameState.addScore(GameConstants.Collectibles.starPoints)
            // Start star power effect
            startStarPower()

        case .oneUp:
            gameState.addLife()
        }

        run(SKAction.playSoundFileNamed("powerup.wav", waitForCompletion: false))
    }

    func die() {
        guard state != .dying else { return }

        state = .dying
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = 0

        // Death animation - jump up then fall
        let deathSequence = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.physicsBody?.velocity = .zero
                self?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))
            },
            SKAction.playSoundFileNamed("death.wav", waitForCompletion: false),
            SKAction.wait(forDuration: 3.0),
            SKAction.run {
                NotificationCenter.default.post(name: .marioDidDie, object: nil)
            }
        ])

        run(deathSequence)
    }

    // MARK: - Power State

    private func updateSizeForPowerState() {
        let gameState = GameState.shared

        let newSize: CGSize
        switch gameState.powerState {
        case .small:
            newSize = CGSize(width: GameConstants.tileSize * 0.8, height: GameConstants.tileSize * 0.95)
        case .big, .fire:
            newSize = CGSize(width: GameConstants.tileSize * 0.8, height: GameConstants.tileSize * 1.9)
        }

        // Animate size change
        let growAction = SKAction.resize(toWidth: newSize.width, height: newSize.height, duration: 0.5)
        run(growAction)

        // Update physics body
        let bodySize = CGSize(width: newSize.width * 0.7, height: newSize.height * 0.9)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        setupPhysics()
    }

    private func becomeInvincible() {
        isInvincible = true

        // Flashing effect
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let flashRepeat = SKAction.repeat(flash, count: Int(GameConstants.Mario.invincibilityDuration / 0.2))

        run(flashRepeat) { [weak self] in
            self?.isInvincible = false
            self?.alpha = 1.0
        }
    }

    private func startStarPower() {
        // Color cycling effect for star power
        let colors: [SKColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
        var colorActions: [SKAction] = []

        for color in colors {
            colorActions.append(SKAction.colorize(with: color, colorBlendFactor: 0.5, duration: 0.1))
        }

        let colorCycle = SKAction.repeatForever(SKAction.sequence(colorActions))
        run(colorCycle, withKey: "starPower")

        // End star power after duration
        run(SKAction.wait(forDuration: GameConstants.Mario.starDuration)) { [weak self] in
            self?.removeAction(forKey: "starPower")
            self?.colorBlendFactor = 0
            GameState.shared.isStarPowered = false
        }
    }

    // MARK: - Animation

    private func updateAnimation() {
        removeAction(forKey: "animation")

        let prefix: String
        switch GameState.shared.powerState {
        case .small: prefix = "small"
        case .big: prefix = "big"
        case .fire: prefix = "fire"
        }

        let animationKey: String
        switch state {
        case .idle:
            animationKey = "\(prefix)_idle"
        case .walking:
            animationKey = "\(prefix)_walk"
        case .running:
            animationKey = "\(prefix)_run"
        case .jumping, .falling:
            animationKey = "\(prefix)_jump"
        case .skidding:
            animationKey = "\(prefix)_skid"
        default:
            animationKey = "\(prefix)_idle"
        }

        if let animation = animations[animationKey] {
            run(animation, withKey: "animation")
        }
    }

    // MARK: - Flag Pole

    func grabFlagpole() {
        state = .flagSlide
        physicsBody?.velocity = .zero
        physicsBody?.affectedByGravity = false

        // Slide down animation
        let slideDown = SKAction.moveBy(x: 0, y: -300, duration: 1.5)
        run(slideDown) { [weak self] in
            self?.walkTowardsCastle()
        }
    }

    private func walkTowardsCastle() {
        physicsBody?.affectedByGravity = true
        state = .walking
        facingRight = true

        // Walk right towards castle
        let walkAction = SKAction.moveBy(x: 200, duration: 2.0)
        run(walkAction) {
            NotificationCenter.default.post(name: .levelComplete, object: nil)
        }
    }

    /// Called when Mario lands on the ground
    func landed() {
        isGrounded = true
        canJump = true
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let marioDidDie = Notification.Name("marioDidDie")
    static let levelComplete = Notification.Name("levelComplete")
}

// MARK: - Helper Extensions

extension CGFloat {
    var sign: CGFloat {
        return self >= 0 ? 1 : -1
    }

    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
