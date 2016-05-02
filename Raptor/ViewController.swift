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
    private var _dpadSprite = Sprite()
    private var _playerShip = Sprite()
    
    private var _dpad: GLKTextureInfo? = nil
    private var _dpadUp: GLKTextureInfo? = nil
    private var _dpadRight: GLKTextureInfo? = nil
    private var _dpadDown: GLKTextureInfo? = nil
    private var _dpadLeft: GLKTextureInfo? = nil
    
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
        constructPlayerShipSprite()
        constructDirectionalPad()
        constructFireButton()

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
        
        // Keep ship in bounds of the screen
        shipInBounds()
    }
    
    func updateSpritesLocations() {
        for sprite in _sprites {
            if sprite !== _playerShip {
                let now = NSDate()
                let elapsed = now.timeIntervalSinceDate(sprite.animation.lastUpdate)
                sprite.position.x = sprite.initialPosition.x + Double(elapsed * sprite.velocity.x)
                sprite.position.y = sprite.initialPosition.y + Double(elapsed * sprite.velocity.y)
            }
            else {
                sprite.position.x = sprite.position.x + sprite.velocity.x
                sprite.position.y = sprite.position.y + sprite.velocity.y
            }
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
            //print("Player has collided with an enemy!")
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
        
        _dpadSprite.drawControls()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self.view)
        
        if touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 469 && touchPoint.y < 497 {
            shipUp()
        }
        else if touchPoint.x > 283 && touchPoint.x < 307 && touchPoint.y > 501 && touchPoint.y < 525 {
            shipRight()
        }
        else if touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 529 && touchPoint.y < 556 {
            shipDown()
        }
        else if touchPoint.x > 223 && touchPoint.x < 250 && touchPoint.y > 500 && touchPoint.y < 525 {
            shipLeft()
        }
        else {
            shipStop()
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self.view)
        
        if touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 469 && touchPoint.y < 497 {
            shipUp()
        }
        else if touchPoint.x > 283 && touchPoint.x < 307 && touchPoint.y > 501 && touchPoint.y < 525 {
            shipRight()
        }
        else if touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 529 && touchPoint.y < 556 {
            shipDown()
        }
        else if touchPoint.x > 223 && touchPoint.x < 250 && touchPoint.y > 500 && touchPoint.y < 525 {
            shipLeft()
        }
        else {
            shipStop()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _dpadSprite.animation.texture = _dpad!.name
        shipStop()
    }
    
    func shipStop() {
        print("stop")
        _dpadSprite.animation.texture = _dpad!.name
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 0
        _playerShip.animation.frameHeight = 36
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.0;
        _playerShip.velocity.y = 0.0;
    }
    
    func shipUp() {
        print("up")
        _dpadSprite.animation.texture = _dpadUp!.name
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 39
        _playerShip.animation.frameHeight = 45
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.0;
        _playerShip.velocity.y = 0.05;
    }
    
    func shipRight() {
        print("right")
        _dpadSprite.animation.texture = _dpadRight!.name
        _playerShip.animation.frameX = 86
        _playerShip.animation.frameY = 86
        _playerShip.animation.frameHeight = 45
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.05;
        _playerShip.velocity.y = 0.0;
    }
    
    func shipDown() {
        _dpadSprite.animation.texture = _dpadDown!.name
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 0
        _playerShip.animation.frameHeight = 36
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.0;
        _playerShip.velocity.y = -0.05;
    }
    
    func shipLeft() {
        _dpadSprite.animation.texture = _dpadLeft!.name
        _playerShip.animation.frameX = 2
        _playerShip.animation.frameY = 86
        _playerShip.animation.frameHeight = 45
        _playerShip.animation.frameWidth = 35
        _playerShip.velocity.x = -0.05;
        _playerShip.velocity.y = 0.0;
    }
    
    func spawnRandomAsteroids() {
        if _model.currentAsteroidFrequency == _model.asteroidFrequency {
            _model.currentAsteroidFrequency = 0
            let sprite: Sprite = Sprite()
            sprite.animation.texture = _asteroid!.name
            sprite.animation.textureX = 1024
            sprite.animation.textureY = 1024
            sprite.animation.frameHeight = 100
            sprite.animation.frameWidth = 100
            sprite.animation.rows = 8
            sprite.animation.columns = 8
            sprite.animation.frameX = 15
            sprite.animation.frameY = 10
            sprite.animation.framesPerAnimation = 1
            let asteroidSize = (drand48() * (0.5 - 0.15)) + 0.15
            sprite.width = Float(asteroidSize)
            sprite.height = Float(asteroidSize)
            sprite.initialPosition.y = 1.1
            sprite.initialPosition.x = (drand48() * 2) - 1
            sprite.position.y = sprite.initialPosition.y
            sprite.position.x = sprite.initialPosition.x
            sprite.velocity.x = 0.0;
            sprite.velocity.y = -1 * ((drand48() * (0.5 - 0.15)) + 0.15);
            sprite.isPlayer = true
            
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
    
    func constructPlayerShipSprite() {
        _playerShip.animation.texture = _ship!.name
        _playerShip.animation.textureX = 116
        _playerShip.animation.textureY = 345
        _playerShip.animation.frameHeight = 36
        _playerShip.animation.frameWidth = 39
        _playerShip.animation.rows = 0
        _playerShip.animation.columns = 0
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 0
        _playerShip.animation.framesPerAnimation = 1
        _playerShip.width = 0.15
        _playerShip.height = 0.15
        _playerShip.initialPosition.y = -0.8
        _playerShip.initialPosition.x = 0
        _playerShip.position.y = _playerShip.initialPosition.y
        _playerShip.position.x = _playerShip.initialPosition.x
        _playerShip.velocity.x = 0.0;
        _playerShip.velocity.y = 0.0;
        _playerShip.isEnemy = true
        
        _sprites.append(_playerShip)
    }
    
    func constructDirectionalPad() {
        _dpad = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "dpad")!.CGImage!, options: nil)
        _dpadUp = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "dpad_up")!.CGImage!, options: nil)
        _dpadRight = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "dpad_right")!.CGImage!, options: nil)
        _dpadDown = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "dpad_down")!.CGImage!, options: nil)
        _dpadLeft = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "dpad_left")!.CGImage!, options: nil)
        
        _dpadSprite.animation.texture = _dpad!.name
        _dpadSprite.animation.textureX = 280
        _dpadSprite.animation.textureY = 280
        _dpadSprite.animation.frameHeight = 280
        _dpadSprite.animation.frameWidth = 280
        _dpadSprite.animation.rows = 1
        _dpadSprite.animation.columns = 1
        _dpadSprite.animation.frameX = 0
        _dpadSprite.animation.frameY = 0
        _dpadSprite.width = 0.3
        _dpadSprite.height = 0.3
        _dpadSprite.position.x = 0.37
        _dpadSprite.position.y = -0.8
        
        _dpadSprite.drawControls()
    }
    
    func constructFireButton() {
        
    }
    
    func shipInBounds() {
        print("x: \(_playerShip.position.x) y: \(_playerShip.position.y)")
        
        if _playerShip.position.y >= 0.9 {
            _playerShip.velocity.y = 0
            _playerShip.position.y = 0.9
        }
        
        else if _playerShip.position.y <= -0.9 {
            _playerShip.velocity.y = 0
            _playerShip.position.y = -0.9
        }
        
        else if _playerShip.position.x <= -0.45 {
            _playerShip.velocity.x = 0
            _playerShip.position.x = -0.45
        }
        
        else if _playerShip.position.x >= 0.45 {
            _playerShip.velocity.x = 0
            _playerShip.position.x = 0.45
        }
    }
}

