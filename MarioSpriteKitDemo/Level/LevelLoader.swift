//
//  LevelLoader.swift
//  MarioSpriteKitDemo
//
//  Loads level data and creates game objects
//

import SpriteKit

class LevelLoader {

    // MARK: - Properties

    weak var scene: SKScene?
    var levelData: LevelData?

    /// Container node for all level objects
    var levelNode: SKNode = SKNode()

    /// Reference to the player
    var player: Mario?

    /// All enemies in the level
    var enemies: [Enemy] = []

    /// All blocks that can be interacted with
    var interactiveBlocks: [Tile] = []

    /// All powerups currently in the level
    var powerups: [Powerup] = []

    /// All coins currently in the level
    var coins: [CollectibleCoin] = []

    // MARK: - Loading

    func loadLevel(_ data: LevelData, into scene: SKScene) -> Mario? {
        self.scene = scene
        self.levelData = data
        self.levelNode = SKNode()
        levelNode.name = "levelNode"

        // Clear arrays
        enemies.removeAll()
        interactiveBlocks.removeAll()
        powerups.removeAll()
        coins.removeAll()

        // Set background color
        scene.backgroundColor = data.backgroundColor

        // Create level objects
        for object in data.objects {
            createObject(object)
        }

        // Add level node to scene
        scene.addChild(levelNode)

        // Create player
        let mario = Mario()
        mario.position = CGPoint(
            x: CGFloat(data.playerStartX) * GameConstants.tileSize + GameConstants.tileSize / 2,
            y: CGFloat(data.playerStartY) * GameConstants.tileSize + GameConstants.tileSize / 2
        )
        scene.addChild(mario)
        self.player = mario

        // Add level boundaries
        addLevelBoundaries(width: data.width, height: data.height)

        return mario
    }

    // MARK: - Object Creation

    private func createObject(_ obj: LevelObject) {
        switch obj.type {
        case "ground", "hardBlock":
            createGroundTile(obj)

        case "brick":
            createBrick(obj)

        case "questionBlock":
            createQuestionBlock(obj)

        case "pipe":
            createPipe(obj)

        case "goomba":
            createGoomba(obj)

        case "koopa":
            createKoopa(obj)

        case "coin":
            createCoin(obj)

        case "flagpole":
            createFlagpole(obj)

        case "castle":
            createCastle(obj)

        case "cloud":
            createCloud(obj)

        case "bush":
            createBush(obj)

        case "hill":
            createHill(obj)

        default:
            break
        }
    }

    private func createGroundTile(_ obj: LevelObject) {
        let tile = Tile(type: .ground, gridPosition: (obj.x, obj.y))
        levelNode.addChild(tile)
    }

    private func createBrick(_ obj: LevelObject) {
        var contents: BlockContents = .empty

        if let contentsStr = obj.properties["contents"] as? String {
            contents = parseBlockContents(contentsStr)
        }

        let brick = BrickBlock(gridPosition: (obj.x, obj.y), contents: contents)
        levelNode.addChild(brick)
        interactiveBlocks.append(brick)
    }

    private func createQuestionBlock(_ obj: LevelObject) {
        var contents: BlockContents = .coin

        if let contentsStr = obj.properties["contents"] as? String {
            contents = parseBlockContents(contentsStr)
        }

        let block = QuestionBlock(gridPosition: (obj.x, obj.y), contents: contents)
        levelNode.addChild(block)
        interactiveBlocks.append(block)
    }

    private func createPipe(_ obj: LevelObject) {
        let height = obj.properties["height"] as? Int ?? 2
        let enterable = obj.properties["enterable"] as? Bool ?? false

        let pipe = Pipe(gridPosition: (obj.x, obj.y), height: height, enterable: enterable)

        if let destX = obj.properties["destinationX"] as? Int,
           let destY = obj.properties["destinationY"] as? Int {
            pipe.destinationX = destX
            pipe.destinationY = destY
        }

        levelNode.addChild(pipe)
    }

