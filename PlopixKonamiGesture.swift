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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
            neutral = CGVector(  dx: 0,  dy: 0 )
            up      = CGVector(  dx: 0, dy: -1 )
            down    = CGVector(  dx: 0,  dy: 1 )
            left    = CGVector( dx: -1,  dy: 0 )
            right   = CGVector(  dx: 1,  dy: 0 )
        }
        func isUp( _ vector: CGVector ) -> Bool {
            return vector == self.up
        }
        func isDown( _ vector: CGVector ) -> Bool {
            return vector == self.down
        }
        func isRight( _ vector: CGVector ) -> Bool {
            return vector == self.right
        }
        func isLeft( _ vector: CGVector ) -> Bool {
            return vector == self.left
        }
        func isNeutral( _ vector: CGVector ) -> Bool {
            return vector == self.neutral
        }
    }
    
    /**
     Direction instance
     */
    fileprivate let direction : Direction
    
    /**
     Configuration
     */
    fileprivate let swipeDistanceTolerance : CGFloat = 50.0
    fileprivate let swipeMinDistance : CGFloat = 50.0
    
    /**
     Store the Konami Code
     */
    fileprivate var konamiCode: [CGVector] = []
    
    /**
     Store the user code
     */
    fileprivate var currentCode : [CGVector] = []
    
    /**
     Store the starting point of the gesture
     */
    fileprivate var startingPoint: CGPoint = CGPoint.zero
    
    /**
     init
     */
    override init(target: Any?, action: Selector?) {
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
    fileprivate func nextVector() -> CGVector? {
        let succeedGesture = currentCode.count
        if ( succeedGesture == konamiCode.count) {
            return nil;
        }
        return konamiCode[succeedGesture]
    }
    
    /**
     Cancef if the user deviate
     */
    fileprivate func isOnHisWay( _ point: CGPoint ) -> Bool {
        let next: CGVector? = self.nextVector()
        if (( next)  == nil ) {
            return true
        }
        if ( direction.isNeutral( next! ) ) {
            return true;
        }
        let deltaX: CGFloat = point.x - startingPoint.x;
        let deltaY: CGFloat = point.y - startingPoint.y;
        
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
    fileprivate func hasReachMinDistance( _ point: CGPoint ) -> Bool {
        let deltaX: CGFloat = point.x - startingPoint.x;
        let deltaY: CGFloat = point.y - startingPoint.y;
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
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false;
    }
    
    /**
     Touches Began
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if ( event.touches(for: self)?.count > 1 ) {
            // give a direct failed when more than touches are detected
            self.state = .failed;
            return
        }
        let touch:UITouch = touches.first!
        self.startingPoint = touch.location(in: self.view)
        if ( self.state == .changed ) {
            // do nothing now
            //@todo: add time check
            return
        }
        if ( self.state == .possible ) {
            // only the first time
            self.state = .began;
            return
        }
        self.state = .failed;
    }
    
    /**
     Touches Moved
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let touch:UITouch = touches.first!
        if ( !self.isOnHisWay(touch.location(in: self.view)) ) {
            self.state = .failed;
        }
    }
    
    /**
     Touches Ended
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        let touch:UITouch = touches.first as UITouch!
        let endPoint:CGPoint = touch.location(in: self.view)
        
        if ( self.isOnHisWay(endPoint) && self.hasReachMinDistance(endPoint)  ) {
            //go next or finish
            let next: CGVector? = self.nextVector()
            if (( next)  != nil ) {
                self.currentCode.append(next!)
            }
            if ( self.currentCode == self.konamiCode ) {
                self.state = .ended;
            }
            return
        }
        self.state = .failed;
    }
    
    /**
     Touches Cancelled
     */
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.reset()
    }
    
    /**
     Touches Reset
     */
    override func reset() {
        currentCode = []
        self.startingPoint = CGPoint.zero
        super.reset()
    }
}
