//
//  MenuScene.swift
//  MarioSpriteKitDemo
//
//  Title screen / Main menu
//

import SpriteKit

class MenuScene: SKScene {

    // MARK: - Properties

    private var titleLabel: SKLabelNode!
    private var pressStartLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var marioSprite: SKSpriteNode!

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = GameConstants.skyColor
        setupTitle()
        setupMario()
        setupMenu()
        setupGround()
        animateScene()
    }

    // MARK: - Setup

    private func setupTitle() {
        // Main title
        titleLabel = SKLabelNode(text: "SUPER MARIO BROS")
        titleLabel.fontName = "AvenirNext-Heavy"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)

        // Add shadow for depth
        let shadow = SKLabelNode(text: "SUPER MARIO BROS")
        shadow.fontName = "AvenirNext-Heavy"
        shadow.fontSize = 36
        shadow.fontColor = .black
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        titleLabel.addChild(shadow)

        addChild(titleLabel)

        // Subtitle
        let subtitle = SKLabelNode(text: "SpriteKit Edition")
        subtitle.fontName = "AvenirNext-Medium"
        subtitle.fontSize = 16
        subtitle.fontColor = .yellow
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        addChild(subtitle)
    }

    private func setupMario() {
        marioSprite = SKSpriteNode(imageNamed: "mario_003_0043")
        marioSprite.setScale(3.0)
        marioSprite.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(marioSprite)

        // Idle animation
        let textures = [
            SKTexture(imageNamed: "mario_003_0043"),
            SKTexture(imageNamed: "mario_003_0044"),
            SKTexture(imageNamed: "mario_003_0045")
        ]
        let animation = SKAction.animate(with: textures, timePerFrame: 0.2)
        marioSprite.run(SKAction.repeatForever(animation))
    }

    private func setupMenu() {
        // Press Start
        pressStartLabel = SKLabelNode(text: "TAP TO START")
        pressStartLabel.fontName = "AvenirNext-Bold"
        pressStartLabel.fontSize = 20
        pressStartLabel.fontColor = .white
        pressStartLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        addChild(pressStartLabel)

        // Blinking animation
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])
        pressStartLabel.run(SKAction.repeatForever(blink))

        // High Score
        let highScore = GameState.shared.highScore
        highScoreLabel = SKLabelNode(text: "HIGH SCORE: \(String(format: "%06d", highScore))")
        highScoreLabel.fontName = "AvenirNext-Medium"
        highScoreLabel.fontSize = 14
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(highScoreLabel)

        // Credits
        let credits = SKLabelNode(text: "© NINTENDO - CLONE FOR EDUCATIONAL PURPOSES")
        credits.fontName = "AvenirNext-Regular"
        credits.fontSize = 10
        credits.fontColor = SKColor(white: 1, alpha: 0.5)
        credits.position = CGPoint(x: size.width / 2, y: 30)
        addChild(credits)
    }

    private func setupGround() {
        // Create ground strip at bottom
        let groundHeight: CGFloat = 64
        for i in 0..<Int(size.width / 32) + 1 {
            let brick = SKSpriteNode(imageNamed: "brick")
            brick.size = CGSize(width: 32, height: 32)
            brick.position = CGPoint(x: CGFloat(i) * 32 + 16, y: groundHeight - 16)
            addChild(brick)

            let brick2 = SKSpriteNode(imageNamed: "brick")
            brick2.size = CGSize(width: 32, height: 32)
            brick2.position = CGPoint(x: CGFloat(i) * 32 + 16, y: groundHeight - 48)
            addChild(brick2)
        }
    }

    private func animateScene() {
        // Title drop animation
        titleLabel.position.y = size.height + 50
        let dropTitle = SKAction.moveTo(y: size.height * 0.75, duration: 0.8)
        dropTitle.timingMode = .easeOut
        titleLabel.run(dropTitle)

        // Mario bounce in
        marioSprite.setScale(0)
        let scaleIn = SKAction.scale(to: 3.0, duration: 0.5)
        scaleIn.timingMode = .easeOut
        marioSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            scaleIn
        ]))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
    }

    private func startGame() {
        // Reset game state
        GameState.shared.reset()

        // Transition to game scene
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
