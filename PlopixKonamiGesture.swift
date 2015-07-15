/*
* This file is part of the PlopixKonamiGesture package.
*
* (c) Sébastien Morel aka Plopix <morel.seb@gmail.com>
*
* For the full copyright and license information(MIT), please view the LICENSE
* file that was distributed with this source code.
*/

import UIKit
import UIKit.UIGestureRecognizerSubclass

/**
    Allow you to track the KomamiTouchCode
    Up,up,Down,Down,Left,Right,Left,Right,Tap,Tap
    We transform BA by Tap Tap for obvious simple reason
*/
class PlopixKonamiGesture: UIGestureRecognizer {
    
    /**
        Take care of the direction vectors
    */
    struct Direction {
        var up: CGVector
        var down: CGVector
        var left: CGVector
        var right: CGVector
        var neutral: CGVector
        init() {
            neutral = CGVectorMake(  0,  0 )
            up      = CGVectorMake(  0, -1 )
            down    = CGVectorMake(  0,  1 )
            left    = CGVectorMake( -1,  0 )
            right   = CGVectorMake(  1,  0 )
        }
        func isUp( vector: CGVector ) -> Bool {
            return vector == self.up
        }
        func isDown( vector: CGVector ) -> Bool {
            return vector == self.down
        }
        func isRight( vector: CGVector ) -> Bool {
            return vector == self.right
        }
        func isLeft( vector: CGVector ) -> Bool {
            return vector == self.left
        }
        func isNeutral( vector: CGVector ) -> Bool {
            return vector == self.neutral
        }
    }
    
    /**
        Direction instance
    */
    private let direction : Direction
    
    /**
        Configuration
    */
    private let swipeDistanceTolerance : CGFloat = 50.0
    private let swipeMinDistance : CGFloat = 50.0
    
    /** 
        Store the Konami Code
    */
    private var konamiCode: [CGVector] = []
    
    /**
        Store the user code
    */
    private var currentCode : [CGVector] = []
    
    /**
        Store the starting point of the gesture
    */
    private var startingPoint: CGPoint = CGPointZero
    
    /**
        init
    */
    override init(target: AnyObject, action: Selector) {
        self.direction = Direction()
        self.konamiCode = [
            direction.up,direction.up,
            direction.down,direction.down,
            direction.left,direction.right,
            direction.left,direction.right,
            direction.neutral,direction.neutral]
        super.init(target: target, action: action)
    }
    
    /**
        Get the next vector
    */
    private func nextVector() -> CGVector? {
        var succeedGesture = currentCode.count
        if ( succeedGesture == konamiCode.count) {
            return nil;
        }
        return konamiCode[succeedGesture]
    }
    
    /**
        Cancef if the user deviate
    */
    private func isOnHisWay( point: CGPoint ) -> Bool {
        let next: CGVector? = self.nextVector()
        if (( next)  == nil ) {
            return true
        }
        if ( direction.isNeutral( next! ) ) {
            return true;
        }
        var deltaX: CGFloat = point.x - startingPoint.x;
        var deltaY: CGFloat = point.y - startingPoint.y;
        
        // check the diversion
        if ( direction.isUp( next! ) || direction.isDown( next! ) ) {
            // next move in on Y, so we check X
            if ( abs( deltaX ) > self.swipeDistanceTolerance ) {
                return false;
            }
        }
        if ( direction.isLeft( next! ) || direction.isRight( next! ) ) {
            // next move in on X, so we check Y
            if ( abs( deltaY ) > self.swipeDistanceTolerance ) {
                return false;
            }
        }
        // check the direction
        if ( direction.isUp( next! ) ) {
            if ( deltaY < 0 ) {
                return true;
            }
        }
        if ( direction.isDown( next! ) ) {
            if ( deltaY > 0 ) {
                return true;
            }
        }
        if ( direction.isLeft( next! ) ) {
            if ( deltaX < 0 ) {
                return true;
            }
        }
        if ( direction.isRight( next! ) ) {
            if ( deltaX > 0 ) {
                return true;
            }
        }
        return false;
    }
    
    /**
        We need at least a minimum distance
    */
    private func hasReachMinDistance( point: CGPoint ) -> Bool {
        var deltaX: CGFloat = point.x - startingPoint.x;
        var deltaY: CGFloat = point.y - startingPoint.y;
        let next: CGVector? = self.nextVector()
        if (( next)  == nil ) {
            return true
        }
        
        if ( direction.isUp( next! ) || direction.isDown( next! ) ) {
            if ( abs( deltaY ) > self.swipeMinDistance ) {
                return true
            }
        }
        if ( direction.isLeft( next! ) || direction.isRight( next! ) ) {
            if ( abs( deltaX ) > self.swipeMinDistance ) {
                return true
            }
        }
        if ( direction.isNeutral( next! ) ) {
            return true;
        }
        return false
    }
    
    /**
        override method
        This gesture doesn't prevent anything
    */
    override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
    }
    
    /**
        Touches Began
    */
    override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if ( event.touchesForGestureRecognizer(self)?.count > 1 ) {
            // give a direct failed when more than touches are detected
            self.state = .Failed;
            return
        }
        let touch:UITouch = touches.first as! UITouch
        self.startingPoint = touch.locationInView(self.view)
        if ( self.state == .Changed ) {
            // do nothing now
            //@todo: add time check
            return
        }
        if ( self.state == .Possible ) {
            // only the first time
            self.state = .Began;
            return
        }
        self.state = .Failed;
    }
    
    /**
        Touches Moved
    */
    override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        let touch:UITouch = touches.first as! UITouch
        if ( !self.isOnHisWay(touch.locationInView(self.view)) ) {
            self.state = .Failed;
        }
    }
    
    /**
        Touches Ended
    */
    override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        let touch:UITouch = touches.first as! UITouch!
        let endPoint:CGPoint = touch.locationInView(self.view)
        
        if ( self.isOnHisWay(endPoint) && self.hasReachMinDistance(endPoint)  ) {
            //go next or finish
            let next: CGVector? = self.nextVector()
            if (( next)  != nil ) {
                self.currentCode.append(next!)
            }
            if ( self.currentCode == self.konamiCode ) {
                self.state = .Ended;
            }
            return
        }
        self.state = .Failed;
    }
    
    /**
        Touches Cancelled
    */
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.reset()
    }
    
    /**
        Touches Reset
    */
    override func reset() {
        currentCode = []
        self.startingPoint = CGPointZero
        super.reset()
    }
}