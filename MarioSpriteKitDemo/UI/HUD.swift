//
//  HUD.swift
//  MarioSpriteKitDemo
//
//  Heads-up display showing score, coins, time, etc.
//

import SpriteKit

class HUD: SKNode {

    // MARK: - Properties

    private var scoreLabel: SKLabelNode!
    private var coinLabel: SKLabelNode!
    private var worldLabel: SKLabelNode!
    private var timeLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!

    private var coinIcon: SKSpriteNode!

    // MARK: - Initialization

    override init() {
        super.init()
        setupHUD()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupHUD() {
        let screenWidth = GameConstants.sceneWidth
        let topY: CGFloat = GameConstants.sceneHeight / 2 - 30

        // Score section (left)
        let scoreTitle = createLabel(text: "MARIO", fontSize: 12)
        scoreTitle.position = CGPoint(x: -screenWidth/2 + 50, y: topY)
        addChild(scoreTitle)

        scoreLabel = createLabel(text: "000000", fontSize: 14)
        scoreLabel.position = CGPoint(x: -screenWidth/2 + 50, y: topY - 18)
        addChild(scoreLabel)

        // Coins section (center-left)
        coinIcon = SKSpriteNode(imageNamed: "coin_1")
        coinIcon.size = CGSize(width: 12, height: 14)
        coinIcon.position = CGPoint(x: -screenWidth/2 + 140, y: topY - 8)
        addChild(coinIcon)

        coinLabel = createLabel(text: "x00", fontSize: 14)
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: -screenWidth/2 + 150, y: topY - 14)
        addChild(coinLabel)

        // World section (center)
        let worldTitle = createLabel(text: "WORLD", fontSize: 12)
        worldTitle.position = CGPoint(x: 0, y: topY)
        addChild(worldTitle)

        worldLabel = createLabel(text: "1-1", fontSize: 14)
        worldLabel.position = CGPoint(x: 0, y: topY - 18)
        addChild(worldLabel)

        // Time section (center-right)
        let timeTitle = createLabel(text: "TIME", fontSize: 12)
        timeTitle.position = CGPoint(x: screenWidth/2 - 80, y: topY)
        addChild(timeTitle)

        timeLabel = createLabel(text: "400", fontSize: 14)
        timeLabel.position = CGPoint(x: screenWidth/2 - 80, y: topY - 18)
        addChild(timeLabel)

        // Lives section (far left, smaller)
        livesLabel = createLabel(text: "♥x3", fontSize: 12)
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: -screenWidth/2 + 10, y: topY - 40)
        addChild(livesLabel)

        // Animate coin icon
        animateCoinIcon()
    }

    private func createLabel(text: String, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = fontSize
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }

    private func animateCoinIcon() {
        let spin = SKAction.sequence([
            SKAction.scaleX(to: 0.3, duration: 0.1),
            SKAction.scaleX(to: 1.0, duration: 0.1)
        ])
        coinIcon.run(SKAction.repeatForever(SKAction.sequence([
            spin,
            SKAction.wait(forDuration: 0.3)
        ])))
    }

    // MARK: - Update

    func update() {
        let state = GameState.shared

        // Update score (with leading zeros)
        scoreLabel.text = String(format: "%06d", state.score)

        // Update coins
        coinLabel.text = String(format: "x%02d", state.coins)

        // Update world
        worldLabel.text = state.worldLevelString

        // Update time
        timeLabel.text = String(format: "%03d", max(0, state.timeRemaining))

        // Flash time when low
        if state.timeRemaining <= 100 && state.timeRemaining > 0 {
            if timeLabel.action(forKey: "flash") == nil {
                let flash = SKAction.sequence([
                    SKAction.run { [weak self] in self?.timeLabel.fontColor = .red },
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run { [weak self] in self?.timeLabel.fontColor = .white },
                    SKAction.wait(forDuration: 0.5)
                ])
                timeLabel.run(SKAction.repeatForever(flash), withKey: "flash")
            }
        } else {
            timeLabel.removeAction(forKey: "flash")
            timeLabel.fontColor = .white
        }

        // Update lives
        livesLabel.text = "♥x\(state.lives)"
    }

    // MARK: - Animations

    func showScorePopup(points: Int, at position: CGPoint) {
        let popup = SKLabelNode(text: "+\(points)")
        popup.fontName = "AvenirNext-Bold"
        popup.fontSize = 14
        popup.fontColor = .white
        popup.position = convert(position, from: parent!)
        popup.zPosition = 100
        addChild(popup)

        let rise = SKAction.moveBy(x: 0, y: 30, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()

        popup.run(SKAction.sequence([rise, fade, remove]))
    }

    func showCoinPopup(at position: CGPoint) {
        showScorePopup(points: GameConstants.Collectibles.coinPoints, at: position)
    }

    func show1Up(at position: CGPoint) {
        let popup = SKLabelNode(text: "1UP")
        popup.fontName = "AvenirNext-Bold"
        popup.fontSize = 16
        popup.fontColor = .green
        popup.position = convert(position, from: parent!)
        popup.zPosition = 100
        addChild(popup)

        let rise = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()

        popup.run(SKAction.sequence([rise, fade, remove]))
    }
}
