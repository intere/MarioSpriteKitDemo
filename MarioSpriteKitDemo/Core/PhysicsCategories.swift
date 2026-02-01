//
//  PhysicsCategories.swift
//  MarioSpriteKitDemo
//
//  Physics collision bitmasks for SpriteKit
//

import Foundation

/// Physics category bitmasks for collision detection
struct PhysicsCategory {
    static let none:        UInt32 = 0
    static let player:      UInt32 = 0b1          // 1
    static let ground:      UInt32 = 0b10         // 2
    static let block:       UInt32 = 0b100        // 4
    static let enemy:       UInt32 = 0b1000       // 8
    static let enemyTop:    UInt32 = 0b10000      // 16 - for stomp detection
    static let coin:        UInt32 = 0b100000     // 32
    static let powerup:     UInt32 = 0b1000000    // 64
    static let pipe:        UInt32 = 0b10000000   // 128
    static let hazard:      UInt32 = 0b100000000  // 256 - pits, lava, etc.
    static let flagpole:    UInt32 = 0b1000000000 // 512
    static let shell:       UInt32 = 0b10000000000 // 1024
    static let fireball:    UInt32 = 0b100000000000 // 2048
    static let playerFeet:  UInt32 = 0b1000000000000 // 4096 - for ground detection

    /// All solid objects that stop movement
    static let allSolids: UInt32 = ground | block | pipe

    /// All collectible items
    static let allCollectibles: UInt32 = coin | powerup

    /// All damageable by player
    static let playerCanDamage: UInt32 = enemy | block
}
