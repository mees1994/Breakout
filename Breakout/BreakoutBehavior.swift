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
    
    var collisionDelegate: UICollisionBehaviorDelegate? {
        didSet { collider.collisionDelegate = collisionDelegate}
    }

    private lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.collisionMode = UICollisionBehaviorMode.Boundaries
        lazilyCreatedCollider.action = {
            for item in lazilyCreatedCollider.items {
                if let ball = item as? UIView {
                    if !CGRectIntersectsRect(ball.frame, self.dynamicAnimator!.referenceView!.bounds) { // Remove each ball that isn't within the reference view
                        self.removeBall(ball)
                    }
                }
            }
        }
        return lazilyCreatedCollider
    }()
    
    func createBoundaryForPlayField(named name: String, fromPoint: CGPoint, toPoint: CGPoint) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, fromPoint: fromPoint, toPoint: toPoint)
    }
    
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

    var balls: [UIView] {
        return ballBehavior.items.map{$0 as! UIView}
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
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBarrier(name: String) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
    var speedVar:CGFloat = 0.3
    
    func pushBall(ball: UIView) {
        if speedVar != 0.3 {
            speedVar = CGFloat(settingsModel().speedBalls)
        }
        switch(speedVar){
            case 1..<2: speedVar = 0.3
            case 2..<3: speedVar = 0.5
            case 3..<4: speedVar = 0.7
            case 4..<5: speedVar = 0.9
            case 5..<6: speedVar = 1.1
        default: speedVar = 0.3
        }
        
        
        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        push.magnitude = speedVar
        
        let randomLower = Double(90 - (arc4random_uniform(20) + 10))
        let randomHigher = Double(90 - (arc4random_uniform(20) + 10))
        let lower =  CGFloat((randomLower * M_PI)/180)
        let upper = CGFloat((randomHigher * M_PI)/180)
        let angle = CGFloat.randomRadian(lower: lower,upper)
        push.angle = angle
        

        push.action = { [weak push] in
            if !push!.active {
                self.removeChildBehavior(push!)
            }
        }
        addChildBehavior(push)
    }
}
//https://github.com/sanjibahmad/Animation/blob/master/Animation/BreakoutBehavior.swift
//copied extension for random radians
private extension CGFloat {
    static func randomRadian(lower: CGFloat = 0, _ upper: CGFloat = CGFloat(2 * M_PI)) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}
