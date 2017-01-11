
import SpriteKit


/// Manages the Player: Mario
public class Mario: SpriteRenderable {

    static let shared = Mario()

    public var sprite: SKSpriteNode = Mario.createSprite()

    struct Actions {
        static let run = SKAction.animate(with: SKTexture.marioRun, timePerFrame: 0.1, resize: true, restore: true)
        static let jump = SKAction.animate(with: SKTexture.marioJump, timePerFrame: 0.1, resize: true, restore: true)
        static let stop = SKAction.animate(withNormalTextures: [SKTexture.mario], timePerFrame: 0.1, resize: true, restore: true)
        static let turnLeft = SKAction.scaleX(to: -Constants.marioScale, duration: 0.1)
        static let turnRight = SKAction.scaleX(to: Constants.marioScale, duration: 0.1)
        static let moveRight = SKAction.moveBy(x: 15, y: 0, duration: 0.1)
        static let moveLeft = SKAction.moveBy(x: -15, y: 0, duration: 0.1)
    }

    internal var state: MotionState = .StoppedRight

    enum MotionState: Int {
        case StoppedRight = 0
        case StoppedLeft
        case RunRight
        case RunLeft
        case JumpRight
        case JumpLeft
    }

    /// Creates the Sprite
    ///
    /// - Returns: A SpriteNode for mario.
    public static func createSprite() -> SKSpriteNode {
        let node = SKSpriteNode(texture: SKTexture.mario)
        node.setScale(Constants.marioScale)

        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.density = 0.5
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = false

        return node
    }
}

// MARK: - API

public extension Mario {

    /// Runs to the Right
    func runRight() {
        sprite.removeAllActions()
        switch state {
        case .RunRight:
            return
        case .JumpLeft, .RunLeft, .StoppedLeft:
            stopRight()
            return
        default:
            break
        }
        sprite.run(SKAction.repeatForever(Actions.run))
        sprite.run(SKAction.repeatForever(Actions.moveRight))
        state = .RunRight
        print("Run Right")
    }

    /// Runs to the Left
    func runLeft() {
        sprite.removeAllActions()
        switch state {
        case .RunLeft:
            return
        case .JumpRight, .RunRight, .StoppedRight:
            stopLeft()
            return
        default:
            break
        }
        sprite.run(SKAction.repeatForever(Actions.run))
        sprite.run(SKAction.repeatForever(Actions.moveLeft))
        state = .RunLeft
        print("Run Left")
    }

    /// Jumps in the air
    func jump() {
        print("Jump")
        guard state != .JumpRight && state != .JumpLeft else {
            return
        }
        let initialState = state
        setJumpState()

        sprite.removeAllActions()
        let action = SKAction.applyForce(CGVector(dx: 0, dy: 200), duration: 0.1)
        action.timingMode = .easeOut
        sprite.run(action)

        if state == .JumpLeft {
            sprite.run(SKAction.repeatForever(Actions.moveLeft))
        } else if state == .JumpRight {
            sprite.run(SKAction.repeatForever(Actions.moveRight))
        }
        sprite.run(Actions.jump) {
            self.sprite.run(SKAction.wait(forDuration: 0.1)) {
                self.goBack(to: initialState)
            }
        }

    }
}

// MARK: - Helpers

private extension Mario {

    /// Sets the appropriate jump state, based on the current state
    func setJumpState() {
        switch state {
        case .RunLeft:
            state = .JumpLeft
        case .RunRight:
            state = .JumpRight
        default:
            break
        }
    }

    /// Invokes the correct action based on the provided state
    ///
    /// - Parameter state: The state to reset back to
    func goBack(to state: MotionState) {
        switch state {
        case .RunLeft:
            runLeft()
        case .RunRight:
            runRight()
        case .StoppedLeft:
            stopLeft()
        case .StoppedRight:
            stopRight()
        default:
            break
        }
    }

    /// Stops looking to the left
    func stopLeft() {
        sprite.removeAllActions()
        sprite.run(Actions.turnLeft)
        sprite.run(SKAction.repeatForever(Actions.stop))
        state = .StoppedLeft
    }

    /// Stops looking to the right
    func stopRight() {
        sprite.removeAllActions()
        sprite.run(Actions.turnRight)
        sprite.run(SKAction.repeatForever(Actions.stop))
        state = .StoppedRight
    }

}
