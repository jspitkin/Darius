//
//  MenuViewController.swift
//  Darius
//
//  Created by Jake Pitkin on 5/2/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class MenuViewController: GLKViewController {
    
    private var _logoSprite = Sprite()
    private var _backgroundSprite = Sprite()
    private var _startSprite = Sprite()
    private var _highScoreSprite = Sprite()
    
    private var _logo: GLKTextureInfo? = nil
    private var _background: GLKTextureInfo? = nil
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
        
        constructLogoSprite()
        constructBackgroundSprite()
        constructStartGameSprite()
        constructHighScoreSprite()
    }
    
    // Game loop
    func update() {
        
    }
    
    // Draw loop
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        // Makes the sprite square
        let height: GLsizei = GLsizei(view.bounds.height * view.contentScaleFactor)
        let offset: GLint = GLint((view.bounds.height - view.bounds.width) * -0.5 * view.contentScaleFactor)
        glViewport(offset, 0, height, height)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        _backgroundSprite.drawMainBackground()
        _logoSprite.drawControls()
        _highScoreSprite.drawControls()
        _startSprite.drawControls()

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(self.view)
        newGame()
    }
    
    func newGame() {
        let gameViewController: GameViewController = GameViewController()
        self.navigationController?.pushViewController(gameViewController, animated: true)
        print("got here 1")
    }
    
    func constructLogoSprite() {
        _logo = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "darius")!.CGImage!, options: nil)

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
    
    func constructBackgroundSprite() {
        _background = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "mainscreen_background.jpg")!.CGImage!, options: nil)
        _backgroundSprite.animation.texture = _background!.name
        _backgroundSprite.animation.textureX = 1280
        _backgroundSprite.animation.textureY = 1280
        _backgroundSprite.animation.frameHeight = 1000
        _backgroundSprite.animation.frameWidth = 1000
        _backgroundSprite.animation.frameX = 640
        _backgroundSprite.animation.frameY = 640
        _backgroundSprite.width = 1.3
        _backgroundSprite.height = 2
        _backgroundSprite.drawControls()
    }
    
    func constructStartGameSprite() {
        _startGame = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "play_game")!.CGImage!, options: nil)
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
        _highScore = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "high_scores")!.CGImage!, options: nil)
        
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
    
}
