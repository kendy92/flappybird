//
//  GameScene.swift
//  Game2
//
//  Created by Dinh Cong Thang on 2016-12-23.
//  Copyright © 2016 Dinh Cong Thang. All rights reserved.
//  FLAPPY BIRD CLONE

import SpriteKit
import GameplayKit

//Tao game flappy bird

struct PhysicCategory {
    static let player: UInt32 = 0x1 << 1
    static let pipes: UInt32 = 0x1 << 2
    static let ground: UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //khoi tao bien
    var background = SKSpriteNode()
    var bg = SKSpriteNode()
    var ground = SKSpriteNode()
    var pipes = SKNode()
    var scorelbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var isDie = false
    
    var player = SKSpriteNode()
    var playerTextureAtlas = SKTextureAtlas()
    var playerArrTexture = [SKTexture]()
    
    var score:Int = 0{
        didSet{
        scorelbl.text = "\(score)"
        }
    }

    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }

    
    func addPipes(){
    pipes = SKNode()
    pipes.name = "pipes"
    let topPipe = SKSpriteNode(imageNamed: "topPipe")
        topPipe.position = CGPoint(x: frame.size.width, y: frame.size.height/2 + 375)
        topPipe.yScale = 1.5
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.categoryBitMask = PhysicCategory.pipes
        topPipe.physicsBody?.contactTestBitMask = PhysicCategory.player
        topPipe.physicsBody?.collisionBitMask = PhysicCategory.player
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.affectedByGravity = false
        
    let botPipe = SKSpriteNode(imageNamed: "botPipe")
        botPipe.position = CGPoint(x: frame.size.width, y: frame.size.height/2 - 375)
        botPipe.yScale = 1.5
        botPipe.physicsBody = SKPhysicsBody(rectangleOf: botPipe.size)
        botPipe.physicsBody?.categoryBitMask = PhysicCategory.pipes
        botPipe.physicsBody?.contactTestBitMask = PhysicCategory.player
        botPipe.physicsBody?.collisionBitMask = PhysicCategory.player
        botPipe.physicsBody?.isDynamic = false
        botPipe.physicsBody?.affectedByGravity = false

        
        pipes.addChild(topPipe)
        pipes.addChild(botPipe)
        
        self.addChild(pipes)
        
        //move pipes
        let randY = random(min: -150, max: 250)
        pipes.position.y = pipes.position.y + randY
        let movePipes = SKAction.moveTo(x: -frame.size.width - 50, duration: TimeInterval(2.0))
        let removePipes = SKAction.removeFromParent()
        pipes.run(SKAction.sequence([movePipes,removePipes]))
        score = score + 1
    }
    
    func spawnPipes(){
        let spawnPipe = SKAction.run({
            () in self.addPipes()
        })
        let delaySpawn = SKAction.wait(forDuration: TimeInterval(1.2))
        let actionPipes = SKAction.sequence([spawnPipe,delaySpawn])
        self.run(SKAction.repeatForever(actionPipes))
    }
    
    func initScene(){ //Tao new scene
        backgroundColor = UIColor.white
        bg = SKSpriteNode(imageNamed: "bg")
        bg.anchorPoint = CGPoint(x: 0, y: 1)
        bg.position = CGPoint(x: 0, y: frame.size.height/2)
        //bg.setScale(CGFloat(0.5))
        bg.xScale = 1.5
        bg.yScale = 2
        bg.zPosition = -1
        self.addChild(bg)
        
        scorelbl.position = CGPoint(x: frame.width/2, y: frame.height - 100)
        scorelbl.text = "0"
        scorelbl.zPosition = 5
        scorelbl.fontSize = 60
        scorelbl.fontColor = UIColor.black
        self.addChild(scorelbl)
        
        ground = SKSpriteNode(imageNamed: "ground")
        ground.xScale = 2
        ground.position = CGPoint(x: frame.size.width/2, y: 0 + ground.size.height/6)
        ground.zPosition = 2
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicCategory.player
        ground.physicsBody?.collisionBitMask = PhysicCategory.player
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        self.addChild(ground)
        
        playerTextureAtlas = SKTextureAtlas(named: "birds")
        for i in 0...playerTextureAtlas.textureNames.count-1{
            let Name = "bird-\(i).png"
            playerArrTexture.append(SKTexture(imageNamed: Name))
        }
        player = SKSpriteNode(imageNamed: playerTextureAtlas.textureNames[0] as String)
        player.position = CGPoint(x: player.size.width, y: frame.size.height/2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicCategory.player
        player.physicsBody?.contactTestBitMask = PhysicCategory.pipes | PhysicCategory.ground
        player.physicsBody?.collisionBitMask = PhysicCategory.pipes | PhysicCategory.ground
        player.zPosition = 3
        self.addChild(player)
        flapBird()
    }
    
    func flapBird(){
       let flap = SKAction.animate(with: playerArrTexture, timePerFrame: 0.1)
        player.run(SKAction.repeatForever(flap))
    }

    override func didMove(to view: SKView) {
            self.physicsWorld.contactDelegate = self
            if(isDie == false){
                initScene()
                spawnPipes()
            }
        

    }
    
    func createBtn(){
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width: 200, height: 100)
        restartBtn.position = CGPoint(x: frame.width/2, y: frame.height/2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func restartGame(){
    self.removeAllChildren()
    self.removeAllActions()
    isDie = false
    score = 0
    initScene()
    spawnPipes()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let obj1 = contact.bodyA
        let obj2 = contact.bodyB
        
        if(obj1.categoryBitMask == PhysicCategory.player && obj2.categoryBitMask == PhysicCategory.ground ||
            obj1.categoryBitMask == PhysicCategory.ground && obj2.categoryBitMask == PhysicCategory.player){
        
            enumerateChildNodes(withName: "pipes", using: ({
                (node,error) in
                node.speed = 0
                self.removeAllActions()
            }))
            self.run(SKAction.playSoundFileNamed("sfx_die.wav", waitForCompletion: true))
            player.removeAllActions()
            if(isDie == false){
                isDie = true
                createBtn()
            }
            
        }
        if(obj1.categoryBitMask == PhysicCategory.player && obj2.categoryBitMask == PhysicCategory.pipes ||
            obj1.categoryBitMask == PhysicCategory.pipes && obj2.categoryBitMask == PhysicCategory.player){
        
            enumerateChildNodes(withName: "pipes", using: ({
                (node,error) in
                node.speed = 0
                self.removeAllActions()
            }))
            self.run(SKAction.playSoundFileNamed("sfx_hit.wav", waitForCompletion: true))
            player.removeAllActions()
            if(isDie == false){
                isDie = true
                createBtn()
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.run(SKAction.playSoundFileNamed("sfx_wing.wav", waitForCompletion: false))
        let deg = CGFloat(40.0) * CGFloat(M_PI) / 180.0
            player.physicsBody?.affectedByGravity = true
            player.run(SKAction.rotate(toAngle: CGFloat(deg), duration: 0.2))
            if(isDie == false){
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 43))
            }
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 43))

        
            for touch in touches{
                let location = touch.location(in: self)
                if(isDie == true){
                    if(restartBtn.contains(location)){
                        restartGame()
                    }
                }
            }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.2))
    }
    
    
   
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(player.frame.origin.y > frame.size.height){
            player.position.y = frame.size.height
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
        }
}
    
}
