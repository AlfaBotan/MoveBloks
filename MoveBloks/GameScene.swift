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
  private let levelMap: [[Int]] = [
            [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
            [1, 1, 0, 0, 1, 0, 0, 0, 1, 1],
            [1, 0, 2, 0, 1, 0, 2, 0, 0, 1],
            [1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
            [1, 1, 1, 0, 1, 1, 1, 0, 1, 1],
            [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
            [1, 0, 2, 0, 1, 0, 2, 0, 0, 1],
            [1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
            [1, 1, 0, 0, 0, 0, 3, 0, 1, 1],
            [0, 1, 1, 1, 1, 1, 1, 1, 1, 0]
        ]
    
    private let wallTexture = SKTexture(imageNamed: "wall_texture")
    private let playerTexture = SKTexture(imageNamed: "player_texture")
    private let blockTexture = SKTexture(imageNamed: "insideWall_texture")
    
    private var fieldNode = SKNode()
    private var player: SKSpriteNode!
    
    var isPlayerMoving = false
    
    //MARK: Override funcs
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        fieldNode.position = CGPoint(
                    x: size.width/2 - (tileSize * 10)/2,
                    y: size.height/2 - (tileSize * 10)/2
                )
        createLevel()
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
    
    //MARK: Funcs for create texture
    private func createLevel() {
        fieldNode.removeAllChildren()
        
        for (rowIndex, row) in levelMap.enumerated() {
            for (colIndex, tile) in row.enumerated() {
                let position = CGPoint(
                    x: CGFloat(colIndex) * tileSize + tileSize/2,
                    y: CGFloat(rowIndex) * tileSize + tileSize/2
                )
                
                switch tile {
                case 1:
                    createWall(at: position)
                case 2:
                    createBlock(at: position)
                case 3:
                    createPlayer(at: position)
                default:
                    break
                }
            }
        }
        
        addChild(fieldNode)
    }
    
    private func createWall(at position: CGPoint) {
        let wall = SKSpriteNode(color: .darkGray, size: CGSize(width: tileSize, height: tileSize))
        wall.position = position
        wall.name = "wall"
        wall.texture = wallTexture
        fieldNode.addChild(wall)
    }
    
    private func createBlock(at position: CGPoint) {
        let wall = SKSpriteNode(color: .darkGray, size: CGSize(width: tileSize, height: tileSize))
        wall.position = position
        wall.name = "block"
        wall.texture = blockTexture
        fieldNode.addChild(wall)
    }
    
    private func createPlayer(at position: CGPoint) {
            player = SKSpriteNode(texture: playerTexture)
            player.size = CGSize(width: tileSize, height: tileSize)
            player.position = position
            player.name = "player"
            
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.isDynamic = true
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.categoryBitMask = 1
            player.physicsBody?.collisionBitMask = 2
            
            fieldNode.addChild(player)
        }
    
    private func drawGrid() {
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

    //MARK: Move funcs
    private func tryMove(direction: Direction) {
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

    private func isPositionInsideField(_ position: CGPoint) -> Bool {
        let col = Int(position.x / tileSize)
        let row = Int(position.y / tileSize)
        
        guard row >= 0, col >= 0,
              row < levelMap.count,
              col < levelMap[0].count else {
            return false
        }
        
        return levelMap[row][col] != 1
    }

    private func canPushBlock(at position: CGPoint) -> Bool {
        guard isPositionInsideField(position) else { return false }
        
        let nodes = fieldNode.nodes(at: position)
        return !nodes.contains { $0.name == "wall" || $0.name == "block" }
    }

    private func moveNode(_ node: SKSpriteNode, to position: CGPoint, completion: (() -> Void)? = nil) {
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
    
    private func playShakeAnimation() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 5, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        player.run(shake)
    }
}
