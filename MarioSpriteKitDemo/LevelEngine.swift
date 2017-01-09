//
//  LevelEngine.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import Foundation
import SpriteKit

public class LevelEngine {
    var blockSize = Brick().sprite.frame.size.width
    var scene: SKScene
    var indices: [[SpriteModel]]

    public init(scene: SKScene, spriteModels: [SpriteModel]) {
        self.scene = scene
        self.indices = LevelEngine.indices(from: spriteModels)
    }

}

// MARK: - API

public extension LevelEngine {

    public func renderAll() {
        for i in 0..<indices.count {
            render(index: i)
        }
    }

    public func render(index: Int) {
        let offset = blockSize / 2
        let x = blockSize * CGFloat(index)
        let models = indices[index]

        for model in models {
            guard let spriteRenderer = LevelEngine.createSprite(for: model) else {
                continue
            }
            let y = scene.frame.minY + blockSize * CGFloat(model.height)
            spriteRenderer.sprite.position = CGPoint(x: x - offset, y: y - offset)
            scene.addChild(spriteRenderer.sprite)
        }
    }

}

// MARK: - Helpers

private extension LevelEngine {

    enum SpriteType: String {
        case empty = "empty"
        case mario = "mario"
        case block = "block"
        case brick = "brick"
        case bush = "bush"
        case cloud = "cloud"
        case mount = "mound"
        case castle = "castle"
        case padTop = "pad_top"
        case padBottom = "pad_bottom"
    }

    static func createSprite(for model: SpriteModel) -> SpriteRenderable? {
        guard let type = SpriteType.init(rawValue: model.type) else {
            print("ERROR: Unknown type: \(model.type)")
            return nil
        }

        switch type {
        case .mario:
            return Mario.shared
        case .block:
            return Block()
        case .brick:
            return Brick()
        case .bush:
            return Bush()
        case .padBottom:
            return PadBottom()
        case .padTop:
            return PadTop()
        default:
            break
        }

        return nil
    }

    /// Converts a single dimension array to a multi dimensional array, organized by index
    ///
    /// - Parameter spriteModels: The 1-D array of SpriteModels
    /// - Returns: A multidimensional array
    static func indices(from spriteModels: [SpriteModel]) -> [[SpriteModel]] {
        var maxIndex = 0
        var modelHash = [Int: [SpriteModel]]()

        for model in spriteModels {
            if var array = modelHash[model.index] {
                array.append(model)
                modelHash[model.index] = array
            } else {
                modelHash[model.index] = [model]
            }
            maxIndex = max(maxIndex, model.index)
        }

        var indices = [[SpriteModel]]()
        for i in 0...maxIndex {
            guard let array = modelHash[i] else {
                continue
            }
            indices.append(array)
        }
        return indices
    }

}
