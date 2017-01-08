import SpriteKit


class Brick {

    var sprite: SKSpriteNode?

    init() {
        sprite = Brick.createSprite()
    }
}

// MARK: - Helpers

private extension Brick {

    static func createSprite() -> SKSpriteNode {
        let texture = SKTexture.brickTexture
        let node = SKSpriteNode(texture: texture)
        node.setScale(Constants.scale)

        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.density = 1
        node.physicsBody?.isDynamic = false     // The Physics simulation SHOULD NOT move the bricks

        return node
    }

}
