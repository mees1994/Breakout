//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by developer on 10/06/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController {
    
    private struct Constants {
        static let paddleWidthMargin = 6;
        static let paddleHeight = CGFloat(10);
        static let paddleColor = UIColor.brownColor()
        
        static let ballRadius = CGFloat(15)
    }

    @IBOutlet var gameView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBAction func startGame(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            instructionsLabel.hidden = true
            let ball = createBall()
            placeBallOnField(ball)
            breakoutBehavior.addBall(ball)
            
            breakoutBehavior.pushBall(ball)
        }
    }
    
    private let breakoutBehavior = BreakoutBehavior()
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return lazilyCreatedDynamicAnimator
    }()
    
        
    // Mark: GestureRecognizer
    
    @IBAction func movePaddle(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            paddleView.frame.origin.x = max(min(paddleView.frame.origin.x + sender.translationInView(gameView).x, gameView.bounds.maxX - paddleView.frame.size.width), 0.0)
            sender.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    
    // MARK: Paddle
    
    private lazy var paddleView: UIView = {
        let paddleWidth = self.gameView.bounds.size.width / CGFloat(Constants.paddleWidthMargin)
        let frame = CGRect(origin: CGPointZero, size: CGSize(width: paddleWidth, height: CGFloat(Constants.paddleHeight)))
        
        let paddleView = UIView(frame: frame)
        paddleView.backgroundColor = Constants.paddleColor
        
        self.gameView.addSubview(paddleView)
        
        return paddleView
    }()
    
    func resetPaddle() {
        let paddleWidth = self.gameView.bounds.size.width / CGFloat(Constants.paddleWidthMargin)
        paddleView.center = CGPoint(x: self.gameView.bounds.width / 2 - paddleWidth / 2, y: self.gameView.bounds.size.height / 5 * 4)
    }
    
    // MARK: ball
    
    private func placeBallOnField(ball: UIView) {
        var center = paddleView.center
        center.y -= Constants.paddleHeight / 2 + Constants.ballRadius
        ball.center = center
    }
    
    private func createBall() -> UIView {
        let ball = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: Constants.ballRadius * 2, height: Constants.ballRadius * 2)))
        ball.backgroundColor = UIColor.redColor()
        ball.layer.cornerRadius = Constants.ballRadius
        return ball
    }
    
    // MARK: Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resetPaddle()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
    }
    
}
