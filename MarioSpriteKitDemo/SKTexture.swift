
import SpriteKit


public extension SKTexture {

    /// Mario Standing Still Texture
    public static var mario: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "mario_003_0043"))
    }

    /// Goombas
    public static var goomba: [SKTexture] {
        return [SKTexture(image: #imageLiteral(resourceName: "goomba_1")), SKTexture(image: #imageLiteral(resourceName: "goomba_2"))]
    }

    /// Dead Goomba
    public static var goombaDead: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "goomba_dead"))
    }

    /// The mario textures
    public static var marioRun: [SKTexture] {
        return loadMarioTextures(from: 43, to: 47)
    }

    /// The brick texture
    public static var brick: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "brick"))
    }

    /// The pipe texture
    public static var pipe: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "pipe"))
    }

    /// The "Pad Top"
    public static var padTop: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "pad_top"))
    }

    /// The "Pad Bottom"
    public static var padBottom: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "pad_bottom"))
    }

    /// The texture for a question block
    public static var block: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "item_block"))
    }

    /// The texture for a question block that's been used
    public static var spentBlock: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "item_used"))
    }

    /// The textures for mario jumping
    public static var marioJump: [SKTexture] {
        return loadMarioTextures(from: 46, to: 50)
    }

    /// The textures for the bushes
    public static var bushes: [SKTexture] {
        return [ SKTexture(image: #imageLiteral(resourceName: "bush_1")), SKTexture(image: #imageLiteral(resourceName: "bush_2")) ]
    }

    /// The textures for the clouds
    public static var clouds: [SKTexture] {
        return [ SKTexture(image: #imageLiteral(resourceName: "cloud_1")), SKTexture(image: #imageLiteral(resourceName: "cloud_2")) ]
    }

    /// The textures for the mounds
    public static var mounds: [SKTexture] {
        return [ SKTexture(image: #imageLiteral(resourceName: "mound_1")), SKTexture(image: #imageLiteral(resourceName: "mound_2")) ]
    }

    /// The castle
    public static var castle: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "castle"))
    }
}

// MARK: - Helpers

private extension SKTexture {

    /// Helps by loading mario textures starting at the index you provide (from) ending at the index you provide (to).
    ///
    /// - Parameters:
    ///   - from: Staring index
    ///   - to: Ending index
    /// - Returns: The textures that you specified
    static func loadMarioTextures(from: Int, to: Int) -> [SKTexture] {
        var textures = [SKTexture]()
        for index in from...to {
            let imageName = "mario_003_00" + String(index)
            guard let image = UIImage(named: imageName) else {
                print("Error loading image: \(imageName)")
                continue
            }
            let texture = SKTexture(image: image)
            textures.append(texture)
        }
        return textures
    }

}
