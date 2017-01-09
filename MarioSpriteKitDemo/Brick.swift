
import SpriteKit

class Brick: SpriteRenderable {

    public var sprite = Brick.createSprite()

    static func createSprite() -> SKSpriteNode {
        let texture = SKTexture.brick
        let node = SKSpriteNode(texture: texture)
        node.setScale(Constants.scale)

        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.density = 1
        node.physicsBody?.isDynamic = false     // The Physics simulation SHOULD NOT move the bricks

        return node
    }

}
