//
//  GameState.swift
//  MarioSpriteKitDemo
//
//  Global game state management
//

import Foundation

/// Mario's power-up state
enum MarioPowerState: Int {
    case small = 0
    case big = 1
    case fire = 2

    var canBreakBricks: Bool {
        return self != .small
    }
}

/// Current game mode
enum GameMode {
    case menu
    case playing
    case paused
    case gameOver
    case levelComplete
}

/// Singleton class managing global game state
class GameState {

    // MARK: - Singleton

    static let shared = GameState()

    private init() {
        reset()
    }

    // MARK: - Player State

    /// Current lives
    var lives: Int = 3

    /// Current score
    var score: Int = 0

    /// Total coins collected
    var coins: Int = 0

    /// Current world (1-8)
    var world: Int = 1

    /// Current level (1-4)
    var level: Int = 1

    /// Mario's power state
    var powerState: MarioPowerState = .small

    /// Is Mario invincible (star power)
    var isStarPowered: Bool = false

    /// Time remaining in current level
    var timeRemaining: Int = 400

    /// Current game mode
    var gameMode: GameMode = .menu

    /// High score (persisted)
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "HighScore") }
        set { UserDefaults.standard.set(newValue, forKey: "HighScore") }
    }

    // MARK: - Level Progress

    /// Checkpoint reached in current level
    var checkpointReached: Bool = false

    /// Checkpoint X position
    var checkpointX: CGFloat = 0

    // MARK: - Methods

    /// Reset all state for new game
    func reset() {
        lives = 3
        score = 0
        coins = 0
        world = 1
        level = 1
        powerState = .small
        isStarPowered = false
        timeRemaining = GameConstants.Level.timeLimit
        gameMode = .menu
        checkpointReached = false
        checkpointX = 0
    }

    /// Reset state for new level (keep score, lives, coins)
    func resetForNewLevel() {
        powerState = .small
        isStarPowered = false
        timeRemaining = GameConstants.Level.timeLimit
        checkpointReached = false
        checkpointX = 0
    }

    /// Add coins and check for extra life
    func addCoins(_ count: Int) {
        coins += count
        score += count * GameConstants.Collectibles.coinPoints

        // Check for extra life
        while coins >= GameConstants.Collectibles.coinsForLife {
            coins -= GameConstants.Collectibles.coinsForLife
            addLife()
        }
    }

    /// Add points to score
    func addScore(_ points: Int) {
        score += points
        if score > highScore {
            highScore = score
        }
    }

    /// Add a life
    func addLife() {
        lives += 1
        // Play 1-up sound here
    }

    /// Lose a life, returns true if game over
    func loseLife() -> Bool {
        lives -= 1
        powerState = .small
        isStarPowered = false

        if lives < 0 {
            gameMode = .gameOver
            return true
        }
        return false
    }

    /// Advance to next level
    func advanceLevel() {
        level += 1
        if level > 4 {
            level = 1
            world += 1
        }
        if world > 8 {
            // Game complete!
            world = 1
            level = 1
        }
        resetForNewLevel()
    }

    /// Get formatted world-level string
    var worldLevelString: String {
        return "\(world)-\(level)"
    }
}
