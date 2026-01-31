//
//  GameConstants.swift
//  MarioSpriteKitDemo
//
//  Super Mario Bros Clone - Game Constants
//

import SpriteKit

/// Central configuration for all game constants
struct GameConstants {

    // MARK: - Screen & World

    /// Tile size in points (16x16 original, scaled up)
    static let tileSize: CGFloat = 32

    /// Number of visible tiles horizontally
    static let visibleTilesX: Int = 16

    /// Number of visible tiles vertically
    static let visibleTilesY: Int = 14

    /// Scene width
    static var sceneWidth: CGFloat { tileSize * CGFloat(visibleTilesX) }

    /// Scene height
    static var sceneHeight: CGFloat { tileSize * CGFloat(visibleTilesY) }

    /// Gravity strength
    static let gravity: CGFloat = -30.0

    /// Sky color (classic SMB blue)
    static let skyColor = SKColor(red: 107/255, green: 140/255, blue: 255/255, alpha: 1.0)

    // MARK: - Mario Physics

    struct Mario {
        /// Walking speed
        static let walkSpeed: CGFloat = 150.0

        /// Running speed (when holding run button)
        static let runSpeed: CGFloat = 250.0

        /// Maximum horizontal velocity
        static let maxVelocityX: CGFloat = 300.0

        /// Jump impulse force
        static let jumpForce: CGFloat = 450.0

        /// Small jump (tap) force
        static let smallJumpForce: CGFloat = 350.0

        /// Acceleration rate
        static let acceleration: CGFloat = 800.0

        /// Deceleration rate (friction)
        static let deceleration: CGFloat = 600.0

        /// Air control factor (reduced control in air)
        static let airControlFactor: CGFloat = 0.65

        /// Invincibility duration after hit
        static let invincibilityDuration: TimeInterval = 2.0

        /// Star power duration
        static let starDuration: TimeInterval = 10.0
    }

    // MARK: - Enemy Settings

    struct Enemy {
        /// Goomba walk speed
        static let goombaSpeed: CGFloat = 50.0

        /// Koopa walk speed
        static let koopaSpeed: CGFloat = 40.0

        /// Shell slide speed
        static let shellSpeed: CGFloat = 300.0

        /// Bounce force when stomped
        static let stompBounce: CGFloat = 300.0
    }

    // MARK: - Collectibles

    struct Collectibles {
        /// Points per coin
        static let coinPoints: Int = 200

        /// Points per enemy stomp
        static let stompPoints: Int = 100

        /// Points for mushroom
        static let mushroomPoints: Int = 1000

        /// Points for fire flower
        static let fireFlowerPoints: Int = 1000

        /// Points for star
        static let starPoints: Int = 1000

        /// Points for 1-up
        static let oneUpPoints: Int = 0

        /// Coins needed for extra life
        static let coinsForLife: Int = 100
    }

    // MARK: - Block Settings

    struct Blocks {
        /// Bounce height when hit
        static let bounceHeight: CGFloat = 8.0

        /// Bounce duration
        static let bounceDuration: TimeInterval = 0.15

        /// Brick break particle count
        static let brickParticles: Int = 4
    }

    // MARK: - Level Settings

    struct Level {
        /// Time limit in seconds
        static let timeLimit: Int = 400

        /// Points per second remaining
        static let timeBonus: Int = 50

        /// Flagpole slide speed
        static let flagSlideSpeed: CGFloat = 200.0
    }

    // MARK: - Animation Frame Durations

    struct Animation {
        /// Mario walk animation speed
        static let marioWalk: TimeInterval = 0.1

        /// Mario run animation speed
        static let marioRun: TimeInterval = 0.05

        /// Goomba walk animation speed
        static let goombaWalk: TimeInterval = 0.2

        /// Koopa walk animation speed
        static let koopaWalk: TimeInterval = 0.15

        /// Coin spin animation speed
        static let coinSpin: TimeInterval = 0.1

        /// Question block animation speed
        static let questionBlock: TimeInterval = 0.2
    }

    // MARK: - Z Positions (layering)

    struct ZPosition {
        static let background: CGFloat = -100
        static let backgroundDecoration: CGFloat = -50
        static let ground: CGFloat = 0
        static let blocks: CGFloat = 10
        static let pipes: CGFloat = 15
        static let collectibles: CGFloat = 20
        static let enemies: CGFloat = 30
        static let player: CGFloat = 50
        static let foregroundDecoration: CGFloat = 60
        static let effects: CGFloat = 80
        static let hud: CGFloat = 100
    }
}
