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
    private let _sprite = Sprite()
    private let _sprite2 = Sprite()
    private var _lastUpdate: NSDate = NSDate()
    private var _marsTexture: GLKTextureInfo? = nil
    private var _pyramidTexture: GLKTextureInfo? = nil
    private var _circleTexture: GLKTextureInfo? = nil

    
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
        glClearColor(0.0, 1.0, 0.0, 1.0)
        // load the textures
        _marsTexture = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "spiral")!.CGImage!, options: nil)
        
        _pyramidTexture = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "pyramid")!.CGImage!, options: nil)
        
        _circleTexture = try!
            GLKTextureLoader.textureWithCGImage(UIImage(named: "circle")!.CGImage!, options: nil)
        
        _sprite2.texture = _circleTexture!.name
        _sprite2.width = 0.25
        _sprite2.height = 0.25
        _sprite2.position.y = -0.5
        
        //_sprite2.position.x = -1
        //_sprite2.position.y = -1
        _sprite.texture = _circleTexture!.name
        _sprite.width = 0.5
        _sprite.height = 0.5
        _sprite.position.y = 1
    }
    
    // runs right before drawInRect is called. You can think of this as your game loop.
    func update() {
        
        let now = NSDate()
        let elapsed = now.timeIntervalSinceDate(_lastUpdate)
        // TODO: Class GameModel.executeGameLoop(timeElapsed)
        _sprite.position.y = 0 + Double(elapsed * -0.1)
        //print(_sprite.position.y)
        // Collision detection
        detectCollisions()
    }
    
    func detectCollisions() {
        // (x2-x1)^2 + (y1-y2)^2 <= (r1+r2)^2
        let x = (_sprite2.position.x - _sprite.position.x) * (_sprite2.position.x - _sprite.position.x)
        let y = (_sprite.position.y - _sprite2.position.y) * (_sprite.position.y - _sprite2.position.y)
        let r = ((_sprite.height/2.0 + _sprite2.height/2.0) * (_sprite.height/2.0 + _sprite2.height/2.0))
        print("x :\(x) y:\(y) r:\(r)")
        if x + y <= Double(r)
        {
            print("got it")
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
        _sprite.draw()
        _sprite2.draw()
    }
}

