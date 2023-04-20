//
//  Alien.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 1/14/23.
//

import SpriteKit

class Alien : SKSpriteNode {
    
    override init(texture:SKTexture?, color: UIColor, size:CGSize) {
        super.init(texture:texture, color:color, size: size)
        
        self.size.width = 32
        self.size.height = 32
        name = "alien"
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width)
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        
        physicsBody?.categoryBitMask = Sprite.enemy.rawValue
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = Sprite.wall.rawValue | Sprite.playerBullet.rawValue | Sprite.player.rawValue
    }
    
    convenience init() {
        let tex = SKTexture(imageNamed:"alien")
        tex.filteringMode = .nearest
        self.init(texture:tex, color: UIColor.white, size: tex.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used!")
    }
    
}
