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
    
    var enemyFrequency: Int = 40
    var currentEnemyFrequency: Int = 0
    
    let firingFrequency: Int = 5
    var currentFiringFrequency: Int = 0
    var playerFiring: Bool = false
    
    var currentEnemyFiringFrequency: Int = 0
    var firingEnemyFrequency: Int = 15
    
    var playerHealth: Int = 5
    var playerScore: Int = 0
    
    var playingGame: Bool = false
    var displayGameScreen: Bool = true
    var gameOverMenu: Bool = false
    var highScoresScreen: Bool = false
    var gameOverDelay: Int = 0
    
    var asteroidsDestroyed: Int = 0
    var shipsDestroyed: Int = 0
    
    var enemyBulletVelocity: Double = -0.6
    var asteroidMaxVelocity: Double = 0.5
    var asteroidMinVelocity: Double = 0.15
 }

