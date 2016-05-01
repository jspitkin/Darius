//
//  Animation.swift
//  Darius
//
//  Created by Jake Pitkin on 4/30/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class Animation {
    var texture: GLuint = 0
    var textureX: Double = 0
    var textureY: Double = 0
    var frameX: Double = 0
    var frameY: Double = 0
    var frameWidth: Double = 0
    var frameHeight: Double = 0
    var spriteIndex: Int = 0
    var rows: Int = 0
    var columns: Int = 0
    var curRow: Int = 1
    var curCol: Int = 1
    var framesPerAnimation: Int = 0
    var currentFrame: Int = 0
    
    func getFrameX() -> Double {
        return frameX / textureX;
    }
    
    func getFrameY() -> Double {
        return frameY / textureY;
    }
    
    func getFrameWidth() -> Double {
        return frameWidth / textureX;
    }
    
    func getFrameHeight() -> Double {
        return frameHeight / textureY;
    }
    
    func updateSprite() {
        if currentFrame == framesPerAnimation {
            currentFrame = 0;
            if curRow == rows {
                curRow = 1
                frameX = 15
                curCol++;
                frameY = frameY + 128;
            } else {
                frameX = frameX + 128;
                curRow++;
            }
        
            if curCol == columns {
                curCol = 1
                frameY = 10
            }
        }
        else{
            currentFrame++;
        }
    }
    
    func updateBackground() {
        if (frameY > textureY - frameHeight) {
            frameY = 0
        } else {
            frameY += 5
        }
    }
}
