//
//  GameOverScene.swift
//  MarioSpriteKitDemo
//
//  Game Over screen
//

import SpriteKit

class GameOverScene: SKScene {

    // MARK: - Properties

    private var gameOverLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var continueLabel: SKLabelNode!

    private var canContinue = false

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupUI()

        // Enable touch after delay
        run(SKAction.wait(forDuration: 2.0)) { [weak self] in
            self?.canContinue = true
            self?.showContinuePrompt()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        // Game Over text
        gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Heavy"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        gameOverLabel.alpha = 0
        addChild(gameOverLabel)

        // Animate game over text
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        gameOverLabel.run(fadeIn)

        // Final Score
        let finalScore = GameState.shared.score
        scoreLabel = SKLabelNode(text: "SCORE: \(String(format: "%06d", finalScore))")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        scoreLabel.alpha = 0
        addChild(scoreLabel)

        // Animate score
        scoreLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            fadeIn
        ]))

        // High Score
        let highScore = GameState.shared.highScore
        let isNewHighScore = finalScore >= highScore && finalScore > 0

        if isNewHighScore {
            highScoreLabel = SKLabelNode(text: "NEW HIGH SCORE!")
            highScoreLabel.fontColor = .yellow
        } else {
            highScoreLabel = SKLabelNode(text: "HIGH SCORE: \(String(format: "%06d", highScore))")
            highScoreLabel.fontColor = .gray
        }
        highScoreLabel.fontName = "AvenirNext-Medium"
        highScoreLabel.fontSize = 18
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        highScoreLabel.alpha = 0
        addChild(highScoreLabel)

        // Animate high score
        highScoreLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            fadeIn
        ]))

        // New high score celebration
        if isNewHighScore {
            celebrateHighScore()
        }

        // Mario image (defeated)
        let mario = SKSpriteNode(imageNamed: "mario_003_0043")
        mario.setScale(2.0)
        mario.yScale = -2.0 // Upside down for "dead" look
        mario.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        mario.alpha = 0
        addChild(mario)

        mario.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }

    private func showContinuePrompt() {
        continueLabel = SKLabelNode(text: "TAP TO CONTINUE")
        continueLabel.fontName = "AvenirNext-Bold"
        continueLabel.fontSize = 18
        continueLabel.fontColor = .white
        continueLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        addChild(continueLabel)

        // Blinking animation
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])
        continueLabel.run(SKAction.repeatForever(blink))
    }

    private func celebrateHighScore() {
        // Create particle effect or sparkles
        for _ in 0..<20 {
            let sparkle = SKShapeNode(circleOfRadius: 3)
            sparkle.fillColor = .yellow
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.3...size.height * 0.5)
            )
            sparkle.alpha = 0
            addChild(sparkle)

            let appear = SKAction.fadeIn(withDuration: 0.2)
            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                        y: CGFloat.random(in: 20...50),
                                        duration: 1.0)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()

            sparkle.run(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 1.0...2.0)),
                appear,
                move,
                fade,
                remove
            ]))
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canContinue else { return }

        // Return to menu
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(menuScene, transition: transition)
    }
}
