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
//        drawGrid()
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
            wall.name = "wall"
            wall.texture = blockTexture
            fieldNode.addChild(wall)
        }
    }
    
    func setupPlayer() {
            player = SKSpriteNode(texture: playerTexture)
            player.size = CGSize(width: tileSize, height: tileSize)
            player.position = CGPoint(
                x: 1 * tileSize + tileSize/2, // Центр поля (5,5)
                y: 1 * tileSize + tileSize/2
            )
            player.name = "player"
            
            // Настройка физического тела
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.isDynamic = true
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.categoryBitMask = 1 // Категория игрока
            player.physicsBody?.collisionBitMask = 2 // Столкновения со стенами/блоками
            
            fieldNode.addChild(player)
        }
    
    func drawGrid() {
        let rows = 10
        let cols = 10
        
        for row in 0...rows {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: CGFloat(row) * tileSize))
            path.addLine(to: CGPoint(x: CGFloat(cols) * tileSize, y: CGFloat(row) * tileSize))
            line.path = path
            line.strokeColor = SKColor.lightGray.withAlphaComponent(0.5)
            line.lineWidth = 0.5
            fieldNode.addChild(line)
        }
        
        for col in 0...cols {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(col) * tileSize, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(rows) * tileSize))
            line.path = path
            line.strokeColor = SKColor.lightGray.withAlphaComponent(0.5)
            line.lineWidth = 0.5
            fieldNode.addChild(line)
        }
    }
}
