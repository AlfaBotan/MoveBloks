//
//  GameViewController.swift
//  MoveBloks
//
//  Created by Илья Волощик on 14.04.25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
                   let scene = GameScene(size: CGSize(width: 800, height: 800))
                   scene.scaleMode = .resizeFill
                   view.presentScene(scene)
                   view.ignoresSiblingOrder = true
                   view.showsFPS = false
                   view.showsNodeCount = false
               }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
