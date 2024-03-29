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
    
    var lastUpdate: NSDate = NSDate()
    
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
        
        if rows == 2 && columns == 6 {
            if currentFrame == framesPerAnimation {
                currentFrame = 0
                if curCol == columns {
                    curCol = 1
                    frameX = 6
                    curRow++;
                    frameY = frameY + 39;
                } else {
                    frameX = frameX + 56;
                    curCol++;
                }
                
                if curRow == rows {
                    curRow = 1
                    frameY = 6
                }
            }
            else {
                currentFrame++
            }
        }
        
        if rows == 0 && columns == 0 {
            return;
        }
        
        if rows == 8 && columns == 8 {
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
    }
    
    func updateExplosion() -> Bool {
        if curCol == 6 {
            return true
        }
        frameX = frameX + 63
        curCol++
        return false
    }
    
    func updateBackground() {
        if (frameY < 500) {
            frameY = 1400
        } else {
            frameY -= 5
        }
    }
    
    func updateMainBackground() {
        if (frameY > 477) {
            frameY -= 1
        }
        if (frameX > 477) {
            frameX -= 1
        }
    }
    
    func updateShipExplosion(phase: Int) {
        switch phase {
        case 0:
            frameX = 6
            frameY = 165
            frameWidth = 7
            frameHeight = 7
        case 3:
            frameX = 22
            frameY = 161
            frameWidth = 15
            frameHeight = 15
        case 6:
            frameX = 45
            frameY = 158
            frameWidth = 21
            frameHeight = 21
        case 9:
            frameX = 74
            frameY = 151
            frameWidth = 39
            frameHeight = 35
        case 12:
            frameX = 0
            frameY = 194
            frameWidth = 45
            frameHeight = 41
        case 15:
            frameX = 51
            frameY = 192
            frameWidth = 53
            frameHeight = 49
        case 18:
            frameWidth = 0
            frameHeight = 0
        default:
            break
        }
    }
    
}
