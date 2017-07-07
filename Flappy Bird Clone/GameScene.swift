//
//  GameScene.swift
//  Flappy Bird Clone
//
//  Created by pratik on 24/09/16.
//  Copyright © 2016 Purteeek. All rights reserved.
//

import SpriteKit
import GameplayKit
import  AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
   
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var gameOver = false
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    var score = 0
    var LastScore = 0
    var time = 0
    var times = 0
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    enum collider : UInt32 {
        case bird = 1
        case object = 2
        case gap = 4
    }
    func spawnPipes(){ //function for pipe spawns at random positions with a fixed gap in between
        let movePipe = SKAction.move(by: CGVector(dx : -2 * self.frame.width, dy : 0), duration: TimeInterval(self.frame.width/100))
        let gapHeight = bird.size.height * 4
        let pipeMovement = arc4random() % UInt32(self.frame.height/2)
        let pipeOffset = CGFloat(pipeMovement) - self.frame.height/4
        let abovePipe = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: abovePipe)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1.size.height/2 + gapHeight/2 + pipeOffset)
        pipe1.run(movePipe)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: abovePipe.size())
        pipe1.physicsBody!.isDynamic = false
        pipe1.physicsBody!.contactTestBitMask = collider.object.rawValue
        pipe1.physicsBody!.categoryBitMask = collider.object.rawValue
        pipe1.physicsBody!.collisionBitMask = collider.object.rawValue
        
        self.addChild(pipe1)
        
        let belowPipe = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: belowPipe)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe1.size.height/2 - gapHeight/2 + pipeOffset)
        pipe2.run(movePipe)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: belowPipe.size())
        
        pipe2.physicsBody!.isDynamic = false
        
        pipe2.physicsBody!.contactTestBitMask = collider.object.rawValue
        pipe2.physicsBody!.categoryBitMask = collider.object.rawValue
        pipe2.physicsBody!.collisionBitMask = collider.object.rawValue
        self.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1.size.width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(movePipe)
        gap.physicsBody!.contactTestBitMask = collider.bird.rawValue
        gap.physicsBody!.categoryBitMask = collider.gap.rawValue
        gap.physicsBody!.collisionBitMask = collider.gap.rawValue
        
        self.addChild(gap)
        time += 1

        
        
    }
    override func didMove(to view: SKView) {
        
        
         physicsWorld.contactDelegate = self
       
        
        setupGame()
        
    }
    
   
    
    
    
    
    
    func setupGame() {
        
        let bgtexture = SKTexture(imageNamed: "bg.png")
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgtexture.size().width, dy: 0), duration: 9)
        let moveBGtoposition = SKAction.move(by: CGVector(dx: bgtexture.size().width, dy: 0), duration: 0)
        let movebackgroundforever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation,moveBGtoposition]))
        var i : CGFloat = 0
        
        while(i < 3){
            bg = SKSpriteNode(texture: bgtexture)
            bg.position = CGPoint(x: bgtexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(movebackgroundforever)
            bg.zPosition = -1
            self.addChild(bg)
            i += 1
        }
        
        
        let birdSprite = SKTexture(imageNamed: "flappy1.png")
        let birdSprite2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animate(with: [birdSprite,birdSprite2], timePerFrame: 0.2)
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdSprite)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdSprite.size().height / 2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = collider.gap.rawValue
        bird.physicsBody!.categoryBitMask = collider.object.rawValue
        bird.physicsBody!.collisionBitMask = collider.object.rawValue
        self.addChild(bird)
        
        
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.contactTestBitMask = collider.object.rawValue
        ground.physicsBody!.categoryBitMask = collider.object.rawValue
        ground.physicsBody!.collisionBitMask = collider.object.rawValue
        
        addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 70)
        scoreLabel.fontColor = UIColor.black
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
       
        if gameOver == false {
           
        if contact.bodyA.categoryBitMask == collider.gap.rawValue ||  contact.bodyB.categoryBitMask == collider.gap.rawValue {
            
            score += 1
            scoreLabel.text = String(score)
        } else
        {
            
            
            LastScore = score
            
            
            
            if let x = UserDefaults.standard.value(forKey: "Highscore") as? Int{
                if x <= LastScore{
                
                    UserDefaults.standard.set(LastScore, forKey: "Highscore")
                    print(LastScore)
                    highScoreLabel.fontName = "Hacked"
                    highScoreLabel.fontSize = 40
                    
                    highScoreLabel.text = "Current Score : \(score) & Highest Score : \(LastScore) "
                    highScoreLabel.fontColor = UIColor.black
                    highScoreLabel.position = CGPoint(x: self.frame.midX  , y: self.frame.midY + 80)
                    highScoreLabel.zPosition = 1
                    addChild(highScoreLabel)
                }
                else if x > LastScore{
                    highScoreLabel.fontName = "Hacked"
                    highScoreLabel.fontSize = 40
                    
                    highScoreLabel.text = "Current Score : \(score) & Highest Score : \(x) "
                    highScoreLabel.fontColor = UIColor.black
                    highScoreLabel.position = CGPoint(x: self.frame.midX  , y: self.frame.midY + 60)
                    highScoreLabel.zPosition = 1
                    addChild(highScoreLabel)
                    print(x)
                }
                
               
            }else{
                highScoreLabel.fontName = "Hacked"
                highScoreLabel.fontSize = 40
                
                highScoreLabel.text = "Current Score : \(score) & Highest Score : \(LastScore) "
                highScoreLabel.fontColor = UIColor.black
                highScoreLabel.position = CGPoint(x: self.frame.midX  , y: self.frame.midY + 60)
                highScoreLabel.zPosition = 1

                UserDefaults.standard.setValue(LastScore, forKey: "Highscore")
                print(LastScore)
                addChild(highScoreLabel)
            }
            timer.invalidate()
            gameOverLabel.fontName = "Hacked"
            gameOverLabel.fontSize = 50
            
            gameOverLabel.text = "Game Over! Tap To Play Again "
            gameOverLabel.fontColor = UIColor.black
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            gameOverLabel.zPosition = 1
            self.addChild(gameOverLabel)
            
            
            self.speed = 0
            gameOver = true
            
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
            timerplay()
            
        
        bird.physicsBody!.isDynamic = true
        bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 60))
        }else {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            time = 0
            times = 0
            setupGame()
            
        }
        
    }
    func timerplay(){
        if times == 0 {
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.spawnPipes), userInfo: nil, repeats: true)
            times += 1
            
            
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if time == 3 {
            bird.physicsBody!.isDynamic = true
        }
        // Called before each frame is rendered
    }
}
