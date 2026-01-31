//
//  GameScene.swift
//  MarioSpriteKitDemo
//
//  Main gameplay scene
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties

    /// The player character
    var mario: Mario!

    /// Level loader
    var levelLoader = LevelLoader()

    /// Camera node for scrolling
    var cameraNode: SKCameraNode!

    /// HUD layer
    var hud: HUD!

    /// Current level data
    var levelData: LevelData!

    /// Time tracking
    var lastUpdateTime: TimeInterval = 0
    var gameTimer: TimeInterval = 0

    /// Touch tracking for controls
    var leftTouchActive = false
    var rightTouchActive = false
    var jumpTouchActive = false
    var runTouchActive = false

    /// Is the game paused?
    var isPaused: Bool = false

    /// Touch control nodes
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var jumpButton: SKSpriteNode!
    var runButton: SKSpriteNode!

    // MARK: - Initialization

    override func didMove(to view: SKView) {
        // Setup physics
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.gravity)
        physicsWorld.contactDelegate = self

        // Setup camera
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)

        // Load level
        levelData = LevelData.level1_1
        mario = levelLoader.loadLevel(levelData, into: self)

        // Setup HUD
        setupHUD()

        // Setup touch controls
        setupTouchControls()

        // Setup notifications
        setupNotifications()

        // Start game
        GameState.shared.gameMode = .playing
        GameState.shared.timeRemaining = levelData.timeLimit

        // Position camera initially
        updateCamera()
    }

    // MARK: - Setup

    private func setupHUD() {
        hud = HUD()
        hud.zPosition = GameConstants.ZPosition.hud
        cameraNode.addChild(hud)
    }

    private func setupTouchControls() {
        let buttonSize = CGSize(width: 60, height: 60)
        let buttonAlpha: CGFloat = 0.4

        // Left button
        leftButton = SKSpriteNode(color: .white, size: buttonSize)
        leftButton.alpha = buttonAlpha
        leftButton.position = CGPoint(x: -size.width/2 + 60, y: -size.height/2 + 60)
        leftButton.name = "leftButton"
        cameraNode.addChild(leftButton)

        // Right button
        rightButton = SKSpriteNode(color: .white, size: buttonSize)
        rightButton.alpha = buttonAlpha
        rightButton.position = CGPoint(x: -size.width/2 + 130, y: -size.height/2 + 60)
        rightButton.name = "rightButton"
        cameraNode.addChild(rightButton)

        // Jump button
        jumpButton = SKSpriteNode(color: .red, size: CGSize(width: 70, height: 70))
        jumpButton.alpha = buttonAlpha
        jumpButton.position = CGPoint(x: size.width/2 - 70, y: -size.height/2 + 70)
        jumpButton.name = "jumpButton"
        cameraNode.addChild(jumpButton)

        // Run button
        runButton = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50))
        runButton.alpha = buttonAlpha
        runButton.position = CGPoint(x: size.width/2 - 140, y: -size.height/2 + 60)
        runButton.name = "runButton"
        cameraNode.addChild(runButton)

        // Add labels
        addButtonLabel(to: leftButton, text: "◀")
        addButtonLabel(to: rightButton, text: "▶")
        addButtonLabel(to: jumpButton, text: "A")
        addButtonLabel(to: runButton, text: "B")
    }

    private func addButtonLabel(to button: SKSpriteNode, text: String) {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(marioDidDie),
                                               name: .marioDidDie, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(levelComplete),
                                               name: .levelComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePipeWarp(_:)),
                                               name: .pipeWarp, object: nil)
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard GameState.shared.gameMode == .playing else { return }

        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update Mario
        mario.update(deltaTime: deltaTime)

        // Update level (enemies, powerups)
        levelLoader.update(deltaTime: deltaTime, cameraX: cameraNode.position.x)

        // Update camera
        updateCamera()

        // Update game timer
        gameTimer += deltaTime
        if gameTimer >= 1.0 {
            gameTimer = 0
            GameState.shared.timeRemaining -= 1
            if GameState.shared.timeRemaining <= 0 {
                mario.die()
            }
        }

        // Update HUD
        hud.update()

        // Check for death (fell off screen)
        if mario.position.y < -GameConstants.tileSize * 2 {
            mario.die()
        }
    }

    private func updateCamera() {
        guard let mario = mario else { return }

        // Camera follows Mario horizontally, stays fixed vertically
        var cameraX = mario.position.x
        let cameraY = size.height / 2

        // Clamp camera to level bounds
        let minX = size.width / 2
        let maxX = CGFloat(levelData.width) * GameConstants.tileSize - size.width / 2

        cameraX = max(minX, min(cameraX, maxX))

        // Smooth camera movement
        let targetPosition = CGPoint(x: cameraX, y: cameraY)
        let smoothing: CGFloat = 0.1
        cameraNode.position.x += (targetPosition.x - cameraNode.position.x) * smoothing
        cameraNode.position.y = targetPosition.y
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            handleTouchDown(at: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle drag between buttons if needed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            handleTouchUp(at: location)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func handleTouchDown(at location: CGPoint) {
        if leftButton.contains(location) {
            leftTouchActive = true
            mario.moveInput = -1
        } else if rightButton.contains(location) {
            rightTouchActive = true
            mario.moveInput = 1
        } else if jumpButton.contains(location) {
            jumpTouchActive = true
            mario.jump()
        } else if runButton.contains(location) {
            runTouchActive = true
            mario.isRunning = true
        }
    }

    private func handleTouchUp(at location: CGPoint) {
        // Check which button was released
        if leftButton.contains(location) || leftTouchActive {
            leftTouchActive = false
            if !rightTouchActive {
                mario.moveInput = 0
            }
        }
        if rightButton.contains(location) || rightTouchActive {
            rightTouchActive = false
            if !leftTouchActive {
                mario.moveInput = 0
            }
        }
        if jumpButton.contains(location) || jumpTouchActive {
            jumpTouchActive = false
            mario.variableJump()
        }
        if runButton.contains(location) || runTouchActive {
            runTouchActive = false
            mario.isRunning = false
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Get nodes
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        // Player + Enemy
        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            handlePlayerEnemyContact(contact)
        }

        // Player + Enemy Top (stomp)
        if collision == PhysicsCategory.player | PhysicsCategory.enemyTop {
            handlePlayerStompEnemy(contact)
        }

        // Player + Coin
        if collision == PhysicsCategory.player | PhysicsCategory.coin {
            if let coin = (nodeA as? CollectibleCoin) ?? (nodeB as? CollectibleCoin) {
                coin.collect()
            }
        }

        // Player + Powerup
        if collision == PhysicsCategory.player | PhysicsCategory.powerup {
            if let powerup = (nodeA as? Powerup) ?? (nodeB as? Powerup) {
                powerup.collect(by: mario)
            }
        }

        // Player + Block (from below)
        if collision == PhysicsCategory.player | PhysicsCategory.block {
            handlePlayerBlockContact(contact)
        }

        // Player + Hazard (death zone)
        if collision == PhysicsCategory.player | PhysicsCategory.hazard {
            mario.die()
        }

        // Player + Flagpole
        if collision == PhysicsCategory.player | PhysicsCategory.flagpole {
            mario.grabFlagpole()
        }

        // Player + Ground (landing)
        if collision == PhysicsCategory.player | PhysicsCategory.ground {
            // Check if landing on top
            if contact.contactNormal.dy > 0.5 {
                mario.landed()
            }
        }

        // Enemy + Ground/Block (turn around at edges or walls)
        if (contact.bodyA.categoryBitMask == PhysicsCategory.enemy ||
            contact.bodyB.categoryBitMask == PhysicsCategory.enemy) {
            if let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) {
                // Turn around when hitting wall
                if abs(contact.contactNormal.dx) > 0.5 {
                    enemy.turnAround()
                }
            }
        }

        // Shell + Enemy
        if collision == PhysicsCategory.shell | PhysicsCategory.enemy {
            if let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) {
                if !(enemy is KoopaTroopa) || (enemy as! KoopaTroopa).koopaState != .sliding {
                    enemy.hitByShell()
                }
            }
        }

        // Shell + Block
        if collision == PhysicsCategory.shell | PhysicsCategory.block {
            if let koopa = (nodeA as? KoopaTroopa) ?? (nodeB as? KoopaTroopa) {
                koopa.shellBounce()
            }
        }
    }

    private func handlePlayerEnemyContact(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        // Determine which is enemy
        guard let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) else { return }

        // Check if it's a shell
        if let koopa = enemy as? KoopaTroopa {
            if koopa.koopaState == .shell {
                // Kick the shell
                let kickDirection: CGFloat = mario.position.x < koopa.position.x ? 1 : -1
                koopa.kickShell(direction: kickDirection)
                // Bounce Mario
                mario.physicsBody?.velocity.dy = GameConstants.Enemy.stompBounce * 0.5
                return
            } else if koopa.koopaState == .sliding {
                // Hit by sliding shell
                if !GameState.shared.isStarPowered {
                    mario.takeDamage()
                }
                return
            }
        }

        // Normal enemy contact
        if GameState.shared.isStarPowered {
            enemy.hitByFireball() // Star power kills enemies
        } else {
            mario.takeDamage()
        }
    }

    private func handlePlayerStompEnemy(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        guard let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) else { return }
        guard let marioBody = mario.physicsBody else { return }

        // Only count as stomp if Mario is falling
        if marioBody.velocity.dy < -50 {
            enemy.stomp()

            // Bounce Mario
            marioBody.velocity.dy = GameConstants.Enemy.stompBounce
        }
    }

    private func handlePlayerBlockContact(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        guard let block = (nodeA as? Tile) ?? (nodeB as? Tile) else { return }
        guard let marioBody = mario.physicsBody else { return }

        // Check if hitting from below (Mario moving up, hit bottom of block)
        if marioBody.velocity.dy > 50 && mario.position.y < block.position.y {
            block.hitFromBelow(by: mario)
        }
    }

    // MARK: - Event Handlers

    @objc private func marioDidDie() {
        let gameOver = GameState.shared.loseLife()

        if gameOver {
            // Show game over screen
            let transition = SKTransition.fade(withDuration: 1.0)
            let gameOverScene = GameOverScene(size: size)
            view?.presentScene(gameOverScene, transition: transition)
        } else {
            // Restart level
            restartLevel()
        }
    }

    @objc private func levelComplete() {
        GameState.shared.gameMode = .levelComplete

        // Calculate time bonus
        let timeBonus = GameState.shared.timeRemaining * GameConstants.Level.timeBonus
        GameState.shared.addScore(timeBonus)

        // Show level complete UI, then advance
        run(SKAction.wait(forDuration: 3.0)) { [weak self] in
            GameState.shared.advanceLevel()
            self?.restartLevel()
        }
    }

    @objc private func handlePipeWarp(_ notification: Notification) {
        // Handle pipe warping
        guard let userInfo = notification.userInfo,
              let destX = userInfo["destinationX"] as? Int,
              let destY = userInfo["destinationY"] as? Int else { return }

        // Warp Mario to destination
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                self?.mario.position = CGPoint(
                    x: CGFloat(destX) * GameConstants.tileSize,
                    y: CGFloat(destY) * GameConstants.tileSize
                )
                self?.mario.physicsBody?.affectedByGravity = true
                self?.mario.state = .idle
            }
        ]))
    }

    private func restartLevel() {
        // Clean up current level
        levelLoader.cleanup()
        mario?.removeFromParent()

        // Reset state for new attempt
        GameState.shared.resetForNewLevel()

        // Reload level
        mario = levelLoader.loadLevel(levelData, into: self)

        // Reset camera
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Resume game
        GameState.shared.gameMode = .playing
        lastUpdateTime = 0
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
