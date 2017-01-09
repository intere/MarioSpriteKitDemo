//
//  SpriteEngine.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import SpriteKit

public class SpriteModel {
    var type: String = ""
    var index: Int = 0
    var height: Int = 0

    init() {}

    init(type: String = "", index: Int = 0, height: Int = 0) {
        self.type = type
        self.index = index
        self.height = 0
    }
}

// MARK: - Serialization / Deserialization

public extension SpriteModel {

    public func toMap() -> [String: Any] {
        return [
            "type": type,
            "index": index,
            "height": height
        ]
    }

    static func fromMap(map: [String: Any]) -> SpriteModel? {
        guard let type = map["type"] as? String,
            let index = map["index"] as? Int,
            let height = map["height"] as? Int else
        {
            return nil
        }
        let model = SpriteModel()
        model.type = type
        model.index = index
        model.height = height
        return model
    }
}
