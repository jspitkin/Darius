//
//  Sprite.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class Sprite {
    // DONT USE JPEG, USE PNG (it has an alpha channel)
    // 1024x1024 is preferred
    // Make an animation object
    // you only need to load a texture and can use it for multiple sprites
    static private var _program: GLuint = 0
    static private let _quad: [Float] = [
        -0.5, -0.5, // bottom left
        0.5, -0.5, // bottom right
        -0.5, 0.5, // top left
        0.5, 0.5, // top right
    ]
    
    // 1-to-1 with the _quad coordinates
    static private let _quadTextureCoordinates: [Float] = [
        0.0, 1.0, // bottom left
        1.0, 1.0, // bottom right
        0.0, 0.0, // top left
        1.0, 0.0, // top right
    ]
    
    private static func setup() {
        // Use NSString so we can later convert into a C style string.
        
        // CREATE TWO MORE UNIFORMS (SCALE AND TRANSLATE) FOR THE TEXTURES
        // This allow us to reference different parts of a PNG to create animations
        let vertexShaderSource: NSString = "" +
            "uniform vec2 translate; \n" +
            "attribute vec2 position; \n" +
            "uniform vec2 textureTranslate; \n" +
            "uniform vec2 textureScale; \n " +
            "attribute vec2 textureCoordinate; \n" +
            "uniform vec2 scale; \n" +
            "varying vec2 textureCoordinateInterpolated; \n" +
            "void main() \n" +
            "{ \n" +
            "    gl_Position = vec4(position.x * scale.x + translate.x, position.y * scale.y + translate.y, 0.0, 1.0); \n" +
        "        textureCoordinateInterpolated = vec2(textureCoordinate.x * textureScale.x + textureTranslate.x, textureCoordinate.y * textureScale.y + textureTranslate.y); \n" +
            "} \n"
        
        // TODO: Create and compile fragment shader
        let fragmentShaderSource: NSString = "" +
            "uniform highp vec4 color; \n" +
            "uniform sampler2D textureUnit;" +
            "varying highp vec2 textureCoordinateInterpolated; \n" +
            "void main() \n" +
            "{ \n" +
                "   gl_FragColor = texture2D(textureUnit, textureCoordinateInterpolated);" +
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
        Sprite._program = glCreateProgram()
        // now we have to attach the two shaders: the vertex and fragment shader
        // you must attach exactly one vertex and one fragment shader
        glAttachShader(Sprite._program, vertexShader)
        glAttachShader(Sprite._program, fragmentShader)
        // here is where we connect 0 to the actual variable
        glBindAttribLocation(_program, 0, "position")
        glBindAttribLocation(_program, 1, "textureCoordinate")
        // link the program together (similar to compiling a shader)
        glLinkProgram(Sprite._program)
        
        // check if everything went accordingly
        var programLinkStatus: GLint = GL_FALSE
        glGetProgramiv(Sprite._program, GLenum(GL_LINK_STATUS), &programLinkStatus)
        if (programLinkStatus == GL_FALSE) {
            var programCompileLogLength: GLint = 0
            glGetProgramiv(Sprite._program, GLenum(GL_INFO_LOG_LENGTH), &programCompileLogLength)
            let programCompileLog = UnsafeMutablePointer<GLchar>.alloc(Int(programCompileLogLength))
            glGetProgramInfoLog(Sprite._program, programCompileLogLength, nil, programCompileLog)
            let programCompileLogString: NSString? = NSString(UTF8String: programCompileLog)
            print("Program linking error: \(programCompileLogString)")
            // TODO: Exit with error UI
        }
        
        // Redefine OpenGL defaults
        // TODO: What changes will other OpenGL users in the program make?
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        glUseProgram(_program)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, _quad)
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, _quadTextureCoordinates)
        
    }
    
    
    var position: Vector = Vector()
    var initialPosition: Vector = Vector()
    var velocity: Vector = Vector()
    var width: Float = 1.0
    var height: Float = 1.0
    var isEnemy: Bool = false
    var isPlayer: Bool = false
    var isPlayerBullet: Bool = false
    var isEnemyBullet: Bool = false
    
    var animation: Animation = Animation()
    
    
    func draw() {
        if Sprite._program == 0{
            Sprite.setup()
        }
        
        
        glUniform2f(glGetUniformLocation(Sprite._program, "translate"), GLfloat(position.x), GLfloat(position.y))
        glUniform2f(glGetUniformLocation(Sprite._program, "scale"), width, height)
        glUniform4f(glGetUniformLocation(Sprite._program, "color"), 1.0, 0.0, 0.0 ,1.0)
        glUniform1i(glGetUniformLocation(Sprite._program, "textureUnit"), 0)
        glUniform2f(glGetUniformLocation(Sprite._program, "textureTranslate"), GLfloat(animation.getFrameX()), GLfloat(animation.getFrameY()))
        glUniform2f(glGetUniformLocation(Sprite._program, "textureScale"), GLfloat(animation.getFrameWidth()), GLfloat(animation.getFrameHeight()))
        glBindTexture(GLenum(GL_TEXTURE_2D), animation.texture)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        
        animation.updateSprite()
        
    }
}

// Model Objects
//class Movable: Sprite {
//    var startTime: Double
//    var endTime: Double
//    var path: [Vector]
//}