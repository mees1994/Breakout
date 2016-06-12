//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by developer on 10/06/16.
//  Copyright (c) 2016 developer. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {
    
    private struct Constants {
        static var gameIsStarted = false
        
        static let paddleWidthMargin = 4;
        static let paddleHeight = CGFloat(10);
        static let paddleColor = UIColor.brownColor()
        
        static let ballRadius = CGFloat(15)
        
        static let nBricksRows = 3
        static let nBricksColumns = 5
        static let spaceBetweenBricks = CGFloat(10)
        static let brickHeight = CGFloat(30)
        static let brickColors = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor()]
        static let brickLifes = 1
    }
    
    private struct PathNames {
        static let topBarrier = "topBarrier"
        static let leftBarrier = "leftBarrier"
        static let rightBarrier = "rightBarrier"
        static let paddleBarrier = "paddleBarrier"
    }
    
    private var breakoutBehavior = BreakoutBehavior()

    @IBOutlet var gameView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return lazilyCreatedDynamicAnimator
    }()
    
    // MARK: - Delegates
    var timerBrick: NSTimer?
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        if let brickPathName = identifier as? String {
            if brickPathName.hasPrefix("brick") {
                bricks[brickPathName]!.brickLifes -= 1
                let brickLifes = bricks[brickPathName]!.brickLifes
                
                if (!bricks[brickPathName]!.brickHit) {
                    bricks[brickPathName]!.brickHit = true
                    timerBrick = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "setBrickHitFalse:", userInfo: ["brickPath": brickPathName], repeats: false)
                    // Required task 2
                    if (brickLifes > 0) {
                        UIView.transitionWithView(
                            bricks[brickPathName]!.brickView,
                            duration: 0.5,
                            options: UIViewAnimationOptions.TransitionFlipFromBottom,
                            animations: {
                                if (brickLifes > 0) {
                                    self.bricks[brickPathName]!.brickView.backgroundColor = Constants.brickColors[brickLifes]
                                }
                            },
                            completion: {
                                if($0){
                                    self.bricks[brickPathName]!.brickHit = false
                                }
                            }
                        )
                    } else {
                        self.bricks[brickPathName]!.brickHit = false
                        self.bricks[brickPathName]!.brickView.removeFromSuperview()
                        self.breakoutBehavior.removeBarrier(brickPathName)
                        UIView.transitionWithView(self.bricks[brickPathName]!.brickView,
                            duration: 0.3,
                            options: UIViewAnimationOptions.CurveEaseInOut,
                            animations: { },
                            completion: {
                                if ($0) {
                                    self.bricks.removeValueForKey(brickPathName)
                                }
                                if(self.bricks.count <= 0) {
                                    self.levelFinished()
                                }
                                self.timerBrick!.invalidate()
                        })

                    }
                }
            }
        }
    }
    
    func setBrickHitFalse(timer: NSTimer) {
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        var brickPathName:String = (userInfo["brickPath"] as! String)
        if(bricks[brickPathName] != nil){
            bricks[brickPathName]!.brickHit = false
        }
        
    }
    
        
    // Mark: GestureRecognizer
    
    @IBAction func startGame(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if (!Constants.gameIsStarted) {
                instructionsLabel.hidden = true
                Constants.gameIsStarted = true
                let ball = createBall()
                placeBallOnField(ball)
                breakoutBehavior.addBall(ball)
                breakoutBehavior.pushBall(ball)
                setBallTimer()
            } else {
                if (breakoutBehavior.balls.count < settingsModel().numberOfBalls) {
                    createBalls()
                    setBallTimer()
                } else {
                    // Required task 3
                    breakoutBehavior.pushBall(breakoutBehavior.balls.last!) //must be worked on
                }
            }
        }
    }
    
    @IBAction func movePaddle(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            paddleView.frame.origin.x = max(min(paddleView.frame.origin.x + sender.translationInView(gameView).x, gameView.bounds.maxX - paddleView.frame.size.width), 0.0)
            addPaddleBarrier()
            sender.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    
    // Mark: PlayField
    
    private func createPlayFieldBounds() {
        let topLeftPoint = CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y)
        let bottomLeftPoint = CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.maxY)
        let topRightPoint = CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.origin.y)
        let bottomRightPoint = CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.maxY)
        
        breakoutBehavior.createBoundaryForPlayField(named: PathNames.topBarrier, fromPoint: topLeftPoint, toPoint: topRightPoint)
        breakoutBehavior.createBoundaryForPlayField(named: PathNames.leftBarrier, fromPoint: bottomLeftPoint, toPoint: topLeftPoint)
        breakoutBehavior.createBoundaryForPlayField(named: PathNames.rightBarrier, fromPoint: topRightPoint, toPoint: bottomRightPoint)
    }
    
    // MARK: Paddle
    
    private lazy var paddleView: UIView = {
        let paddleView = UIView()
        paddleView.backgroundColor = Constants.paddleColor
        self.gameView.addSubview(paddleView)
        return paddleView
    }()
    
    func resetPaddle() {
        changePaddleSize()
        paddleView.center = CGPoint(x: self.gameView.bounds.width / 2, y: self.gameView.bounds.size.height / 5 * 4)
        addPaddleBarrier()
    }
    
    func changePaddleSize() {
        var paddleWidth = self.gameView.bounds.size.width / CGFloat(Constants.paddleWidthMargin)
        paddleWidth = paddleWidth + CGFloat(settingsModel().paddleSize * 20)
        let frame = CGRect(origin: CGPointZero, size: CGSize(width: paddleWidth, height: CGFloat(Constants.paddleHeight)))
        paddleView.frame = frame
        
    }
    
    private func addPaddleBarrier() {
        breakoutBehavior.addBarrier(UIBezierPath(rect: CGRect(origin: paddleView.frame.origin, size: paddleView.frame.size)), named: PathNames.paddleBarrier)
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
    
    private func createBalls() {
        let ball = createBall()
        placeBallOnField(ball)
        breakoutBehavior.addBall(ball)
        breakoutBehavior.pushBall(breakoutBehavior.balls.last!)
    }
    
    func spawnBalls() {
        if(settingsModel().startOver && Constants.gameIsStarted) {
            if(breakoutBehavior.balls.count < settingsModel().numberOfBalls) {
                createBalls()
            }
        }else{
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: Bricks
    
    private struct Brick {
        var brickView: UIView
        var brickLifes: NSInteger
        var brickHit: Bool
        
        init(view: UIView, lifes: NSInteger, hit: Bool) {
            brickView = view
            brickLifes = lifes
            brickHit = hit
        }
    }
    
    private var bricks = [String: Brick]()
    
    private func createBricks() {
        var row = 0
        var column = 0

        let totalSpaceBetweenBricks = Constants.spaceBetweenBricks * CGFloat(Constants.nBricksColumns + 1)
        var brickWidth = (gameView.frame.width - totalSpaceBetweenBricks) / CGFloat(Constants.nBricksColumns)
        let lifes = Constants.brickLifes * settingsModel().brickHealth

        while row <= Constants.nBricksRows {
            while column <= Constants.nBricksColumns {
                let frame = CGRect(origin: CGPoint(x: brickWidth * CGFloat(column) + Constants.spaceBetweenBricks * CGFloat(column + 1),
                                                   y: 30.0 * CGFloat(row + 1) + Constants.spaceBetweenBricks * CGFloat(row + 1)),
                                   size: CGSize(width: brickWidth, height: 30.0))
                let brick = UIView(frame: frame)

                brick.backgroundColor = Constants.brickColors[lifes]
                //brick.layer.cornerRadius = 10.0

                gameView.addSubview(brick)
                breakoutBehavior.addBarrier(UIBezierPath(rect: brick.frame), named: "brick \(row) \(column)")
                bricks["brick \(row) \(column)"] = Brick(view: brick, lifes: lifes, hit: false)
                
                column += 1
            }
            
            column = 0
            row += 1
        }
    }

    
    // MARK: Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createPlayFieldBounds()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBricks()
        breakoutBehavior.collisionDelegate = self
        resetPaddle()
        breakoutBehavior.speedVar = CGFloat(settingsModel().speedBalls)
        animator.addBehavior(breakoutBehavior)
        setBallTimer()
        
    }
    private var timer: NSTimer?
    private func setBallTimer() {
        println(settingsModel().startOver)
        if(settingsModel().startOver && Constants.gameIsStarted) {
            timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "spawnBalls", userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification,
        object: nil,
        queue: nil) { (notification) -> Void in
            self.reset()
        }
        removeDeathBricks()
    }
    
    func reset() {
        for ball in breakoutBehavior.balls {
            ball.removeFromSuperview()
        }
        removeAllBricks()
        timer?.invalidate()
        timer = nil
        animator.removeAllBehaviors()
        
        
        breakoutBehavior = BreakoutBehavior()
        animator.addBehavior(self.breakoutBehavior)
        
        resetPaddle()
        createBricks()
        
        breakoutBehavior.speedVar = CGFloat(settingsModel().speedBalls)
        breakoutBehavior.collisionDelegate = self
        setBallTimer()
    }
    
    func removeDeathBricks() {
        for brick in bricks {
            if(brick.1.brickLifes < 1){
                bricks.removeValueForKey(brick.0)
                brick.1.brickView.removeFromSuperview()
                breakoutBehavior.removeBarrier(brick.0)
            }
        }
    }
    
    func removeAllBricks() {
        for brick in bricks {
            bricks.removeValueForKey(brick.0)
            brick.1.brickView.removeFromSuperview()
            breakoutBehavior.removeBarrier(brick.0)
        }
    }
    

    private func levelFinished() {
        timer?.invalidate()
        timer = nil
        for ball in breakoutBehavior.balls {
            ball.removeFromSuperview()
        }

        if NSClassFromString("UIAlertController") != nil {
            let alertController = UIAlertController(title: "Game Over", message: "", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Play Again", style: .Default, handler: { (action) in
                self.reset()
            }))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertView = UIAlertView(title: "Game Over", message: "asdf", delegate: self, cancelButtonTitle: "Play Again")
            alertView.show()
        }
    }
    
}
