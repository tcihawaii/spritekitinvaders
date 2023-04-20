//
//  GameViewController.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 1/2/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GamePlayScene(size: CGSize(width: 640, height: 960))
        scene.scaleMode = .aspectFit
        let view = self.view as! SKView
        view.showsFPS = false
        view.showsPhysics = false
        view.showsNodeCount = false
        view.presentScene(scene)
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
