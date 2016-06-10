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
        static let paddleWidthMargin = 8;
        static let paddleHeight = 10;
        static let paddleColor = UIColor.brownColor()
    }

    @IBOutlet var gameView: UIView!
    
    @IBAction func startGame(sender: UITapGestureRecognizer) {
        
    }
    
    private lazy var paddleView: UIView = {
        let paddleWidth = self.gameView.bounds.size.width / CGFloat(Constants.paddleWidthMargin)
        let frame = CGRect(origin: CGPointZero, size: CGSize(width: paddleWidth, height: CGFloat(Constants.paddleHeight)))
        
        let paddleView = UIView(frame: frame)
        paddleView.backgroundColor = Constants.paddleColor
        
        self.gameView.addSubview(paddleView)
        
        return paddleView
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
    
    func resetPaddle() {
        let paddleWidth = self.gameView.bounds.size.width / CGFloat(Constants.paddleWidthMargin)
        paddleView.center = CGPoint(x: self.gameView.bounds.width / 2 - paddleWidth / 2, y: self.gameView.bounds.size.height / 5 * 4)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLayoutSubviews() {
        resetPaddle()
    }
    
}
