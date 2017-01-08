
import SpriteKit


public extension SKTexture {

    /// Mario Standing Still Texture
    public static var mario: SKTexture {
        return SKTexture(imageNamed: "mario_003_0043")
    }

    /// The mario textures
    public static var marioRunTextures: [SKTexture] {
        return loadMarioTextures(from: 43, to: 47)
    }

    /// The brick texture
    public static var brickTexture: SKTexture {
        return SKTexture(imageNamed: "brick")
    }

    /// The textures for mario jumping
    public static var marioJumpTextures: [SKTexture] {
        return loadMarioTextures(from: 46, to: 50)
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

    /// Loads the textures by name and returns an array
    ///
    /// - Parameter imageNames: The names of the image textures you wish to load
    /// - Returns: The specified textures
    func loadTextures(imageNames: [String]) -> [SKTexture] {
        return imageNames.map { SKTexture(imageNamed: $0) }
    }

}
