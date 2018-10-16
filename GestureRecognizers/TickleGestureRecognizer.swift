//
//  TickleGestureRecognizer.swift
//  GestureRecognizers
//
//  Created by Руслан Акберов on 16.10.2018.
//  Copyright © 2018 Ruslan Akberov. All rights reserved.
//

import UIKit

class TickleGestureRecognizer: UIGestureRecognizer {
    
    let requiredTickles = 2
    let distanceForTickleGesture: CGFloat = 25
    
    enum Direction: Int {
        case unknown = 0
        case left
        case right
    }
    
    var tickleCount = 0
    var tickleStartPoint = CGPoint.zero
    var lastDirection = Direction.unknown
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        tickleStartPoint = touch.location(in: view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else { return }
        let ticklePoint = touch.location(in: view)
        let moveAmt = ticklePoint.x - tickleStartPoint.x
        var currentDirection: Direction
        if moveAmt < 0 {
            currentDirection = .left
        } else {
            currentDirection = .right
        }
        
        if abs(moveAmt) < distanceForTickleGesture { return }
        if lastDirection == .unknown || (lastDirection == .right && currentDirection == .left) || (lastDirection == .left && currentDirection == .right) {
            tickleCount += 1
            tickleStartPoint = ticklePoint
            lastDirection = currentDirection
            
            if state == .possible && tickleCount > requiredTickles {
                state = .ended
            }
        }
    }
    
    override func reset() {
        tickleCount = 0
        tickleStartPoint = .zero
        lastDirection = .unknown
        if state == .possible {
            state = .failed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        reset()
    }
    
}


