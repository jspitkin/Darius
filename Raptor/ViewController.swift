//
//  ViewController.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    private var _model = Model()
    private var _sprites = [Sprite]()
    private var _backgroundSprite = Sprite()
    
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

    }
    
    // runs right before drawInRect is called. You can think of this as your game loop.
    func update() {
        
        // Update sprite's locations
        updateSpritesLocations()
       
        // Collision detection
        detectCollisions()
        
        if _model.level == 1 {
            spawnRandomAsteroids()
        }
    }
    
    func updateSpritesLocations() {
        for sprite in _sprites {
            let now = NSDate()
            let elapsed = now.timeIntervalSinceDate(sprite.animation.lastUpdate)
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
        
        for (index, sprite) in _sprites.enumerate().reverse() {
            if sprite.position.x > 2 || sprite.position.x < -2 || sprite.position.y > 2 || sprite.position.y < -2 {
              _sprites.removeAtIndex(index)
            }
        }
        
        for sprite in _sprites {
            sprite.draw()
        }
    }
    
    func spawnRandomAsteroids() {
        if _model.currentAsteroidFrequency == _model.asteroidFrequency {
            _model.currentAsteroidFrequency = 0
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
            sprite.animation.framesPerAnimation = 1
            sprite.width = 0.25
            sprite.height = 0.25
            sprite.initialPosition.y = 1.1
            sprite.initialPosition.x = (drand48() * 2) - 1
            print(sprite.initialPosition.x)
            sprite.position.y = sprite.initialPosition.y
            sprite.position.x = sprite.initialPosition.x
            sprite.velocity.x = 0.0;
            sprite.velocity.y = -0.4;
            sprite.isEnemy = true
            
            _sprites.append(sprite)
        }
        else {
            _model.currentAsteroidFrequency++;
        }
    }
    
    func constructBackgroundSprite() {
        _backgroundSprite.animation.texture = _background!.name
        _backgroundSprite.animation.textureX = 1080
        _backgroundSprite.animation.textureY = 1920
        _backgroundSprite.animation.frameHeight = 500
        _backgroundSprite.animation.frameWidth = 500
        _backgroundSprite.animation.frameX = 0
        _backgroundSprite.animation.frameY = 0
        _backgroundSprite.width = 1.3
        _backgroundSprite.height = 2
    }
}

