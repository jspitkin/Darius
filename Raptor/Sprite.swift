//
//  Sprite.swift
//  Raptor
//
//  Created by Jake Pitkin on 4/6/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class Sprite {
    static private var _program: GLuint = 0
    static private let _quad: [Float] = [
        -0.5, -0.5,
        0.5, -0.5,
        -0.5, 0.5,
        0.5, 0.5,
    ]
    
    var position: Vector = Vector()
    var width: Float = 1.0
    var height: Float = 1.0
    //var image: UIImage
    
    private static func setup() {
        // Use NSString so we can later convert into a C style string.
        let vertexShaderSource: NSString = "" +
        "uniform vec2 translate; \n" +
        "attribute vec2 position; \n" +
        "uniform vec2 scale; \n"
        "void main() \n" +
        "{ \n" +
        "    gl_Position = vec4(position.x + translate.x, position.y + translate.y, 0.0, 1.0); \n" +
        "} \n"
        
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
        
        // TODO: What changes will other OpenGL users in the program make?
        glUseProgram(_program)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, _quad)
    }
    
    func draw() {
        if Sprite._program == 0{
            Sprite.setup()
        }
        
        glUniform2f(glGetUniformLocation(Sprite._program, "translate"), GLfloat(position.x), GLfloat(position.y))
        glUniform2f(glGetUniformLocation(Sprite._program, "scale"), width, height)
        glUniform4f(glGetUniformLocation(Sprite._program, "color"), 1.0, 0.0, 0.0 ,1.0)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}

// Model Objects
//class Movable: Sprite {
//    var startTime: Double
//    var endTime: Double
//    var path: [Vector]
//}