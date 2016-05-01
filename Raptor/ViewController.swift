//
//  ViewController.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    private var _sprites = [Sprite]()
    private var _backgroundSprite = Sprite()
    private var _lastUpdate: NSDate = NSDate()
    
    private var _circleTexture: GLKTextureInfo? = nil
    private var _ship: GLKTextureInfo? = nil
    private var _asteroid: GLKTextureInfo? = nil
    private var _background: GLKTextureInfo? = nil

    
    // look up the documention on update
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let glkView: GLKView = view as! GLKView
        glkView.context = EAGLContext(API: .OpenGLES2)
        glkView.drawableColorFormat = .RGBA8888 // 32-bit color format
        EAGLContext.setCurrentContext(glkView.context)
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // called once everytime the view is created.
    // you can set a setting once and openGL will continue to use that setting
    // until you change that setting. OpenGL is a state machine.
    private func setup() {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        // load the textures
        _circleTexture = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "circle")!.CGImage!, options: nil)
        
        _ship = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "ship")!.CGImage!, options: nil)
        
        _asteroid = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "asteroid")!.CGImage!, options: nil)
        
        _background = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "background.jpg")!.CGImage!, options: nil)
        
        constructBackgroundSprite()
        
        let sprite: Sprite = Sprite()
        sprite.animation.texture = _asteroid!.name
        sprite.animation.textureX = 1024
        sprite.animation.textureY = 1024
        sprite.animation.frameHeight = 100
        sprite.animation.frameWidth = 90
        sprite.animation.rows = 8
        sprite.animation.columns = 8
        sprite.animation.frameX = 15
        sprite.animation.frameY = 10
        sprite.animation.framesPerAnimation = 3
        sprite.width = 0.25
        sprite.height = 0.25
        sprite.initialPosition.y = 1
        sprite.initialPosition.x = 0
        sprite.velocity.x = 0.0;
        sprite.velocity.y = -0.3;
        sprite.isEnemy = true
        
        _sprites.append(sprite)
        
        
        let sprite2: Sprite = Sprite()
        sprite2.animation.texture = _circleTexture!.name
        sprite2.animation.textureX = 1024
        sprite2.animation.textureY = 1024
        sprite2.animation.frameHeight = 1024
        sprite2.animation.frameWidth = 1024
        sprite2.animation.frameX = 0
        sprite2.animation.frameY = 0
        sprite2.width = 0.05
        sprite2.height = 0.05
        sprite2.initialPosition.y = 1
        sprite2.velocity.x = 0
        sprite2.velocity.y = -0.5
        sprite2.isPlayerBullet = true
        
       // _sprites.append(sprite2)
    }
    
    // runs right before drawInRect is called. You can think of this as your game loop.
    func update() {
        
        let now = NSDate()
        let elapsed = now.timeIntervalSinceDate(_lastUpdate)
        
        // Update sprite's locations
        updateSpritesLocations(elapsed)
       
        // Collision detection
        detectCollisions()
    }
    
    func updateSpritesLocations(elapsed: Double) {
        for sprite in _sprites {
            sprite.position.x = sprite.initialPosition.x + Double(elapsed * sprite.velocity.x)
            sprite.position.y = sprite.initialPosition.y + Double(elapsed * sprite.velocity.y)
        }
    }
    
    func detectCollisions() {
        for (index, sprite) in _sprites.enumerate() {
            for (indexTwo, spriteTwo) in _sprites.enumerate() {
                if index != indexTwo {
                    // (x2-x1)^2 + (y1-y2)^2 <= (r1+r2)^2
                    let xPos = (spriteTwo.position.x - sprite.position.x) * (spriteTwo.position.x - sprite.position.x)
                    let yPos = (sprite.position.y - spriteTwo.position.y) * (sprite.position.y - spriteTwo.position.y)
                    let radius = ((sprite.height/2.0 + spriteTwo.height/2.0) * (sprite.height/2.0 + spriteTwo.height/2.0))
                    if xPos + yPos <= Double(radius) {
                        collision(sprite, spriteIndex: index, spriteTwo: spriteTwo, spriteTwoIndex: indexTwo)
                    }

                }
            }
        }
    }
    
    func collision(sprite: Sprite, spriteIndex: Int, spriteTwo: Sprite, spriteTwoIndex: Int) {
        // player bullet and enemy collision
        if sprite.isPlayerBullet && spriteTwo.isEnemy || sprite.isEnemy && sprite.isPlayerBullet {
            print("Bullet hit an enemy!")
            if sprite.isEnemy {
                _sprites.removeAtIndex(spriteIndex)
            }
            
            if spriteTwo.isEnemy {
                _sprites.removeAtIndex(spriteTwoIndex)
            }
        }
        
        // player and enemy collision
        if sprite.isPlayer && spriteTwo.isEnemy || sprite.isPlayer && sprite.isPlayerBullet {
            print("Player has collided with an enemy!")
        }
        
        // player and enemy bullet collision
        if sprite.isPlayer && spriteTwo.isEnemyBullet || sprite.isPlayer && sprite.isEnemyBullet {
            print("Bullet hit the player!")
        }
    }
    
    // Called everytime GLK should refresh it's view
    // Redrawing every pixel every frame at about 60 FPS (this is adjustable)
    // This can be thought of as the draw loop.
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        // Makes the sprite square
        let height: GLsizei = GLsizei(view.bounds.height * view.contentScaleFactor)
        let offset: GLint = GLint((view.bounds.height - view.bounds.width) * -0.5 * view.contentScaleFactor)
        glViewport(offset, 0, height, height)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        _backgroundSprite.drawBackground()
        
        for sprite in _sprites {
            sprite.draw()
        }
    }
    
    func constructBackgroundSprite() {
        
        _backgroundSprite.animation.texture = _background!.name
        _backgroundSprite.animation.textureX = 1080
        _backgroundSprite.animation.textureY = 1920
        _backgroundSprite.animation.frameHeight = 500
        _backgroundSprite.animation.frameWidth = 500
        _backgroundSprite.animation.rows = 1
        _backgroundSprite.animation.columns = 4
        _backgroundSprite.animation.frameX = 0
        _backgroundSprite.animation.frameY = 0
        _backgroundSprite.animation.framesPerAnimation = 1
        _backgroundSprite.width = 1.3
        _backgroundSprite.height = 2
        _backgroundSprite.initialPosition.y = 0
        _backgroundSprite.initialPosition.x = 0
        _backgroundSprite.velocity.x = 0.0;
        _backgroundSprite.velocity.y = 0.0;
    }
}

