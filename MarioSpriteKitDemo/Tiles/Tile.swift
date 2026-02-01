//
//  Tile.swift
//  MarioSpriteKitDemo
//
//  Base tile class for all level tiles
//

import SpriteKit

/// Types of tiles in the game
enum TileType: String, CaseIterable {
    case ground
    case brick
    case questionBlock
    case usedBlock
    case hardBlock    // Unbreakable block
    case pipe
    case pipeTop
    case platform
    case bridge
    case flagpole
    case castle
    case empty
}

/// Base class for all tiles
class Tile: SKSpriteNode {

    // MARK: - Properties

    let tileType: TileType
    var gridX: Int = 0
    var gridY: Int = 0

    // MARK: - Initialization

    init(type: TileType, gridPosition: (x: Int, y: Int)) {
        self.tileType = type
        self.gridX = gridPosition.x
        self.gridY = gridPosition.y

        let textureName = Tile.textureName(for: type)
        let texture = SKTexture(imageNamed: textureName)
        let size = Tile.size(for: type)

        super.init(texture: texture, color: .clear, size: size)

        self.name = type.rawValue
        self.position = CGPoint(
            x: CGFloat(gridX) * GameConstants.tileSize + size.width / 2,
            y: CGFloat(gridY) * GameConstants.tileSize + size.height / 2
        )
        self.zPosition = GameConstants.ZPosition.blocks

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Static Helpers

    static func textureName(for type: TileType) -> String {
        switch type {
        case .ground: return "brick"
        case .brick: return "brick"
        case .questionBlock: return "item_block"
        case .usedBlock: return "item_used"
        case .hardBlock: return "brick"
        case .pipe, .pipeTop: return "pipe"
        case .platform: return "pad_top"
        case .bridge: return "bridge"
        case .flagpole: return "flagpole"
        case .castle: return "castle"
        case .empty: return "empty"
        }
    }

    static func size(for type: TileType) -> CGSize {
        let tileSize = GameConstants.tileSize
        switch type {
        case .pipe:
            return CGSize(width: tileSize * 2, height: tileSize * 2)
        case .pipeTop:
            return CGSize(width: tileSize * 2, height: tileSize)
        case .castle:
            return CGSize(width: tileSize * 5, height: tileSize * 5)
        case .flagpole:
            return CGSize(width: tileSize * 0.5, height: tileSize * 10)
        default:
            return CGSize(width: tileSize, height: tileSize)
        }
    }

    // MARK: - Physics

    func setupPhysics() {
        guard tileType != .empty else { return }

        let bodySize = size

        switch tileType {
        case .ground, .brick, .hardBlock, .usedBlock:
            physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            physicsBody?.categoryBitMask = PhysicsCategory.ground
            physicsBody?.isDynamic = false

        case .questionBlock:
            physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            physicsBody?.categoryBitMask = PhysicsCategory.block
            physicsBody?.isDynamic = false

        case .pipe, .pipeTop:
            physicsBody = SKPhysicsBody(rectangleOf: bodySize)
            physicsBody?.categoryBitMask = PhysicsCategory.pipe
            physicsBody?.isDynamic = false

        case .platform, .bridge:
            // One-way platforms - player can jump through from below
            physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bodySize.width, height: 4),
                                        center: CGPoint(x: 0, y: bodySize.height / 2 - 2))
            physicsBody?.categoryBitMask = PhysicsCategory.ground
            physicsBody?.isDynamic = false

        case .flagpole:
            physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 8, height: bodySize.height))
            physicsBody?.categoryBitMask = PhysicsCategory.flagpole
            physicsBody?.isDynamic = false

        case .castle, .empty:
            // No physics
            break
        }

        physicsBody?.friction = 0.3
        physicsBody?.restitution = 0
    }

    // MARK: - Interactions

    func hitFromBelow(by player: Mario) {
        // Override in subclasses
    }

    func hitFromAbove(by player: Mario) {
        // Override in subclasses
    }
}
