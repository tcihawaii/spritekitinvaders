//
//  GamePlayScene.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 1/2/23.
//

import SpriteKit

class GamePlayScene: SKScene, SKPhysicsContactDelegate {
    
    var gameBorder = GameBorder()
    var player = Player()
    var livesSprite = SKSpriteNode(imageNamed: "l_3")
    var livesTextures:[SKTexture] = []
    var lives = 3
    let sounds = Sounds()
    let alienPitches:[Float] = [0.0, 100.0, 200.0, 300.0, 400.0, 500.0, 600.0]
    
    var lastTouch:CGPoint?
    var reverseDirection = false
    var aliens = Set<Alien>()
    var alienSpeed:Double = 64.0
    var gameOverFlag = false
    
    override required init(size: CGSize) {
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Not used!")
    }
    
    //this returns a string in the format of "alien_00 through alien_11"
    func frameNamed(_ name:String, _ number:Int) -> String {
        return String(format: "\(name)_%02d", arguments: [number])
    }
    
    //this returns an action that animates through 12 alien frames
    func explodeAnimation() -> SKAction {
        var frames:[SKTexture] = []
        for i in 0...11 {
            let name = frameNamed("alien", i)
            frames.append(SKTexture(imageNamed: name))
        }
        return SKAction.animate(with: frames, timePerFrame: 1/24)
    }
    
    func makePlayerPiece(_ name:String) -> SKSpriteNode {
        let piece = SKSpriteNode(imageNamed: name)
        
        piece.position = player.position
        //slightly offset this piece at random to simulate breaking the ship apart
        piece.position.x += CGFloat.random(in: -32...32)
        piece.position.y += CGFloat.random(in: 16...32)
        
        piece.physicsBody = SKPhysicsBody(texture: piece.texture!, size: piece.size)
        piece.physicsBody?.velocity = player.physicsBody!.velocity
        piece.physicsBody?.collisionBitMask = Sprite.wall.rawValue
        piece.physicsBody?.categoryBitMask = Sprite.player.rawValue
        //make the piece quite bouncy and give it some initial spin and momentum
        piece.physicsBody?.restitution = 0.98
        piece.physicsBody?.angularVelocity = CGFloat.random(in: -3.14...3.14)
        
        piece.name = "piece"
        return piece
    }
    
    func explodePlayer() {
        //player loses an extra life
        lives = lives - 1
        updateLives()
        if gameOverFlag {
            sounds.play("explode1", speed: 0.25)
        } else {
            sounds.play("explode1", speed: 0.5)
        }
        //do nothing if player is hidden
        if player.alpha == 0.0 {
            return
        }
        //hide the player sprite
        player.alpha = 0.0
        
        let part1 = makePlayerPiece("player_piece_0")
        let part2 = makePlayerPiece("player_piece_1")
        let part3 = makePlayerPiece("player_piece_2")
        
        gameBorder.addChild(part1)
        gameBorder.addChild(part2)
        gameBorder.addChild(part3)
        
        //after 1.5 seconds, the player will reappear and rejoin the physics simulation
        //unless the game is now over, the player will in that case stay invisible
        if gameOverFlag == false {
            player.run(SKAction.wait(forDuration: 1.5)) {
                self.player.alpha = 1.0
                self.player.setUpPhysics()
            }
        }
        //default the player to the standard starting position
        player.position = CGPoint(x: 304, y: 4)
        //take player out of the simulation
        player.physicsBody = nil
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        part1.run(fadeOut) {
            part1.removeFromParent()
        }
        part2.run(fadeOut) {
            part2.removeFromParent()
        }
        part3.run(fadeOut) {
            part3.removeFromParent()
        }
    }
    
    func endTheGame() {
        gameOverFlag = true
        if lives >= 1 {
            explodePlayer()
        }
        let gameOverSprite = SKSpriteNode(imageNamed: "gameover")
        gameOverSprite.texture?.filteringMode = .nearest
        gameOverSprite.position = CGPoint(x: 304, y: 240)
        gameOverSprite.setScale(2.0)
        
        let wait = SKAction.wait(forDuration: 0.05)
        let sizeDown = SKAction.scale(to: 1.5, duration: 0.5)
        let sizeUp = SKAction.scale(to: 2.5, duration: 0.5)
        let seq = SKAction.sequence([sizeDown, wait, sizeUp, wait])
        let blinking = SKAction.repeat(seq, count: 6)
        gameOverSprite.run(blinking) {
            gameOverSprite.removeFromParent()
            self.lives = 3
            self.updateLives()
            self.startNewWave()
        }
        gameBorder.addChild(gameOverSprite)
    }
    
    func startNewWave() {
        gameOverFlag = false
        // reset the game scene
        for alien in aliens {
            alien.removeFromParent()
        }
        player.alpha = 1.0
        player.setUpPhysics()
        alienSpeed = 64.0
        aliens.removeAll()
        
        //set up a new game scene
        let margin = 24
        for xp in (0...10) {
            for yp in (0...4) {
                let enemy = Alien()
                aliens.insert(enemy)
                enemy.position.x = CGFloat(margin + (xp * 48))
                enemy.position.y = CGFloat(432 - (yp * 48))
                gameBorder.addChild(enemy)
            }
        }
        let startSprite = SKSpriteNode(imageNamed: "start")
        startSprite.texture?.filteringMode = .nearest
        startSprite.position = CGPoint(x: 304, y: 240)
        startSprite.setScale(2.0)
        let wait = SKAction.wait(forDuration: 0.25)
        let invis = SKAction.run {
            startSprite.alpha = 0.0
        }
        let vis = SKAction.run {
            startSprite.alpha = 1.0
        }
        let seq = SKAction.sequence([invis, wait, vis, wait])
        let blinking = SKAction.repeat(seq, count: 4)
        startSprite.run(blinking) {
            startSprite.removeFromParent()
        }
        gameBorder.addChild(startSprite)
    }
    
