//
//  settingsModel.swift
//  Breakout
//
//  Created by developer on 11/06/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

import Foundation

class settingsModel {
    private struct Constants {
        static let speedBall = "speedBall"
        static let paddleSize = "paddleSize"
        static let startOver = "startOver"
        static let numberOfBalls = "numberOfBalls"
        static let brickHealth = "brickHealth"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var speedBalls: Int{
        get { return defaults.objectForKey(Constants.speedBall) as? Int ?? 1}
        set { defaults.setObject(newValue, forKey: Constants.speedBall) }
    }
    
    var paddleSize: Int{
        get { return defaults.objectForKey(Constants.paddleSize) as? Int ?? 1}
        set {
            defaults.setObject(newValue, forKey: Constants.paddleSize)
        }
    }
    
    var startOver: Bool{
        get { return defaults.objectForKey(Constants.startOver) as? Bool ?? false}
        set { defaults.setObject(newValue, forKey: Constants.startOver) }
    }
    
    var numberOfBalls: Int{
        get { return defaults.objectForKey(Constants.numberOfBalls) as? Int ?? 1}
        set { defaults.setObject(newValue, forKey: Constants.numberOfBalls) }
    }
    
    var brickHealth: Int{
        get { return defaults.objectForKey(Constants.brickHealth) as? Int ?? 1}
        set { defaults.setObject(newValue, forKey: Constants.brickHealth) }
    }
}
