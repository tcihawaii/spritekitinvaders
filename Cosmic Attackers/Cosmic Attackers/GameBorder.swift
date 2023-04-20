//
//  GameBorder.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 1/2/23.
//

import SpriteKit

class GameBorder : SKShapeNode {
    
    override init() {
        super.init()
        let thePath = CGMutablePath()
        let rect = CGRect(x: 0, y: 0, width: 640, height: 480)
        thePath.addRect(rect)
        path = thePath
        strokeColor = SKColor.white
        lineWidth = 4.0
        position = CGPoint(x: 0, y: 480)
        name = "bounds"
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: thePath)
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        
        physicsBody?.categoryBitMask = Sprite.wall.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used!")
    }
    
}
