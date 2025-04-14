//
//  GameScene.swift
//  MoveBloks
//
//  Created by Илья Волощик on 14.04.25.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    
  private  let tileSize: CGFloat = 40.0
    private let wallTexture = SKTexture(imageNamed: "wall_texture")
    private let playerTexture = SKTexture(imageNamed: "player_texture")
    private let blockTexture = SKTexture(imageNamed: "insideWall_texture")
    
    private var fieldNode = SKNode()
    private var player: SKSpriteNode!
    
    var isPlayerMoving = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        fieldNode.position = CGPoint(
            x: size.width/2 - (tileSize * 10)/2,
            y: size.height/2 - (tileSize * 10)/2
        )
        addChild(fieldNode)
        
        setupWalls()
        setupBloks()
        setupPlayer()
        drawGrid()
    }
    
    func setupWalls() {
        let rows = 10
        let cols = 10
        
        for row in 0..<rows {
            for col in 0..<cols {
                if row == 0 || row == rows - 1 || col == 0 || col == cols - 1 {
                    let wall = SKSpriteNode(color: .darkGray, size: CGSize(width: tileSize, height: tileSize))
                    wall.position = CGPoint(
                        x: CGFloat(col) * tileSize + tileSize / 2,
                        y: CGFloat(row) * tileSize + tileSize / 2
                    )
                    wall.name = "wall"
                    wall.texture = wallTexture
                    fieldNode.addChild(wall)
                }
            }
        }
    }
    
    func setupBloks() {
        let internalWallsPositions = [
            CGPoint(x: 2, y: 2),
            CGPoint(x: 5, y: 5),
            CGPoint(x: 7, y: 3)
        ]
        
        for pos in internalWallsPositions {
            let wall = SKSpriteNode(color: .darkGray, size: CGSize(width: tileSize, height: tileSize))
            wall.position = CGPoint(
                x: pos.x * tileSize + tileSize / 2,
                y: pos.y * tileSize + tileSize / 2
            )
            wall.name = "block"
            wall.texture = blockTexture
            fieldNode.addChild(wall)
        }
    }
    
    func setupPlayer() {
            player = SKSpriteNode(texture: playerTexture)
            player.size = CGSize(width: tileSize, height: tileSize)
            player.position = CGPoint(
                x: 1 * tileSize + tileSize/2,
                y: 1 * tileSize + tileSize/2
            )
            player.name = "player"
            
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.isDynamic = true
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.categoryBitMask = 1
            player.physicsBody?.collisionBitMask = 2
            
            fieldNode.addChild(player)
        }
    
    func drawGrid() {
            let gridColor = SKColor.lightGray.withAlphaComponent(0.3)
            
            for row in 0...10 {
                let line = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: CGFloat(row) * tileSize))
                path.addLine(to: CGPoint(x: 10 * tileSize, y: CGFloat(row) * tileSize))
                line.path = path
                line.strokeColor = gridColor
                line.lineWidth = 0.5
                fieldNode.addChild(line)
            }
            
            for col in 0...10 {
                let line = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: CGFloat(col) * tileSize, y: 0))
                path.addLine(to: CGPoint(x: CGFloat(col) * tileSize, y: 10 * tileSize))
                line.path = path
                line.strokeColor = gridColor
                line.lineWidth = 0.5
                fieldNode.addChild(line)
            }
        }
    
    enum Direction {
        case up, down, left, right
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
       
        let location = touch.location(in: fieldNode)
        
        let dx = location.x - player.position.x
        let dy = location.y - player.position.y
        
        if abs(dx) > abs(dy) {
            tryMove(direction: dx > 0 ? .right : .left)
        } else {
            tryMove(direction: dy > 0 ? .up : .down)
        }
    }

    func tryMove(direction: Direction) {
        guard isPlayerMoving == false else {return}
        
        let movementVector: CGVector
        switch direction {
        case .up:    movementVector = CGVector(dx: 0, dy: tileSize)
        case .down:  movementVector = CGVector(dx: 0, dy: -tileSize)
        case .left:  movementVector = CGVector(dx: -tileSize, dy: 0)
        case .right: movementVector = CGVector(dx: tileSize, dy: 0)
        }
        
        let newPlayerPosition = CGPoint(
            x: player.position.x + movementVector.dx,
            y: player.position.y + movementVector.dy
        )
        
        guard isPositionInsideField(newPlayerPosition) else {
            playShakeAnimation()
            return
        }
        
        let nodesAtPosition = fieldNode.nodes(at: newPlayerPosition)
        
        if nodesAtPosition.contains(where: { $0.name == "wall" }) {
            playShakeAnimation()
            return
        }
        
        if let block = nodesAtPosition.first(where: { $0.name == "block" }) as? SKSpriteNode {
            let newBlockPosition = CGPoint(
                x: block.position.x + movementVector.dx,
                y: block.position.y + movementVector.dy
            )
            
            if canPushBlock(at: newBlockPosition) {
                isPlayerMoving = true
                moveNode(block, to: newBlockPosition)
                moveNode(player, to: newPlayerPosition)
            } else {
                playShakeAnimation()
            }
        } else {
            isPlayerMoving = true
            moveNode(player, to: newPlayerPosition)
        }
    }

    func isPositionInsideField(_ position: CGPoint) -> Bool {
        return position.x >= tileSize/2 &&
               position.y >= tileSize/2 &&
               position.x <= tileSize * 10 - tileSize/2 &&
               position.y <= tileSize * 10 - tileSize/2
    }

    func canPushBlock(at position: CGPoint) -> Bool {
        guard isPositionInsideField(position) else { return false }
        
        let nodes = fieldNode.nodes(at: position)
        return !nodes.contains { $0.name == "wall" || $0.name == "block" }
    }

    func moveNode(_ node: SKSpriteNode, to position: CGPoint, completion: (() -> Void)? = nil) {
        let moveAction = SKAction.move(to: position, duration: 0.2)
        
        if let completion = completion {
            node.run(SKAction.sequence([
                moveAction,
                SKAction.run { [weak self] in
                    self?.isPlayerMoving = false
                    completion()
                }
            ]))
        } else {
            node.run(SKAction.sequence([
                moveAction,
                SKAction.run { [weak self] in
                    self?.isPlayerMoving = false
                }
            ]))
        }
    }
    
    func playShakeAnimation() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        player.run(shake)
    }
}
