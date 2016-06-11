//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by developer on 10/06/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    //private let gravity = UIGravityBehavior()

    private lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollider
    }()
    
    private lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.allowsRotation = false
        lazilyCreatedBallBehavior.elasticity = 1.0
        lazilyCreatedBallBehavior.friction = 0.0
        lazilyCreatedBallBehavior.resistance = 0.0
        return lazilyCreatedBallBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    
    func pushBall(ball: UIView) {
        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        push.magnitude = 0.3
        
        // Onderstaande code gekopieerd om de hoek van de ball te bepalen.
        // Gekopieerd van https://github.com/sanjibahmad/Animation/blob/master/Animation/BreakoutBehavior.swift
        let linearVelocity = ballBehavior.linearVelocityForItem(ball)
        // derive the opposite angle from current velocity
        let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x))
        let oppositeAngle = CGFloat((currentAngle + M_PI) % (2 * M_PI))
        
        // add 30 degrees variation for random
        let lower = oppositeAngle - CGFloat.degreeToRadian(30)
        let upper = oppositeAngle + CGFloat.degreeToRadian(30)
        push.angle = CGFloat.randomRadian(lower: lower, upper)
        


        push.action = { [weak push] in
            if !push!.active {
                self.removeChildBehavior(push!)
            }
        }
        addChildBehavior(push)
    }
}

private extension CGFloat {
    static func randomRadian(lower: CGFloat = 0, _ upper: CGFloat = CGFloat(2 * M_PI)) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
    
    static func degreeToRadian(degree: Double) -> CGFloat {
        return CGFloat((degree * M_PI)/180)
    }
}
