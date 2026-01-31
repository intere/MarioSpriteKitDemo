//
//  LevelData.swift
//  MarioSpriteKitDemo
//
//  Level data structures and Level 1-1 definition
//

import SpriteKit

/// Represents a single object in the level
struct LevelObject {
    let type: String
    let x: Int
    let y: Int
    var properties: [String: Any] = [:]

    init(_ type: String, x: Int, y: Int, properties: [String: Any] = [:]) {
        self.type = type
        self.x = x
        self.y = y
        self.properties = properties
    }
}

/// Complete level data
struct LevelData {
    let world: Int
    let level: Int
    let width: Int           // Level width in tiles
    let height: Int          // Level height in tiles
    let backgroundColor: SKColor
    let timeLimit: Int
    let objects: [LevelObject]
    let playerStartX: Int
    let playerStartY: Int
}

// MARK: - Level 1-1 Definition

extension LevelData {

    /// Classic Super Mario Bros World 1-1
    static var level1_1: LevelData {
        var objects: [LevelObject] = []

        // Ground floor (y = 0 and y = 1 for 2-tile high ground)
        // Section 1: Start area (0-68)
        for x in 0..<69 {
            if x < 69 && x != 69 { // Gap at 69-70
                objects.append(LevelObject("ground", x: x, y: 0))
                objects.append(LevelObject("ground", x: x, y: 1))
            }
        }

        // Gap in ground (69-70)

        // Section 2: After first gap (71-85)
        for x in 71..<86 {
            objects.append(LevelObject("ground", x: x, y: 0))
            objects.append(LevelObject("ground", x: x, y: 1))
        }

        // Gap at 86-88

        // Section 3: After second gap (89-152)
        for x in 89..<153 {
            objects.append(LevelObject("ground", x: x, y: 0))
            objects.append(LevelObject("ground", x: x, y: 1))
        }

        // Gap at 153-154

        // Section 4: Final stretch (155-210)
        for x in 155..<211 {
            objects.append(LevelObject("ground", x: x, y: 0))
            objects.append(LevelObject("ground", x: x, y: 1))
        }

        // Question blocks and bricks
        // First question block with coin (x=16)
        objects.append(LevelObject("questionBlock", x: 16, y: 5, properties: ["contents": "coin"]))

        // Brick-Question-Brick-Question-Brick row (x=20-24)
        objects.append(LevelObject("brick", x: 20, y: 5))
        objects.append(LevelObject("questionBlock", x: 21, y: 5, properties: ["contents": "mushroom"]))
        objects.append(LevelObject("brick", x: 22, y: 5))
        objects.append(LevelObject("questionBlock", x: 23, y: 5, properties: ["contents": "coin"]))
        objects.append(LevelObject("brick", x: 24, y: 5))

        // Hidden 1-UP block (above the row)
        objects.append(LevelObject("questionBlock", x: 22, y: 9, properties: ["contents": "coin"]))

        // First pipe (x=28, height 2)
        objects.append(LevelObject("pipe", x: 28, y: 2, properties: ["height": 2]))

        // Second pipe (x=38, height 3)
        objects.append(LevelObject("pipe", x: 38, y: 2, properties: ["height": 3]))

        // Third pipe (x=46, height 4) - leads to underground
        objects.append(LevelObject("pipe", x: 46, y: 2, properties: ["height": 4, "enterable": true, "destinationX": 0, "destinationY": 0]))

        // Fourth pipe (x=57, height 4)
        objects.append(LevelObject("pipe", x: 57, y: 2, properties: ["height": 4]))

        // Enemies: First Goomba
        objects.append(LevelObject("goomba", x: 22, y: 2))

        // Two Goombas near pipes
        objects.append(LevelObject("goomba", x: 40, y: 2))
        objects.append(LevelObject("goomba", x: 51, y: 2))

        // Brick ceiling section with Goombas below (x=64-68)
        for x in 64..<69 {
            objects.append(LevelObject("brick", x: x, y: 9))
        }

        // Brick row with star (x=77-79)
        objects.append(LevelObject("brick", x: 77, y: 5))
        objects.append(LevelObject("questionBlock", x: 78, y: 5, properties: ["contents": "star"]))
        objects.append(LevelObject("brick", x: 79, y: 5))

        // Brick row (x=80-87)
        for x in 80..<88 {
            objects.append(LevelObject("brick", x: x, y: 9))
        }

        // Question block with mushroom/fireflower
        objects.append(LevelObject("questionBlock", x: 94, y: 5, properties: ["contents": "fireFlower"]))

        // Brick section (x=100-101)
        objects.append(LevelObject("brick", x: 100, y: 5))
        objects.append(LevelObject("brick", x: 101, y: 5))

        // Question blocks (x=106, 109, 109 at height 9)
        objects.append(LevelObject("questionBlock", x: 106, y: 5, properties: ["contents": "coin"]))
        objects.append(LevelObject("questionBlock", x: 109, y: 5, properties: ["contents": "coin"]))
        objects.append(LevelObject("questionBlock", x: 109, y: 9, properties: ["contents": "coin"]))

        // Brick with 10 coins (x=112)
        objects.append(LevelObject("brick", x: 112, y: 5, properties: ["contents": "multiCoin"]))

        // Bricks row (x=118-121)
        for x in 118..<122 {
            objects.append(LevelObject("brick", x: x, y: 5))
        }

        // High bricks (x=128-131 at height 9)
        for x in 128..<132 {
            objects.append(LevelObject("brick", x: x, y: 9))
        }

        // More ground-level bricks (x=129-131 at height 5)
        objects.append(LevelObject("brick", x: 129, y: 5))
        objects.append(LevelObject("brick", x: 130, y: 5))
        objects.append(LevelObject("questionBlock", x: 130, y: 9, properties: ["contents": "coin"]))

        // Staircase 1 (ascending, x=134-137)
        for step in 0..<4 {
            for height in 0...step {
                objects.append(LevelObject("hardBlock", x: 134 + step, y: 2 + height))
            }
        }

        // Staircase 2 (descending, x=140-143)
        for step in 0..<4 {
            for height in 0..<(4 - step) {
                objects.append(LevelObject("hardBlock", x: 140 + step, y: 2 + height))
            }
        }

        // Staircase 3 (ascending, x=148-152)
        for step in 0..<4 {
            for height in 0...step {
                objects.append(LevelObject("hardBlock", x: 148 + step, y: 2 + height))
            }
        }
        // Extra block at top
        objects.append(LevelObject("hardBlock", x: 152, y: 6))

        // Staircase 4 (descending, x=155-159)
        for step in 0..<5 {
            for height in 0..<(5 - step) {
                objects.append(LevelObject("hardBlock", x: 155 + step, y: 2 + height))
            }
        }

        // Two pipes after staircases
        objects.append(LevelObject("pipe", x: 163, y: 2, properties: ["height": 2]))
        objects.append(LevelObject("pipe", x: 179, y: 2, properties: ["height": 2]))

        // Brick row (x=168-171)
        for x in 168..<172 {
            objects.append(LevelObject("brick", x: x, y: 5))
        }

        // Final staircase to flagpole (x=181-188)
        for step in 0..<8 {
            for height in 0...step {
                objects.append(LevelObject("hardBlock", x: 181 + step, y: 2 + height))
            }
        }

        // Flagpole (x=189)
        objects.append(LevelObject("flagpole", x: 189, y: 2))

        // Castle (x=198)
        objects.append(LevelObject("castle", x: 198, y: 2))

        // Goombas throughout the level
        objects.append(LevelObject("goomba", x: 80, y: 2))
        objects.append(LevelObject("goomba", x: 82, y: 2))
        objects.append(LevelObject("koopa", x: 107, y: 2))
        objects.append(LevelObject("goomba", x: 114, y: 2))
        objects.append(LevelObject("goomba", x: 116, y: 2))
        objects.append(LevelObject("goomba", x: 124, y: 2))
        objects.append(LevelObject("goomba", x: 126, y: 2))
        objects.append(LevelObject("goomba", x: 128, y: 10))
        objects.append(LevelObject("goomba", x: 130, y: 10))
        objects.append(LevelObject("goomba", x: 174, y: 2))
        objects.append(LevelObject("goomba", x: 176, y: 2))

        // Background decorations
        // Clouds (y=11-12)
        objects.append(LevelObject("cloud", x: 8, y: 12, properties: ["size": 1]))
        objects.append(LevelObject("cloud", x: 19, y: 13, properties: ["size": 1]))
        objects.append(LevelObject("cloud", x: 27, y: 12, properties: ["size": 3]))
        objects.append(LevelObject("cloud", x: 36, y: 13, properties: ["size": 2]))
        objects.append(LevelObject("cloud", x: 56, y: 12, properties: ["size": 1]))
        objects.append(LevelObject("cloud", x: 67, y: 13, properties: ["size": 1]))
        objects.append(LevelObject("cloud", x: 75, y: 12, properties: ["size": 3]))

        // Hills/Bushes
        objects.append(LevelObject("bush", x: 11, y: 2, properties: ["size": 3]))
        objects.append(LevelObject("bush", x: 23, y: 2, properties: ["size": 1]))
        objects.append(LevelObject("hill", x: 0, y: 2, properties: ["size": 2]))
        objects.append(LevelObject("hill", x: 16, y: 2, properties: ["size": 1]))
        objects.append(LevelObject("hill", x: 48, y: 2, properties: ["size": 2]))

        return LevelData(
            world: 1,
            level: 1,
            width: 211,
            height: 15,
            backgroundColor: GameConstants.skyColor,
            timeLimit: 400,
            objects: objects,
            playerStartX: 3,
            playerStartY: 3
        )
    }
}
