//
//  ViewController.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class GameViewController: GLKViewController {
    private var _model = Model()
    private var _sprites = [Sprite]()
    private var _backgroundSprite = Sprite()
    private var _dpadSprite = Sprite()
    private var _fireSprite = Sprite()
    private var _playerShip = Sprite()
    private var _healthBarSprite = Sprite()
    private var _gameoverSprite = Sprite()
    private var _oneNumberSprite = Sprite()
    private var _twoNumberSprite = Sprite()
    private var _threeNumberSprite = Sprite()
    private var _fourNumberSprite = Sprite()
    private var _tapForMenuSprite = Sprite()
    private var _scoresSprite = Sprite()
    private var _highScoreBackgroundSprite = Sprite()
    private var _highScoreBackSprite = Sprite()
    
    private var _dpad: GLKTextureInfo? = nil
    private var _dpadUp: GLKTextureInfo? = nil
    private var _dpadRight: GLKTextureInfo? = nil
    private var _dpadDown: GLKTextureInfo? = nil
    private var _dpadLeft: GLKTextureInfo? = nil
    private var _buttonUnpressed: GLKTextureInfo? = nil
    private var _button: GLKTextureInfo? = nil
    private var _ship: GLKTextureInfo? = nil
    private var _asteroid: GLKTextureInfo? = nil
    private var _background: GLKTextureInfo? = nil
    private var _explosion: GLKTextureInfo? = nil
    private var _healthBar: GLKTextureInfo? = nil
    private var _gameover: GLKTextureInfo? = nil
    private var _numbers: GLKTextureInfo? = nil
    private var _enemyShip: GLKTextureInfo? = nil
    private var _mars: GLKTextureInfo? = nil
    private var _biomech: GLKTextureInfo? = nil
    private var _scores: GLKTextureInfo? = nil
    private var _highScoreBackground: GLKTextureInfo? = nil
    private var _highScoreBack: GLKTextureInfo? = nil
    
    private var _logoSprite = Sprite()
    private var _backgroundMainSprite = Sprite()
    private var _startSprite = Sprite()
    private var _highScoreSprite = Sprite()
    
    private var _logo: GLKTextureInfo? = nil
    private var _backgroundMain: GLKTextureInfo? = nil
    private var _startGame: GLKTextureInfo? = nil
    private var _highScore: GLKTextureInfo? = nil

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
    }

    private func setup() {
        glClearColor(0.0, 0.0, 0.0, 1.0)

        loadSprites()
        constructLogoSprite()
        constructBackgroundMainSprite()
        constructStartGameSprite()
        constructHighScoreSprite()

    }
    
    private func setupGame() {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        constructBackgroundSprite()
        constructPlayerShipSprite()
        constructDirectionalPad()
        constructFireButton()
        constructHealthBar()
        constructScoreBar()
    }
    
    private func setupScoresScreen() {
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        constructHighScoreScreen()
    }
    
    // Game loop
    func update() {
        /* GAME SCREEN */
        if _model.playingGame || _model.gameOverMenu {
            // Update sprite's locations
            updateSpritesLocations()
            
            // Collision detection
            detectCollisions()
            
            if _model.level == 1 {
                spawnRandomAsteroids()
                if _model.asteroidsDestroyed >= 5 {
                    _model.level = 2
                }
            }
            else if _model.level == 2 {
                 _backgroundSprite.animation.texture = _mars!.name
                spawnEnemyShips()
                enemyFire()
                
                if _model.shipsDestroyed >= 5 {
                    _model.level = 3
                }
            }
            else if _model.level == 3 {
                if _model.shipsDestroyed + _model.asteroidsDestroyed > 5 {
                    _model.shipsDestroyed = 0
                    _model.asteroidsDestroyed = 0
                    _model.enemyBulletVelocity -= 0.2
                    _model.asteroidMinVelocity += 0.1
                    _model.asteroidMaxVelocity += 0.1
                    print("upgraded")
                }
                
                _backgroundSprite.animation.texture = _biomech!.name
                spawnRandomAsteroids()
                spawnEnemyShips()
                enemyFire()
            }
            
            // Keep ship in bounds of the screen
            shipInBounds()
            
            if _model.playerFiring {
                playerFire()
            }
            else {
                _model.currentFiringFrequency = _model.firingFrequency
            }
            
            if _playerShip.playerShipExplosionPhase == 20 {
                _playerShip.position.x = -3
                _playerShip.position.y = -3
            }
            
            updateScore()
        }
        
        /* GAME OVER SCREEN */
        if _model.gameOverMenu {
            _model.gameOverDelay++;
        }
        
        /* HIGH SCORES SCREEN */
        if _model.highScoresScreen {
            setupScoresScreen()
        }
    }
    
    // Draw loop
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        // Makes the sprite square
        let height: GLsizei = GLsizei(view.bounds.height * view.contentScaleFactor)
        let offset: GLint = GLint((view.bounds.height - view.bounds.width) * -0.5 * view.contentScaleFactor)
        glViewport(offset, 0, height, height)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        /* GAME SCREEN */
        if _model.playingGame {
            _backgroundSprite.drawBackground()
            
            for (index, sprite) in _sprites.enumerate().reverse() {
                if sprite.remove && !sprite.isPlayer {
                    _sprites.removeAtIndex(index)
                }
                else if sprite.position.x > 2 || sprite.position.x < -2 || sprite.position.y > 2 || sprite.position.y < -2 {
                    _sprites.removeAtIndex(index)
                }
            }
            
            for sprite in _sprites {
                sprite.draw()
            }
            
            _dpadSprite.drawControls()
            _fireSprite.drawControls()
            _healthBarSprite.drawControls()
            _oneNumberSprite.drawControls()
            _twoNumberSprite.drawControls()
            _threeNumberSprite.drawControls()
            _fourNumberSprite.drawControls()
        }
        
        /* MAIN SCREEN */
        if _model.displayGameScreen {
            _backgroundMainSprite.drawMainBackground()
            _logoSprite.drawControls()
            _highScoreSprite.drawControls()
            _startSprite.drawControls()
        }
        
        /* GAME OVER SCREEN */
        if _model.gameOverMenu {
            _backgroundSprite.drawBackground()
            
            for (index, sprite) in _sprites.enumerate().reverse() {
                if sprite.remove && !sprite.isPlayer {
                    _sprites.removeAtIndex(index)
                }
                else if sprite.position.x > 2 || sprite.position.x < -2 || sprite.position.y > 2 || sprite.position.y < -2 {
                    _sprites.removeAtIndex(index)
                }
            }
            
            for sprite in _sprites {
                sprite.draw()
            }
            
            _healthBarSprite.drawControls()
            _oneNumberSprite.drawControls()
            _twoNumberSprite.drawControls()
            _threeNumberSprite.drawControls()
            _fourNumberSprite.drawControls()
            _gameoverSprite.drawControls()
        }
        
        /* HIGH SCORES SCREEN */
        if _model.highScoresScreen {
            _highScoreBackgroundSprite.drawControls()
            _scoresSprite.drawControls()
            _highScoreBackSprite.drawControls()
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
                        collision(sprite, spriteTwo: spriteTwo)
                    }

                }
            }
        }
    }
    
    func collision(sprite: Sprite, spriteTwo: Sprite) {
        // player bullet and enemy collision
        if sprite.isPlayerBullet && (spriteTwo.isEnemy || spriteTwo.isSpaceship) || (sprite.isEnemy || sprite.isSpaceship) && sprite.isPlayerBullet {
            _model.playerScore++
            if sprite.isEnemy || sprite.isEnemyBullet || sprite.isSpaceship {
                spriteTwo.remove = true
                asteroidHit(sprite)
            }
            else if spriteTwo.isEnemy || spriteTwo.isEnemyBullet || spriteTwo.isSpaceship {
                sprite.remove = true
                asteroidHit(spriteTwo)
            }
        }
        
        // player and enemy collision
        if sprite.isPlayer && (spriteTwo.isEnemy || spriteTwo.isSpaceship || spriteTwo.isEnemyBullet) || spriteTwo.isPlayer && (sprite.isPlayerBullet || sprite.isSpaceship || sprite.isEnemy) {
            if sprite.isEnemy || sprite.isEnemyBullet || sprite.isSpaceship {
                enemyCollision(sprite)
                playerHit(spriteTwo)
            }
            else if spriteTwo.isEnemy || spriteTwo.isEnemyBullet || spriteTwo.isSpaceship {
                enemyCollision(spriteTwo)
                playerHit(sprite)
            }
        }
    }
    
    func playerHit(sprite: Sprite) {
        _model.playerHealth--;
        
        if _model.playerHealth == 0 {
            _healthBarSprite.remove = true
            gameOver()
        }
        
        // Adjust health bar
        _healthBarSprite.animation.frameWidth = _healthBarSprite.animation.frameWidth - 105
        _healthBarSprite.width = _healthBarSprite.width - 0.1
        _healthBarSprite.position.x = _healthBarSprite.position.x - 0.05
        
    }
    
    func shipInBounds() {
        if _playerShip.position.y >= 0.9 {
            _playerShip.velocity.y = 0
            _playerShip.position.y = 0.9
        }
            
        else if _playerShip.position.y <= -0.75 {
            _playerShip.velocity.y = 0
            _playerShip.position.y = -0.75
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
    
    func gameOver() {
        _model.gameOverMenu = true
        _model.playingGame = false
        _playerShip.remove = true
        _backgroundSprite.animation.texture = _background!.name
        _gameoverSprite.animation.texture = _gameover!.name
        _gameoverSprite.animation.textureX = 471
        _gameoverSprite.animation.textureY = 107
        _gameoverSprite.animation.frameWidth = 471
        _gameoverSprite.animation.frameHeight = 107
        _gameoverSprite.animation.rows = 1
        _gameoverSprite.animation.columns = 1
        _gameoverSprite.animation.frameX = 0
        _gameoverSprite.animation.frameY = 0
        _gameoverSprite.width = 1
        _gameoverSprite.height = 0.5
        _gameoverSprite.position.x = 0
        _gameoverSprite.position.y = 0
        
        _gameoverSprite.drawControls()
    }
    
    func asteroidHit(sprite: Sprite) {
        if sprite.height < 0.3 {
            let deathSprite: Sprite = Sprite()
            deathSprite.animation.texture = _explosion!.name
            deathSprite.animation.textureX = 320
            deathSprite.animation.textureY = 320
            deathSprite.animation.frameHeight = 55
            deathSprite.animation.frameWidth = 52
            deathSprite.animation.rows = 0
            deathSprite.animation.columns = 5
            deathSprite.animation.frameX = 10
            deathSprite.animation.frameY = 7
            deathSprite.animation.framesPerAnimation = 1
            deathSprite.width = sprite.width * 0.75
            deathSprite.height = sprite.height * 0.75
            deathSprite.initialPosition.y = sprite.position.y
            deathSprite.initialPosition.x = sprite.position.x
            deathSprite.position.y = deathSprite.initialPosition.y
            deathSprite.position.x = deathSprite.initialPosition.x
            deathSprite.velocity.x = 0.0
            deathSprite.velocity.y = 0.0
            if sprite.isEnemy {
                _model.asteroidsDestroyed++
            }
            if sprite.isSpaceship {
                _model.shipsDestroyed++
            }
            sprite.remove = true
            _sprites.append(deathSprite)
        }
        else {
            sprite.height = sprite.height - 0.1
            sprite.width = sprite.width - 0.1
        }
    }
    
    func enemyCollision(sprite: Sprite) {
        let deathSprite: Sprite = Sprite()
        deathSprite.animation.texture = _explosion!.name
        deathSprite.animation.textureX = 320
        deathSprite.animation.textureY = 320
        deathSprite.animation.frameHeight = 55
        deathSprite.animation.frameWidth = 52
        deathSprite.animation.rows = 0
        deathSprite.animation.columns = 5
        deathSprite.animation.frameX = 10
        deathSprite.animation.frameY = 7
        deathSprite.animation.framesPerAnimation = 1
        deathSprite.width = sprite.width * 0.75
        deathSprite.height = sprite.height * 0.75
        deathSprite.initialPosition.y = sprite.position.y
        deathSprite.initialPosition.x = sprite.position.x
        deathSprite.position.y = deathSprite.initialPosition.y
        deathSprite.position.x = deathSprite.initialPosition.x
        deathSprite.velocity.x = 0.0
        deathSprite.velocity.y = 0.0
        sprite.isEnemy = false
        sprite.isSpaceship = false
        sprite.isEnemyBullet = false
        sprite.remove = true
        _sprites.append(deathSprite)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self.view)
        if _model.playingGame && touchPoint.x > 27 && touchPoint.x < 74 && touchPoint.y > 488 && touchPoint.y < 536 {
            _model.playerFiring = true
        }
        else if _model.playingGame && touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 469 && touchPoint.y < 497 {
            shipUp()
        }
        else if _model.playingGame && touchPoint.x > 283 && touchPoint.x < 307 && touchPoint.y > 501 && touchPoint.y < 525 {
            shipRight()
        }
        else if _model.playingGame && touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 529 && touchPoint.y < 556 {
            shipDown()
        }
        else if _model.playingGame && touchPoint.x > 223 && touchPoint.x < 250 && touchPoint.y > 500 && touchPoint.y < 525 {
            shipLeft()
        }
        else if _model.playingGame {
            shipStop()
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self.view)
        
        if _model.playingGame && touchPoint.x > 27 && touchPoint.x < 74 && touchPoint.y > 488 && touchPoint.y < 536 {
            _model.playerFiring = true
        }
        else if _model.playingGame && touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 469 && touchPoint.y < 497 {
            shipUp()
        }
        else if _model.playingGame && touchPoint.x > 283 && touchPoint.x < 307 && touchPoint.y > 501 && touchPoint.y < 525 {
            shipRight()
        }
        else if _model.playingGame && touchPoint.x > 253 && touchPoint.x < 279 && touchPoint.y > 529 && touchPoint.y < 556 {
            shipDown()
        }
        else if _model.playingGame && touchPoint.x > 223 && touchPoint.x < 250 && touchPoint.y > 500 && touchPoint.y < 525 {
            shipLeft()
        }
        else if _model.playingGame {
            _dpadSprite.animation.texture = _dpad!.name
            _fireSprite.animation.texture = _buttonUnpressed!.name
            shipStop()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self.view)
        
        if _model.playingGame {
            _dpadSprite.animation.texture = _dpad!.name
            _fireSprite.animation.texture = _buttonUnpressed!.name
            _model.playerFiring = false
            shipStop()
        }
        
        /* SWITCH TO GAME MODE */
        if _model.displayGameScreen && touchPoint.x > 77 && touchPoint.x < 239 && touchPoint.y > 344 && touchPoint.y < 387 {
            _model.playingGame = true
            _model.displayGameScreen = false
            setupGame()
        }
        
        /* SWITCH TO GAME MENU */
        if _model.gameOverMenu && _model.gameOverDelay > 10 {
            _model.displayGameScreen = true
            _model.gameOverMenu = false
            restartGame()
        }
        
        /* SWITCH TO GAME MENU */
        if _model.highScoresScreen && touchPoint.x > 68 && touchPoint.x < 242 && touchPoint.y > 462 && touchPoint.y < 502 {
            _model.highScoresScreen = false
            _model.displayGameScreen = false
            _model.displayGameScreen = true
            restartGame()
        }
        
        /* SWITCH TO HIGH SCORES */
        if _model.displayGameScreen && touchPoint.x > 77 && touchPoint.x < 239 && touchPoint.y > 404 && touchPoint.y < 441 {
            _model.highScoresScreen = true
            _model.displayGameScreen = false
            setupScoresScreen()
        }
        
    }
    
    func shipStop() {
        _dpadSprite.animation.texture = _dpad!.name
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 0
        _playerShip.animation.frameHeight = 36
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.0;
        _playerShip.velocity.y = 0.0;
    }
    
    func shipUp() {
        _dpadSprite.animation.texture = _dpadUp!.name
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 39
        _playerShip.animation.frameHeight = 45
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.0
        _playerShip.velocity.y = 0.05
    }
    
    func shipRight() {
        _dpadSprite.animation.texture = _dpadRight!.name
        _playerShip.animation.frameX = 86
        _playerShip.animation.frameY = 86
        _playerShip.animation.frameHeight = 45
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.05
        _playerShip.velocity.y = 0.0
    }
    
    func shipDown() {
        _dpadSprite.animation.texture = _dpadDown!.name
        _playerShip.animation.frameX = 39
        _playerShip.animation.frameY = 0
        _playerShip.animation.frameHeight = 36
        _playerShip.animation.frameWidth = 39
        _playerShip.velocity.x = 0.0
        _playerShip.velocity.y = -0.05
    }
    
    func shipLeft() {
        _dpadSprite.animation.texture = _dpadLeft!.name
        _playerShip.animation.frameX = 2
        _playerShip.animation.frameY = 86
        _playerShip.animation.frameHeight = 45
        _playerShip.animation.frameWidth = 35
        _playerShip.velocity.x = -0.05
        _playerShip.velocity.y = 0.0
    }
    
    func playerFire() {
        _fireSprite.animation.texture = _button!.name
        
        if _model.currentFiringFrequency == _model.firingFrequency {
            _model.currentFiringFrequency = 0
            let sprite: Sprite = Sprite()
            sprite.animation.texture = _ship!.name
            sprite.animation.textureX = 116
            sprite.animation.textureY = 345
            sprite.animation.frameHeight = 14
            sprite.animation.frameWidth = 4
            sprite.animation.rows = 0
            sprite.animation.columns = 0
            sprite.animation.frameX = 56
            sprite.animation.frameY = 131
            sprite.animation.framesPerAnimation = 1
            sprite.width = 0.02
            sprite.height = 0.06
            sprite.initialPosition.y = _playerShip.position.y + 0.1
            sprite.initialPosition.x = _playerShip.position.x
            sprite.position.y = sprite.initialPosition.y
            sprite.position.x = sprite.initialPosition.x
            sprite.velocity.x = 0.0
            sprite.velocity.y = 1.0
            sprite.isPlayerBullet = true
            
            _sprites.append(sprite)
        }
        else {
            _model.currentFiringFrequency++
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
            sprite.velocity.x = 0.0
            sprite.velocity.y = -1 * ((drand48() * (0.5 - 0.15)) + 0.15)
            sprite.isEnemy = true
            
            _sprites.append(sprite)
        }
        else {
            _model.currentAsteroidFrequency++;
        }
    }
    
    func spawnEnemyShips() {
        if _model.currentEnemyFrequency == _model.enemyFrequency {
            _model.currentEnemyFrequency = 0
            let sprite: Sprite = Sprite()
            sprite.animation.texture = _enemyShip!.name
            sprite.animation.textureX = 348
            sprite.animation.textureY = 250
            sprite.animation.frameHeight = 30
            sprite.animation.frameWidth = 53
            sprite.animation.rows = 2
            sprite.animation.columns = 6
            sprite.animation.frameX = 5
            sprite.animation.frameY = 5
            sprite.animation.framesPerAnimation = 1
            sprite.width = 0.15
            sprite.height = 0.15
            sprite.initialPosition.y = 1.1
            sprite.initialPosition.x = (drand48() * 2) - 1
            sprite.position.y = sprite.initialPosition.y
            sprite.position.x = sprite.initialPosition.x
            sprite.velocity.x = 0.0
            sprite.velocity.y = -1 * ((drand48() * (_model.asteroidMaxVelocity - _model.asteroidMinVelocity)) + _model.asteroidMinVelocity)
            sprite.isSpaceship = true
            
            _sprites.append(sprite)
        }
        else if _model.currentEnemyFrequency == _model.enemyFrequency/2 {
            let sprite: Sprite = Sprite()
            _model.currentEnemyFrequency++;
            sprite.animation.texture = _enemyShip!.name
            sprite.animation.textureX = 348
            sprite.animation.textureY = 250
            sprite.animation.frameHeight = 30
            sprite.animation.frameWidth = 53
            sprite.animation.rows = 2
            sprite.animation.columns = 6
            sprite.animation.frameX = 5
            sprite.animation.frameY = 5
            sprite.animation.framesPerAnimation = 1
            sprite.width = 0.15
            sprite.height = 0.15
            sprite.initialPosition.y = 0.8
            sprite.initialPosition.x = -0.7
            sprite.position.y = sprite.initialPosition.y
            sprite.position.x = sprite.initialPosition.x
            sprite.velocity.x = 0.5
            sprite.velocity.y = 0
            sprite.isSpaceship = true
            
            _sprites.append(sprite)
        }
        else {
            _model.currentEnemyFrequency++
        }

    }
    
    func enemyFire() {
    
        if _model.currentEnemyFiringFrequency == _model.firingEnemyFrequency {
            _model.currentEnemyFiringFrequency = 0
            for sprite in _sprites {
                if sprite.isSpaceship {
                    let bullet: Sprite = Sprite()
                    bullet.animation.texture = _enemyShip!.name
                    bullet.animation.textureX = 348
                    bullet.animation.textureY = 250
                    bullet.animation.frameHeight = 39
                    bullet.animation.frameWidth = 28
                    bullet.animation.rows = 0
                    bullet.animation.columns = 0
                    bullet.animation.frameX = 9
                    bullet.animation.frameY = 123
                    bullet.animation.framesPerAnimation = 1
                    bullet.width = 0.02
                    bullet.height = 0.06
                    bullet.initialPosition.y = sprite.position.y - 0.1
                    bullet.initialPosition.x = sprite.position.x
                    bullet.position.y = sprite.initialPosition.y
                    bullet.position.x = sprite.initialPosition.x
                    bullet.velocity.x = 0.0
                    bullet.velocity.y = _model.enemyBulletVelocity
                    bullet.isEnemyBullet = true
                    _sprites.append(bullet)
                }
            }
        }
        else {
            _model.currentEnemyFiringFrequency++
        }
    }
    
    func restartGame() {
        _sprites = [Sprite]()
        _model.gameOverMenu = false
        _model.gameOverDelay = 0
        _model.level = 1
        _model.playerHealth = 5
        _model.playerScore = 0
        _model.asteroidFrequency = 20
        _model.level = 1
        _model.asteroidsDestroyed = 0
        _model.shipsDestroyed = 0
        updateScore()
        _playerShip = Sprite()
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
    
    func updateScore() {
        let playerScoreString: String = String(_model.playerScore)
        var oneDigit: Int = 0
        var twoDigit: Int = 0
        var threeDigit: Int = 0
        var fourDigit: Int = 0
        if playerScoreString.characters.count == 1 {
            oneDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(0)]))!
            _oneNumberSprite.position.x = 0.47
            _twoNumberSprite.position.x = -3.0
            _threeNumberSprite.position.x = -3.0
            _fourNumberSprite.position.x = -3.0
        }
        if playerScoreString.characters.count >= 2 {
            _oneNumberSprite.position.x = 0.47
            _twoNumberSprite.position.x = 0.36
            _threeNumberSprite.position.x = -3.0
            _fourNumberSprite.position.x = -3.0
            oneDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(1)]))!
            twoDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(0)]))!
        }
        if playerScoreString.characters.count >= 3 {
            _oneNumberSprite.position.x = 0.47
            _twoNumberSprite.position.x = 0.36
            _threeNumberSprite.position.x = 0.24
            _fourNumberSprite.position.x = -3.0
            oneDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(2)]))!
            twoDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(1)]))!
            threeDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(0)]))!
        }
        if playerScoreString.characters.count >= 4 {
            _oneNumberSprite.position.x = 0.47
            _twoNumberSprite.position.x = 0.36
            _threeNumberSprite.position.x = 0.24
            _fourNumberSprite.position.x = 0.12
            oneDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(3)]))!
            twoDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(2)]))!
            threeDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(1)]))!
            fourDigit = Int(String(playerScoreString[playerScoreString.startIndex.advancedBy(0)]))!
        }
        
        _oneNumberSprite.animation.frameX = Double((36 * oneDigit) + 2)
        _twoNumberSprite.animation.frameX = Double((36 * twoDigit) + 2)
        _threeNumberSprite.animation.frameX = Double((36 * threeDigit) + 2)
        _fourNumberSprite.animation.frameX = Double((36 * fourDigit) + 2)
    }
    
    func loadSprites() {
        _buttonUnpressed = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "button_unpressed")!.CGImage!, options: nil)
        _button = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "button_pressed")!.CGImage!, options: nil)
        _asteroid = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "asteroid")!.CGImage!, options: nil)
        _explosion = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "explosion")!.CGImage!, options: nil)
        _gameover = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "gameover")!.CGImage!, options: nil)
        _healthBar = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "healthbar")!.CGImage!, options: nil)
        _numbers = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "numbers")!.CGImage!, options: nil)
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
        _ship = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "ship")!.CGImage!, options: nil)
        _background = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "background.jpg")!.CGImage!, options: nil)
        _highScore = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "high_scores")!.CGImage!, options: nil)
        _logo = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "darius")!.CGImage!, options: nil)
        _backgroundMain = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "mainscreen_background.jpg")!.CGImage!, options: nil)
        _startGame = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "play_game")!.CGImage!, options: nil)
        _highScore = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "high_scores")!.CGImage!, options: nil)
        _enemyShip = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "enemy_ship")!.CGImage!, options: nil)
        _mars = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "mars.jpg")!.CGImage!, options: nil)
        _biomech = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "biomech.jpg")!.CGImage!, options: nil)
        _scores = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "scores")!.CGImage!, options: nil)
        _highScoreBackground = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "highscore_background.jpg")!.CGImage!, options: nil)
        _highScoreBack = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "back")!.CGImage!, options: nil)
    }
    
    
    func constructLogoSprite() {
        _logoSprite.animation.texture = _logo!.name
        _logoSprite.animation.textureX = 256
        _logoSprite.animation.textureY = 74
        _logoSprite.animation.frameHeight = 74
        _logoSprite.animation.frameWidth = 256
        _logoSprite.animation.rows = 1
        _logoSprite.animation.columns = 1
        _logoSprite.animation.frameX = 0
        _logoSprite.animation.frameY = 0
        _logoSprite.width = 1
        _logoSprite.height = 0.8
        _logoSprite.position.x = 0
        _logoSprite.position.y = 0.3
        _logoSprite.drawControls()
    }
    
    func constructBackgroundMainSprite() {
        _backgroundMainSprite.animation.texture = _backgroundMain!.name
        _backgroundMainSprite.animation.textureX = 1280
        _backgroundMainSprite.animation.textureY = 1280
        _backgroundMainSprite.animation.frameHeight = 1000
        _backgroundMainSprite.animation.frameWidth = 1000
        _backgroundMainSprite.animation.frameX = 640
        _backgroundMainSprite.animation.frameY = 640
        _backgroundMainSprite.width = 1.3
        _backgroundMainSprite.height = 2
        _backgroundMainSprite.drawControls()
    }
    
    func constructStartGameSprite() {
        _startSprite.animation.texture = _startGame!.name
        _startSprite.animation.textureX = 256
        _startSprite.animation.textureY = 74
        _startSprite.animation.frameHeight = 74
        _startSprite.animation.frameWidth = 256
        _startSprite.animation.rows = 1
        _startSprite.animation.columns = 1
        _startSprite.animation.frameX = 0
        _startSprite.animation.frameY = 0
        _startSprite.width = 0.7
        _startSprite.height = 0.3
        _startSprite.position.x = 0
        _startSprite.position.y = -0.3
        _startSprite.drawControls()
    }
    
    func constructHighScoreSprite() {
        _highScoreSprite.animation.texture = _highScore!.name
        _highScoreSprite.animation.textureX = 256
        _highScoreSprite.animation.textureY = 74
        _highScoreSprite.animation.frameHeight = 74
        _highScoreSprite.animation.frameWidth = 256
        _highScoreSprite.animation.rows = 1
        _highScoreSprite.animation.columns = 1
        _highScoreSprite.animation.frameX = 0
        _highScoreSprite.animation.frameY = 0
        _highScoreSprite.width = 0.7
        _highScoreSprite.height = 0.3
        _highScoreSprite.position.x = 0
        _highScoreSprite.position.y = -0.5
        _highScoreSprite.drawControls()
    }
    
    func constructHighScoreScreen() {
        _scoresSprite.animation.texture = _scores!.name
        _scoresSprite.animation.textureX = 551
        _scoresSprite.animation.textureY = 79
        _scoresSprite.animation.frameHeight = 79
        _scoresSprite.animation.frameWidth = 551
        _scoresSprite.animation.rows = 1
        _scoresSprite.animation.columns = 1
        _scoresSprite.animation.frameX = 0
        _scoresSprite.animation.frameY = 0
        _scoresSprite.width = 1
        _scoresSprite.height = 0.5
        _scoresSprite.position.x = 0
        _scoresSprite.position.y = 0.7
        _scoresSprite.drawControls()
        
        _highScoreBackgroundSprite.animation.texture = _highScoreBackground!.name
        _highScoreBackgroundSprite.animation.textureX = 2560
        _highScoreBackgroundSprite.animation.textureY = 1580
        _highScoreBackgroundSprite.animation.frameHeight = 1580
        _highScoreBackgroundSprite.animation.frameWidth = 2560
        _highScoreBackgroundSprite.animation.rows = 1
        _highScoreBackgroundSprite.animation.columns = 1
        _highScoreBackgroundSprite.animation.frameX = 0
        _highScoreBackgroundSprite.animation.frameY = 0
        _highScoreBackgroundSprite.width = 4
        _highScoreBackgroundSprite.height = 4
        _highScoreBackgroundSprite.position.x = 0
        _highScoreBackgroundSprite.position.y = 0
        _highScoreBackgroundSprite.drawControls()
        
        _highScoreBackSprite.animation.texture = _highScoreBack!.name
        _highScoreBackSprite.animation.textureX = 263
        _highScoreBackSprite.animation.textureY = 79
        _highScoreBackSprite.animation.frameHeight = 79
        _highScoreBackSprite.animation.frameWidth = 263
        _highScoreBackSprite.animation.rows = 1
        _highScoreBackSprite.animation.columns = 1
        _highScoreBackSprite.animation.frameX = 0
        _highScoreBackSprite.animation.frameY = 0
        _highScoreBackSprite.width = 1
        _highScoreBackSprite.height = 0.2
        _highScoreBackSprite.position.x = 0
        _highScoreBackSprite.position.y = -0.7
        _highScoreBackSprite.drawControls()
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
        _playerShip.initialPosition.y = -0.75
        _playerShip.initialPosition.x = -0.05
        _playerShip.position.y = _playerShip.initialPosition.y
        _playerShip.position.x = _playerShip.initialPosition.x
        _playerShip.velocity.x = 0.0
        _playerShip.velocity.y = 0.0
        _playerShip.isPlayer = true
        
        _sprites.append(_playerShip)
    }
    
    func constructDirectionalPad() {
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
        _fireSprite.animation.texture = _buttonUnpressed!.name
        _fireSprite.animation.textureX = 128
        _fireSprite.animation.textureY = 128
        _fireSprite.animation.frameHeight = 280
        _fireSprite.animation.frameWidth = 280
        _fireSprite.animation.rows = 1
        _fireSprite.animation.columns = 1
        _fireSprite.animation.frameX = 0
        _fireSprite.animation.frameY = 0
        _fireSprite.width = 0.4
        _fireSprite.height = 0.4
        _fireSprite.position.x = -0.28
        _fireSprite.position.y = -0.9
        
        _fireSprite.drawControls()
        
    }
    
    func constructHealthBar() {
        
        _healthBarSprite.animation.texture = _healthBar!.name
        _healthBarSprite.animation.textureX = 516
        _healthBarSprite.animation.textureY = 46
        _healthBarSprite.animation.frameHeight = 46
        _healthBarSprite.animation.frameWidth = 516
        _healthBarSprite.animation.rows = 1
        _healthBarSprite.animation.columns = 1
        _healthBarSprite.animation.frameX = 0
        _healthBarSprite.animation.frameY = 0
        _healthBarSprite.width = 0.5
        _healthBarSprite.height = 0.07
        _healthBarSprite.position.x = -0.05
        _healthBarSprite.position.y = -0.9
        
        _healthBarSprite.drawControls()
    }
    
    func constructScoreBar() {
        _oneNumberSprite.animation.texture = _numbers!.name
        _twoNumberSprite.animation.texture = _numbers!.name
        _threeNumberSprite.animation.texture = _numbers!.name
        _fourNumberSprite.animation.texture = _numbers!.name
        
        _oneNumberSprite.animation.textureX = 360
        _oneNumberSprite.animation.textureY = 36
        _oneNumberSprite.animation.frameX = 2
        _oneNumberSprite.animation.frameY = 6
        _oneNumberSprite.width = 0.1
        _oneNumberSprite.height = 0.1
        _oneNumberSprite.animation.frameWidth = 34
        _oneNumberSprite.animation.frameHeight = 27
        _oneNumberSprite.position.x = -3.0
        _oneNumberSprite.position.y = 0.87
        
        _twoNumberSprite.animation.textureX = 360
        _twoNumberSprite.animation.textureY = 36
        _twoNumberSprite.animation.frameX = 2
        _twoNumberSprite.animation.frameY = 6
        _twoNumberSprite.width = 0.1
        _twoNumberSprite.height = 0.1
        _twoNumberSprite.animation.frameWidth = 34
        _twoNumberSprite.animation.frameHeight = 27
        _twoNumberSprite.position.x = -3.0
        _twoNumberSprite.position.y = 0.87
        
        _threeNumberSprite.animation.textureX = 360
        _threeNumberSprite.animation.textureY = 36
        _threeNumberSprite.animation.frameX = 2
        _threeNumberSprite.animation.frameY = 6
        _threeNumberSprite.width = 0.1
        _threeNumberSprite.height = 0.1
        _threeNumberSprite.animation.frameWidth = 34
        _threeNumberSprite.animation.frameHeight = 27
        _threeNumberSprite.position.x = -3.0
        _threeNumberSprite.position.y = 0.87
        
        _fourNumberSprite.animation.textureX = 360
        _fourNumberSprite.animation.textureY = 36
        _fourNumberSprite.animation.frameX = 2
        _fourNumberSprite.animation.frameY = 6
        _fourNumberSprite.animation.frameWidth = 34
        _fourNumberSprite.animation.frameHeight = 27
        _fourNumberSprite.width = 0.1
        _fourNumberSprite.height = 0.1
        _fourNumberSprite.position.x = -3.0
        _fourNumberSprite.position.y = 0.87
    }
}

