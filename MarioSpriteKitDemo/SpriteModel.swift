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
    var endIndex: Int?
    var height: Int = 0

    init() {}

    init(type: String = "", index: Int = 0, endIndex: Int? = nil, height: Int = 0) {
        self.type = type
        self.index = index
        self.endIndex = endIndex
        self.height = height
    }
}

// MARK: - Serialization / Deserialization

public extension SpriteModel {

    public func toMap() -> [String: Any] {
        var map: [String: Any] = [
            "type": type,
            "index": index,
            "height": height
        ]
        if let endIndex = endIndex {
            map["endIndex"] = endIndex
        }
        return map
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
        if let endIndex = map["endIndex"] as? Int {
            model.endIndex = endIndex
        }
        return model
    }
}