    func updateLives() {
        if lives <= 0 {
            livesSprite.texture = nil
            endTheGame()
        } else {
            livesSprite.texture = livesTextures[lives]
            livesSprite.texture?.filteringMode = .nearest
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        backgroundColor = SKColor.blue
        addChild(gameBorder)
        gameBorder.addChild(player)
        livesSprite.position = CGPoint(x: 64, y: 448)
        livesSprite.setScale(2.0)
        addChild(livesSprite)
        
        livesTextures.append(SKTexture(imageNamed: "alien_11")) //this is a blank texture, will be index 0
        livesTextures.append(SKTexture(imageNamed: "l_1")) //index 1
        livesTextures.append(SKTexture(imageNamed: "l_2")) //index 2
        livesTextures.append(SKTexture(imageNamed: "l_3")) //index 3
        
        sounds.preload("shoot")
        sounds.preload("explode1")
        
        updateLives()
        
        startNewWave()
        
        let timeBetweenShots = SKAction.wait(forDuration: 0.5)
        let fireShot = SKAction.run {
            if let anAlien = self.aliens.randomElement() {
                if self.gameOverFlag == false {
                    let alienBullet = EnemyBullet()
                    //offset the position to be below the alien
                    alienBullet.position.x = anAlien.position.x + 16
                    alienBullet.position.y = anAlien.position.y - 12
                    self.gameBorder.addChild(alienBullet)
                    self.sounds.play("shoot", pitch:self.alienPitches.randomElement()!)
                }
            }
        }
        let sequence = SKAction.sequence([timeBetweenShots, fireShot])
        gameBorder.run(SKAction.repeatForever(sequence))
    }
    
    override func update(_ currentTime: TimeInterval) {
        //only visible player can be moved by touches
        if player.alpha == 1.0 {
            player.update(touching: lastTouch)
        }
        if reverseDirection {
            //increase the alien speed
            if alienSpeed < 0 {
                alienSpeed = alienSpeed - 8
            } else {
                alienSpeed = alienSpeed + 8
            }
            if(alienSpeed > 1024) {
                alienSpeed = 1024
            }
            if(alienSpeed < -1024) {
                alienSpeed = -1024
            }
            //let's move all aliens in opposite direction
            alienSpeed = -alienSpeed
            //lower all aliens
            for alien in aliens {
                alien.position.y -= 8
                if alien.position.y < player.position.y {
                    endTheGame()
                }
            }
        }
        for alien in aliens {
            //if the game is over, halt all aliens in place
            if gameOverFlag == false {
                if reverseDirection == true {
                    if alienSpeed < 0 {
                        alien.position.x -= 8
                    } else {
                        alien.position.x += 8
                    }
                }
                alien.physicsBody?.velocity = CGVector(dx: alienSpeed, dy: 0)
            } else {
                alien.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
        reverseDirection = false
        if aliens.isEmpty {
            startNewWave()
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let spriteA = contact.bodyA.node
        let spriteB = contact.bodyB.node
        //print("Collision \(spriteA?.name) and \(spriteB?.name)")
        if spriteA?.name == "bounds" {
            if spriteB?.name == "alien" {
                //if aliens touch the wall/bounds they should go the other way
                reverseDirection = true
            }
            if spriteB?.name == "playerBullet" {
                spriteB?.removeFromParent()
            }
            if spriteB?.name == "enemyBullet" {
                spriteB?.removeFromParent()
            }
        }
        if spriteA?.name == "playerBullet" {
            if spriteB?.name == "alien" {
                spriteA?.removeFromParent()
                //explode the alien
                spriteB?.physicsBody = nil
                spriteB?.run(explodeAnimation()) {
                    spriteB?.removeFromParent()
                }
                sounds.play("explode1", pitch:alienPitches.randomElement()!)
                aliens.remove(spriteB as! Alien)
            }
        }
        if spriteA?.name == "player" {
            if spriteB?.name == "enemyBullet" {
                explodePlayer()
            }
        }
        if spriteA?.name == "enemyBullet" {
            if spriteB?.name == "player" {
                explodePlayer()
            }
        }
        
        //this is a game ending condition - the aliens have reached the player
        if spriteA?.name == "player" {
            if spriteB?.name == "alien" {
                endTheGame()
            }
        }
        if spriteA?.name == "alien" {
            if spriteB?.name == "player" {
                endTheGame()
            }
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        lastTouch = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        lastTouch = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
        //don't let dead player shoot on touch
        if player.alpha == 0.0 {
            return
        }
        let bullet = PlayerBullet()
        //add some offset so the bullet is at the tip of player triangle
        bullet.position.x = player.position.x + 16
        bullet.position.y = player.position.y + 24
        gameBorder.addChild(bullet)
        sounds.play("shoot")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
    }
    
}