    private func createGoomba(_ obj: LevelObject) {
        let position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + GameConstants.tileSize / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + GameConstants.tileSize / 2
        )
        let goomba = Goomba(position: position)
        levelNode.addChild(goomba)
        enemies.append(goomba)
    }

    private func createKoopa(_ obj: LevelObject) {
        let position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + GameConstants.tileSize / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + GameConstants.tileSize / 2
        )
        let isRed = obj.properties["red"] as? Bool ?? false
        let koopa = KoopaTroopa(position: position, isRed: isRed)
        levelNode.addChild(koopa)
        enemies.append(koopa)
    }

    private func createCoin(_ obj: LevelObject) {
        let position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + GameConstants.tileSize / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + GameConstants.tileSize / 2
        )
        let coin = CollectibleCoin(position: position)
        levelNode.addChild(coin)
        coins.append(coin)
    }

    private func createFlagpole(_ obj: LevelObject) {
        let flagpole = SKSpriteNode(color: .gray, size: CGSize(width: 8, height: GameConstants.tileSize * 10))
        flagpole.position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + GameConstants.tileSize / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + flagpole.size.height / 2
        )
        flagpole.name = "flagpole"
        flagpole.zPosition = GameConstants.ZPosition.blocks

        // Physics for flagpole
        flagpole.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 8, height: flagpole.size.height))
        flagpole.physicsBody?.categoryBitMask = PhysicsCategory.flagpole
        flagpole.physicsBody?.contactTestBitMask = PhysicsCategory.player
        flagpole.physicsBody?.collisionBitMask = 0
        flagpole.physicsBody?.isDynamic = false

        // Add flag
        let flag = SKSpriteNode(color: .green, size: CGSize(width: 16, height: 16))
        flag.position = CGPoint(x: 12, y: flagpole.size.height / 2 - 16)
        flag.name = "flag"
        flagpole.addChild(flag)

        // Add ball on top
        let ball = SKShapeNode(circleOfRadius: 6)
        ball.fillColor = .yellow
        ball.strokeColor = .clear
        ball.position = CGPoint(x: 0, y: flagpole.size.height / 2)
        flagpole.addChild(ball)

        levelNode.addChild(flagpole)
    }

    private func createCastle(_ obj: LevelObject) {
        let castle = SKSpriteNode(imageNamed: "castle")
        castle.size = CGSize(width: GameConstants.tileSize * 5, height: GameConstants.tileSize * 5)
        castle.position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + castle.size.width / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + castle.size.height / 2
        )
        castle.zPosition = GameConstants.ZPosition.backgroundDecoration
        levelNode.addChild(castle)
    }

    private func createCloud(_ obj: LevelObject) {
        let size = obj.properties["size"] as? Int ?? 1
        let cloudSize = CGSize(width: GameConstants.tileSize * CGFloat(size) * 2, height: GameConstants.tileSize * 1.5)

        let cloud = SKSpriteNode(imageNamed: "cloud_1")
        cloud.size = cloudSize
        cloud.position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + cloudSize.width / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + cloudSize.height / 2
        )
        cloud.zPosition = GameConstants.ZPosition.backgroundDecoration
        levelNode.addChild(cloud)
    }

    private func createBush(_ obj: LevelObject) {
        let size = obj.properties["size"] as? Int ?? 1
        let bushSize = CGSize(width: GameConstants.tileSize * CGFloat(size) * 1.5, height: GameConstants.tileSize)

        let bush = SKSpriteNode(imageNamed: size > 1 ? "bush_2" : "bush_1")
        bush.size = bushSize
        bush.position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + bushSize.width / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + bushSize.height / 2
        )
        bush.zPosition = GameConstants.ZPosition.backgroundDecoration
        levelNode.addChild(bush)
    }

    private func createHill(_ obj: LevelObject) {
        let size = obj.properties["size"] as? Int ?? 1
        let hillSize = CGSize(width: GameConstants.tileSize * CGFloat(size) * 3, height: GameConstants.tileSize * CGFloat(size) * 2)

        let hill = SKSpriteNode(imageNamed: "mound_1")
        hill.size = hillSize
        hill.position = CGPoint(
            x: CGFloat(obj.x) * GameConstants.tileSize + hillSize.width / 2,
            y: CGFloat(obj.y) * GameConstants.tileSize + hillSize.height / 2 - GameConstants.tileSize
        )
        hill.zPosition = GameConstants.ZPosition.background
        levelNode.addChild(hill)
    }

    // MARK: - Helpers

    private func parseBlockContents(_ str: String) -> BlockContents {
        switch str {
        case "coin": return .coin
        case "multiCoin": return .multiCoin
        case "mushroom": return .mushroom
        case "fireFlower": return .fireFlower
        case "star": return .star
        case "oneUp": return .oneUp
        default: return .empty
        }
    }

    private func addLevelBoundaries(width: Int, height: Int) {
        guard let scene = scene else { return }

        // Bottom death zone
        let deathZone = SKNode()
        deathZone.position = CGPoint(x: CGFloat(width) * GameConstants.tileSize / 2, y: -GameConstants.tileSize)
        let deathBody = SKPhysicsBody(rectangleOf: CGSize(width: CGFloat(width) * GameConstants.tileSize, height: GameConstants.tileSize))
        deathBody.categoryBitMask = PhysicsCategory.hazard
        deathBody.contactTestBitMask = PhysicsCategory.player
        deathBody.collisionBitMask = 0
        deathBody.isDynamic = false
        deathZone.physicsBody = deathBody
        deathZone.name = "deathZone"
        scene.addChild(deathZone)

        // Left boundary
        let leftWall = SKNode()
        leftWall.position = CGPoint(x: -16, y: CGFloat(height) * GameConstants.tileSize / 2)
        let leftBody = SKPhysicsBody(rectangleOf: CGSize(width: 32, height: CGFloat(height) * GameConstants.tileSize * 2))
        leftBody.categoryBitMask = PhysicsCategory.ground
        leftBody.isDynamic = false
        leftWall.physicsBody = leftBody
        scene.addChild(leftWall)
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval, cameraX: CGFloat) {
        // Activate enemies that are on screen
        let screenLeft = cameraX - GameConstants.sceneWidth / 2
        let screenRight = cameraX + GameConstants.sceneWidth / 2 + GameConstants.tileSize * 2

        for enemy in enemies where enemy.parent != nil {
            if enemy.position.x >= screenLeft && enemy.position.x <= screenRight {
                enemy.update(deltaTime: deltaTime)
            }
        }

        // Update powerups
        for powerup in powerups where powerup.parent != nil {
            powerup.update(deltaTime: deltaTime)
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        levelNode.removeFromParent()
        enemies.removeAll()
        interactiveBlocks.removeAll()
        powerups.removeAll()
        coins.removeAll()
        player = nil
    }
}
