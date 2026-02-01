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

    /// Touch control nodes
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var jumpButton: SKSpriteNode!
    var runButton: SKSpriteNode!

    // MARK: - Initialization

    override func didMove(to view: SKView) {
        // Set background color
        backgroundColor = GameConstants.skyColor

        // Scene anchor at bottom-left
        anchorPoint = CGPoint(x: 0, y: 0)

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
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    // MARK: - Setup

    private func setupHUD() {
        hud = HUD()
        hud.zPosition = GameConstants.ZPosition.hud
        cameraNode.addChild(hud)
    }

    private func setupTouchControls() {
        let buttonSize = CGSize(width: 60, height: 60)
        let buttonAlpha: CGFloat = 0.5

        // Left button - bottom left
        leftButton = SKSpriteNode(color: .white, size: buttonSize)
        leftButton.alpha = buttonAlpha
        leftButton.position = CGPoint(x: -size.width/2 + 50, y: -size.height/2 + 50)
        leftButton.name = "leftButton"
        leftButton.zPosition = 10
        cameraNode.addChild(leftButton)

        // Right button - next to left
        rightButton = SKSpriteNode(color: .white, size: buttonSize)
        rightButton.alpha = buttonAlpha
        rightButton.position = CGPoint(x: -size.width/2 + 120, y: -size.height/2 + 50)
        rightButton.name = "rightButton"
        rightButton.zPosition = 10
        cameraNode.addChild(rightButton)

        // Jump button (A) - bottom right
        jumpButton = SKSpriteNode(color: .red, size: CGSize(width: 70, height: 70))
        jumpButton.alpha = buttonAlpha
        jumpButton.position = CGPoint(x: size.width/2 - 60, y: -size.height/2 + 60)
        jumpButton.name = "jumpButton"
        jumpButton.zPosition = 10
        cameraNode.addChild(jumpButton)

        // Run button (B) - next to jump
        runButton = SKSpriteNode(color: .yellow, size: CGSize(width: 50, height: 50))
        runButton.alpha = buttonAlpha
        runButton.position = CGPoint(x: size.width/2 - 130, y: -size.height/2 + 50)
        runButton.name = "runButton"
        runButton.zPosition = 10
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
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
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
        guard mario != nil else { return }

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

        // Camera follows Mario horizontally
        var cameraX = mario.position.x

        // Keep camera Y fixed to show ground level
        let cameraY = size.height / 2

        // Clamp camera to level bounds
        let minX = size.width / 2
        let maxX = CGFloat(levelData.width) * GameConstants.tileSize - size.width / 2

        cameraX = max(minX, min(cameraX, maxX))

        // Smooth camera movement
        let smoothing: CGFloat = 0.1
        cameraNode.position.x += (cameraX - cameraNode.position.x) * smoothing
        cameraNode.position.y = cameraY
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            handleTouchDown(at: location)
        }
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
            mario?.moveInput = -1
        } else if rightButton.contains(location) {
            rightTouchActive = true
            mario?.moveInput = 1
        } else if jumpButton.contains(location) {
            jumpTouchActive = true
            mario?.jump()
        } else if runButton.contains(location) {
            runTouchActive = true
            mario?.isRunning = true
        }
    }

    private func handleTouchUp(at location: CGPoint) {
        if leftTouchActive {
            leftTouchActive = false
            if !rightTouchActive {
                mario?.moveInput = 0
            }
        }
        if rightTouchActive {
            rightTouchActive = false
            if !leftTouchActive {
                mario?.moveInput = 0
            }
        }
        if jumpTouchActive {
            jumpTouchActive = false
            mario?.variableJump()
        }
        if runTouchActive {
            runTouchActive = false
            mario?.isRunning = false
        }
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

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
            mario?.die()
        }

        // Player + Flagpole
        if collision == PhysicsCategory.player | PhysicsCategory.flagpole {
            mario?.grabFlagpole()
        }

        // Player + Ground (landing)
        if collision == PhysicsCategory.player | PhysicsCategory.ground {
            if contact.contactNormal.dy > 0.5 {
                mario?.landed()
            }
        }

        // Enemy + wall (turn around)
        if (contact.bodyA.categoryBitMask == PhysicsCategory.enemy ||
            contact.bodyB.categoryBitMask == PhysicsCategory.enemy) {
            if let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) {
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
    }

    private func handlePlayerEnemyContact(_ contact: SKPhysicsContact) {
        guard let mario = mario else { return }
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        guard let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) else { return }

        if let koopa = enemy as? KoopaTroopa {
            if koopa.koopaState == .shell {
                let kickDirection: CGFloat = mario.position.x < koopa.position.x ? 1 : -1
                koopa.kickShell(direction: kickDirection)
                mario.physicsBody?.velocity.dy = GameConstants.Enemy.stompBounce * 0.5
                return
            } else if koopa.koopaState == .sliding {
                if !GameState.shared.isStarPowered {
                    mario.takeDamage()
                }
                return
            }
        }

        if GameState.shared.isStarPowered {
            enemy.hitByFireball()
        } else {
            mario.takeDamage()
        }
    }

    private func handlePlayerStompEnemy(_ contact: SKPhysicsContact) {
        guard let mario = mario, let marioBody = mario.physicsBody else { return }
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        guard let enemy = (nodeA as? Enemy) ?? (nodeB as? Enemy) else { return }

        if marioBody.velocity.dy < -50 {
            enemy.stomp()
            marioBody.velocity.dy = GameConstants.Enemy.stompBounce
        }
    }

    private func handlePlayerBlockContact(_ contact: SKPhysicsContact) {
        guard let mario = mario, let marioBody = mario.physicsBody else { return }
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        guard let block = (nodeA as? Tile) ?? (nodeB as? Tile) else { return }

        if marioBody.velocity.dy > 50 && mario.position.y < block.position.y {
            block.hitFromBelow(by: mario)
        }
    }

    // MARK: - Event Handlers

    @objc private func marioDidDie() {
        let gameOver = GameState.shared.loseLife()

        if gameOver {
            let transition = SKTransition.fade(withDuration: 1.0)
            let gameOverScene = GameOverScene(size: size)
            view?.presentScene(gameOverScene, transition: transition)
        } else {
            restartLevel()
        }
    }

    @objc private func levelComplete() {
        GameState.shared.gameMode = .levelComplete

        let timeBonus = GameState.shared.timeRemaining * GameConstants.Level.timeBonus
        GameState.shared.addScore(timeBonus)

        run(SKAction.wait(forDuration: 3.0)) { [weak self] in
            GameState.shared.advanceLevel()
            self?.restartLevel()
        }
    }

    @objc private func handlePipeWarp(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let destX = userInfo["destinationX"] as? Int,
              let destY = userInfo["destinationY"] as? Int else { return }

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
        levelLoader.cleanup()
        mario?.removeFromParent()

        GameState.shared.resetForNewLevel()
        mario = levelLoader.loadLevel(levelData, into: self)

        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        GameState.shared.gameMode = .playing
        lastUpdateTime = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
