//
//  Array.swift
//  MarioSpriteKitDemo
//
//  Created by Internicola, Eric on 1/8/17.
//  Copyright © 2017 iColasoft. All rights reserved.
//

import Foundation

public extension Array {

    var random: Element? {
        guard count > 0 else {
            return nil
        }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
