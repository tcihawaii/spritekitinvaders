//
//  Player.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 1/7/23.
//

import SpriteKit

class Player : SKShapeNode {
    
    override init(){
        super.init()
        
        let thePath = CGMutablePath()
        thePath.move(to:CGPoint(x:0, y:0))
        thePath.addLine(to: CGPoint(x:32, y:0))
        thePath.addLine(to: CGPoint(x: 16, y:32))
        thePath.closeSubpath()
        path = thePath
        strokeColor = SKColor.white
        lineWidth = 4.0
        position = CGPoint(x: 304, y: 4)
        name = "player"
        
        setUpPhysics()
    }
    
    func setUpPhysics() {
        physicsBody = SKPhysicsBody(polygonFrom: path!)
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 2.0
        physicsBody?.categoryBitMask = Sprite.player.rawValue
        physicsBody?.collisionBitMask = Sprite.wall.rawValue
        physicsBody?.contactTestBitMask = Sprite.enemyBullet.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used!")
    }
    
    func update(touching touch:CGPoint?) {
        guard let touch = touch else {
            return
        }
        var speed = touch.x - position.x
        if speed < -16 {
            speed = -16
        }
        if speed > 16 {
            speed = 16
        }
        physicsBody?.velocity = CGVector(dx: speed * 24, dy: 0)
    }
    
}

