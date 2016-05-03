//
//  Model.swift
//  Darius
//
//  Created by Jake Pitkin on 5/1/16.
//  Copyright © 2016 Jake Pitkin. All rights reserved.
//

import GLKit

class Model {
    var level: Int = 1
    var asteroidFrequency: Int = 20
    var currentAsteroidFrequency: Int = 0
    
    let firingFrequency: Int = 5
    var currentFiringFrequency: Int = 0
    var playerFiring: Bool = false
    
    var playerHealth: Int = 5
    var playerScore: Int = 0
    
    var playingGame: Bool = false
    var displayGameScreen: Bool = true
    var gameOverMenu: Bool = false
    var gameOverDelay: Int = 0
 }

