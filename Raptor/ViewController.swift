//
//  ViewController.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    
    private var _program: GLuint = 0
    private var _translateX: Float = 0.0
    private var _translateY: Float = 0.0


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
        
        // Use NSString so we can later convert into a C style string.
        let vertexShaderSource: NSString = "" +
            "uniform vec2 translate; \n" +
            "attribute vec2 position; \n" +
            "void main() \n" +
            "{ \n" +
            "    gl_Position = vec4(position.x + translate.x, position.y + translate.y, 0.0, 1.0); \n" +
            "} \n" +
            " \n"
        
        // Create and compile vertex shader
        let vertexShader: GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var vertexShaderSourceUTF8 = vertexShaderSource.UTF8String // returns an UnsafePointer object
        glShaderSource(vertexShader, 1, &vertexShaderSourceUTF8, nil) // you can take the address of something with '&' it returns an UnsafePointer
        glCompileShader(vertexShader) // compile
        var vertexShaderCompileStatus: GLint = GL_FALSE // lets us know if the above line compiled correctly
        glGetShaderiv(vertexShader, GLenum(GL_COMPILE_STATUS), &vertexShaderCompileStatus)
        
        // if the compile fails, error out
        if vertexShaderCompileStatus == GL_FALSE {
            // allocating space and getting the log message. no need to de-allocate memory, ARC will handle that
            var vertexShaderLogLength: GLint = 0
            glGetShaderiv(vertexShader, GLenum(GL_INFO_LOG_LENGTH), &vertexShaderLogLength)
            let vertexShaderLog = UnsafeMutablePointer<GLchar>.alloc(Int(vertexShaderLogLength))
            glGetShaderInfoLog(vertexShader, vertexShaderLogLength, nil, vertexShaderLog)
            let vertexShaderLogString: NSString? = NSString(UTF8String: vertexShaderLog)
            print("Vertex Shader Compile Failed! Error: \(vertexShaderLogString)")
            // TODO: Prevent drawing
        }
        
        // TODO: Create and compile fragment shader
        let fragmentShaderSource: NSString = "" +
        "void main() \n" +
        "{ \n" +
        "   gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);" +
        "} \n" +
        " \n"
        
        // Create and compile fragment shader
        let fragmentShader: GLuint = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        var fragmentShaderSourceUTF8 = fragmentShaderSource.UTF8String // returns an UnsafePointer object
        glShaderSource(fragmentShader, 1, &fragmentShaderSourceUTF8, nil) // you can take the address of something with '&' it returns an UnsafePointer
        glCompileShader(fragmentShader) // compile
        var fragmentShaderCompileStatus: GLint = GL_FALSE // lets us know if the above line compiled correctly
        glGetShaderiv(fragmentShader, GLenum(GL_COMPILE_STATUS), &fragmentShaderCompileStatus)
        
        // if the compile fails, error out
        if fragmentShaderCompileStatus == GL_FALSE {
            // allocating space and getting the log message. no need to de-allocate memory, ARC will handle that
            var fragmentShaderLogLength: GLint = 0
            glGetShaderiv(fragmentShader, GLenum(GL_INFO_LOG_LENGTH), &fragmentShaderLogLength)
            let fragmentShaderLog = UnsafeMutablePointer<GLchar>.alloc(Int(fragmentShaderLogLength))
            glGetShaderInfoLog(fragmentShader, fragmentShaderLogLength, nil, fragmentShaderLog)
            let fragmentShaderLogString: NSString? = NSString(UTF8String: fragmentShaderLog)
            print("Fragment Shader Compile Failed! Error: \(fragmentShaderLogString)")
        }
        
        // Link shaders into a full program
        _program = glCreateProgram()
        // now we have to attach the two shaders: the vertex and fragment shader
        // you must attach exactly one vertex and one fragment shader
        glAttachShader(_program, vertexShader)
        glAttachShader(_program, fragmentShader)
        // here is where we connect 0 to the actual variable
        glBindAttribLocation(_program, 0, "position")
        // link the program together (similar to compiling a shader)
        glLinkProgram(_program)
        
        // check if everything went accordingly
        var programLinkStatus: GLint = GL_FALSE
        glGetProgramiv(_program, GLenum(GL_LINK_STATUS), &programLinkStatus)
        if (programLinkStatus == GL_FALSE) {
            var programCompileLogLength: GLint = 0
            glGetProgramiv(_program, GLenum(GL_INFO_LOG_LENGTH), &programCompileLogLength)
            let programCompileLog = UnsafeMutablePointer<GLchar>.alloc(Int(programCompileLogLength))
            glGetProgramInfoLog(_program, programCompileLogLength, nil, programCompileLog)
            let programCompileLogString: NSString? = NSString(UTF8String: programCompileLog)
            print("Program linking error: \(programCompileLogString)")
            // TODO: Exit with error UI
        }
        glUseProgram(_program)
        glEnableVertexAttribArray(0)
    }
    
    // runs right before drawInRect is called. You can think of this as your game loop.
    func update() {
        
    }
    
    // Called everytime GLK should refresh it's view
    // Redrawing every pixel every frame at about 60 FPS (this is adjustable)
    // This can be thought of as the draw loop.
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // TODO: Draw a triangle
        let triangle: [Float] = [
            // triangle points
            0.0, 0.0, // x: 0 y: 0
            -1.0, 1.0, // x: 1 y: 0
            1.0, 1.0 // x: 0 y: 1
        ]
        
        _translateX += 0.000
        _translateY += -0.001
        
        // TODO: Draw a triangle
        // the number 0 was picked at random
        // all attributes must be enabled
        glUniform2f(glGetUniformLocation(_program, "translate"), _translateX, _translateY)
        glVertexAttribPointer(0,2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, triangle)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)

    }
}

