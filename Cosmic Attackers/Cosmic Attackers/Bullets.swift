//
//  Bullets.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 2/4/23.
//

import SpriteKit

class Bullet: SKShapeNode {
    
    override init() {
        super.init()
        let thePath = CGMutablePath()
        thePath.addRect(CGRect(x: 0, y: 0, width: 4, height: 16))
        thePath.closeSubpath()
        
        path = thePath
        strokeColor = SKColor.white
        lineWidth = 4.0
        
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 4, height: 16))
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.collisionBitMask = 0
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used!")
    }
}

class PlayerBullet : Bullet {
    override init() {
        super.init()
        physicsBody?.velocity = CGVector(dx: 0, dy: 384)
        physicsBody?.contactTestBitMask = Sprite.wall.rawValue | Sprite.enemy.rawValue
        physicsBody?.categoryBitMask = Sprite.playerBullet.rawValue
        name = "playerBullet"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used")
    }
}

class EnemyBullet : Bullet {
    override init() {
        super.init()
        physicsBody?.velocity = CGVector(dx: 0, dy: -384)
        physicsBody?.contactTestBitMask = Sprite.wall.rawValue
        physicsBody?.categoryBitMask = Sprite.enemyBullet.rawValue
        name = "enemyBullet"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used")
    }
}
