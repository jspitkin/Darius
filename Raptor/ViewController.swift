//
//  ViewController.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    private let _sprite = Sprite()
    private var _lastUpdate: NSDate = NSDate()
    
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
    }
    
    // runs right before drawInRect is called. You can think of this as your game loop.
    func update() {
        let now = NSDate()
        let elapsed = now.timeIntervalSinceDate(_lastUpdate)
        // TODO: Class GameModel.executeGameLoop(timeElapsed)
        _sprite.position.x =  Double(elapsed * 0.25)
    }
    
    // Called everytime GLK should refresh it's view
    // Redrawing every pixel every frame at about 60 FPS (this is adjustable)
    // This can be thought of as the draw loop.
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        _sprite.draw()
    }
}

