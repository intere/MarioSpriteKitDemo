//
//  Pipe.swift
//  MarioSpriteKitDemo
//
//  Warp pipes - some are enterable
//

import SpriteKit

/// Direction Mario enters/exits pipe
enum PipeDirection {
    case down   // Press down to enter, exit upward
    case up     // Press up to enter, exit downward
    case left   // Walk into pipe from right
    case right  // Walk into pipe from left
}

class Pipe: Tile {

    // MARK: - Properties

    /// Can Mario enter this pipe?
    var isEnterable: Bool = false

    /// Direction to enter
    var enterDirection: PipeDirection = .down

    /// Destination (grid position in level)
    var destinationX: Int = 0
    var destinationY: Int = 0

    /// Destination level (for warp zones)
    var destinationWorld: Int = 0
    var destinationLevel: Int = 0

    /// Does this pipe contain a Piranha Plant?
    var hasPiranha: Bool = false
    var piranha: PiranhaPlant?

    /// Height of pipe in tiles
    var pipeHeight: Int = 2

    // MARK: - Initialization

    init(gridPosition: (x: Int, y: Int), height: Int = 2, enterable: Bool = false) {
        self.pipeHeight = height
        self.isEnterable = enterable
        super.init(type: .pipe, gridPosition: gridPosition)

        // Adjust size based on height
        let pipeSize = CGSize(width: GameConstants.tileSize * 2, height: GameConstants.tileSize * CGFloat(height))
        self.size = pipeSize

        // Reposition based on new size
        self.position = CGPoint(
            x: CGFloat(gridX) * GameConstants.tileSize + pipeSize.width / 2,
            y: CGFloat(gridY) * GameConstants.tileSize + pipeSize.height / 2
        )

        self.zPosition = GameConstants.ZPosition.pipes
        setupPipePhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPipePhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.pipe
        physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.isDynamic = false
        physicsBody?.friction = 0
    }

    func addPiranha() {
        hasPiranha = true
        piranha = PiranhaPlant(pipe: self)
        if let piranha = piranha, let scene = self.scene {
            scene.addChild(piranha)
        }
    }

    // MARK: - Interactions

    func canEnter(player: Mario, direction: PipeDirection) -> Bool {
        guard isEnterable && enterDirection == direction else { return false }

        // Check if piranha is hiding
        if hasPiranha, let piranha = piranha {
            return piranha.isHiding
        }

        return true
    }

    func enterPipe(player: Mario) {
        guard isEnterable else { return }

        player.state = .enteringPipe
        player.physicsBody?.velocity = .zero
        player.physicsBody?.affectedByGravity = false

        // Pipe enter animation based on direction
        let enterAction: SKAction

        switch enterDirection {
        case .down:
            enterAction = SKAction.moveBy(x: 0, y: -GameConstants.tileSize * 2, duration: 0.5)
        case .up:
            enterAction = SKAction.moveBy(x: 0, y: GameConstants.tileSize * 2, duration: 0.5)
        case .left:
            enterAction = SKAction.moveBy(x: -GameConstants.tileSize * 2, y: 0, duration: 0.5)
        case .right:
            enterAction = SKAction.moveBy(x: GameConstants.tileSize * 2, y: 0, duration: 0.5)
        }

        run(SKAction.playSoundFileNamed("pipe.wav", waitForCompletion: false))

        player.run(enterAction) { [weak self] in
            self?.warpPlayer(player)
        }
    }

    private func warpPlayer(_ player: Mario) {
        // Post notification with destination
        let userInfo: [String: Any] = [
            "destinationX": destinationX,
            "destinationY": destinationY,
            "destinationWorld": destinationWorld,
            "destinationLevel": destinationLevel
        ]
        NotificationCenter.default.post(name: .pipeWarp, object: nil, userInfo: userInfo)
    }
}

// MARK: - Piranha Plant

class PiranhaPlant: SKSpriteNode {

    weak var pipe: Pipe?
    var isHiding: Bool = true
    var emergeHeight: CGFloat = 0

    init(pipe: Pipe) {
        self.pipe = pipe
        let texture = SKTexture(imageNamed: "piranha_1")
        let size = CGSize(width: GameConstants.tileSize, height: GameConstants.tileSize * 1.5)

        super.init(texture: texture, color: .clear, size: size)

        self.name = "piranha"
        self.zPosition = GameConstants.ZPosition.enemies - 1 // Behind pipe

        // Position inside pipe
        self.position = CGPoint(x: pipe.position.x, y: pipe.position.y + pipe.size.height / 2)
        self.emergeHeight = size.height

        setupAnimation()
        startBehavior()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAnimation() {
        let textures = [
            SKTexture(imageNamed: "piranha_1"),
            SKTexture(imageNamed: "piranha_2")
        ]
        let animation = SKAction.animate(with: textures, timePerFrame: 0.2)
        run(SKAction.repeatForever(animation))
    }

    private func startBehavior() {
        // Emerge and hide cycle
        let emerge = SKAction.moveBy(x: 0, y: emergeHeight, duration: 0.5)
        let wait = SKAction.wait(forDuration: 1.5)
        let hide = SKAction.moveBy(x: 0, y: -emergeHeight, duration: 0.5)
        let hideWait = SKAction.wait(forDuration: 2.0)

        let setEmerged = SKAction.run { [weak self] in self?.isHiding = false }
        let setHidden = SKAction.run { [weak self] in self?.isHiding = true }

        let cycle = SKAction.sequence([
            hideWait,
            setEmerged, emerge,
            wait,
            hide, setHidden
        ])

        run(SKAction.repeatForever(cycle))
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let pipeWarp = Notification.Name("pipeWarp")
}
