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
    static let blockSize = Brick().sprite.frame.size.width
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
        let models = indices[index]

        for model in models {
            guard let endIndex = model.endIndex else {
                let _ = createSprite(for: model, x: index)
                continue
            }
            for x in index...endIndex {
                let _ = createSprite(for: model, x: x)
            }
        }
    }

}

// MARK: - Helpers

private extension LevelEngine {

    enum SpriteType: String {
        case empty = "empty"
        case mario = "mario"
        case goomba = "goomba"
        case block = "block"
        case brick = "brick"
        case pipe = "pipe"
        case bush = "bush"
        case cloud = "cloud"
        case mount = "mound"
        case castle = "castle"
        case padTop = "pad_top"
        case padBottom = "pad_bottom"
    }

    func createSprite(for model: SpriteModel, x index: Int) -> SpriteRenderable? {
        let blockSize = LevelEngine.blockSize
        let offset = blockSize / 2
        let x = blockSize * CGFloat(index)
        let y = scene.frame.minY + blockSize * CGFloat(model.height)
        guard let spriteRenderer = LevelEngine.createSprite(for: model) else {
            return nil
        }

        spriteRenderer.sprite.position = CGPoint(x: x - offset, y: y - offset)
        scene.addChild(spriteRenderer.sprite)
        if let enemy = spriteRenderer as? Enemy {
            enemy.startMoving()
        }
        return spriteRenderer
    }

    static func createSprite(for model: SpriteModel) -> SpriteRenderable? {
        guard let type = SpriteType.init(rawValue: model.type) else {
            print("ERROR: Unknown type: \(model.type)")
            return nil
        }

        switch type {
        case .mario:
            return Mario.shared
        case .goomba:
            return Goomba()
        case .block:
            return Block()
        case .brick:
            return Brick()
        case .pipe:
            return Pipe()
        case .bush:
            return Bush()
        case .cloud:
            return Cloud()
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

        let copyBlock = { (_ model: SpriteModel) in
            if var array = modelHash[model.index] {
                array.append(model)
                modelHash[model.index] = array
            } else {
                modelHash[model.index] = [model]
            }
            maxIndex = max(maxIndex, model.index)
        }

        for model in spriteModels {
            guard let endIndex = model.endIndex else {
                copyBlock(model)
                continue
            }
            for i in model.index...endIndex {
                let aModel = SpriteModel(type: model.type, index: i, height: model.height)
                copyBlock(aModel)
            }
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
