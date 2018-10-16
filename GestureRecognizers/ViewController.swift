//
//  ViewController.swift
//  GestureRecognizers
//
//  Created by Руслан Акберов on 11/10/2018.
//  Copyright © 2018 Ruslan Akberov. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var homerPan: UIPanGestureRecognizer!
    @IBOutlet var donutPan: UIPanGestureRecognizer!
    
    var chompPlayer: AVAudioPlayer? = nil
    var hehePlayer: AVAudioPlayer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setSoundTap()
    }

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view) // center of sender.view is (0, 0) coordinates
        guard let imageView = sender.view else { return }
        // imageView.center - centet of the imageView in the view coordinate system
        imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            
        // to prevent translation compbine each time set it zero point, if not image rapidly move off the screen
        sender.setTranslation(.zero, in: view)
        
        // add deceleration
        if sender.state == .ended {
            let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
            let velocity = sender.velocity(in: view)

            // final point with decelerating
            var finalPoint = CGPoint(
                x: imageView.center.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
                y: imageView.center.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
            )
            
            // image should not move out of the screen
            finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
            finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)

            let relativeInitialVelocity = CGVector(
                dx: relativeVelocity(velocity: velocity.x, from: imageView.center.x, to: finalPoint.x),
                dy: relativeVelocity(velocity: velocity.y, from: imageView.center.y, to: finalPoint.y)
            )

            let timingParameters = UISpringTimingParameters(dampingRatio: 0.9, initialVelocity: relativeInitialVelocity)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            animator.addAnimations {
                imageView.center = finalPoint
            }
            animator.startAnimation()
        }
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let imageView = sender.view else { return }
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    @IBAction func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard let imageView = sender.view else { return }
        imageView.transform = imageView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    // Play sound when tap gesture occurs
    
    func loadSound(filename: String) -> AVAudioPlayer {
        let url = Bundle.main.url(forResource: filename, withExtension: "caf")
        var player = AVAudioPlayer()
        do {
            try player = AVAudioPlayer(contentsOf: url!)
            player.prepareToPlay()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return player
    }
    
    func setSoundTap() {
        let filteredSubviews = view.subviews.filter { $0 is UIImageView }
        filteredSubviews.forEach {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            recognizer.delegate = self
            $0.addGestureRecognizer(recognizer)
            // tap gesture recognizer will only get called if no pan is detected
            recognizer.require(toFail: homerPan)
            recognizer.require(toFail: donutPan)
            
            // add custom gesture
            let customRecognizer = TickleGestureRecognizer(target: self, action: #selector(handleTickle))
            customRecognizer.delegate = self
            $0.addGestureRecognizer(customRecognizer)
        }
        chompPlayer = loadSound(filename: "chomp")
        hehePlayer = loadSound(filename: "hehe")
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        chompPlayer?.play()
    }
    
    @objc func handleTickle(recognizer: TickleGestureRecognizer) {
        hehePlayer?.play()
    }

    // Distance traveled after decelerating to zero velocity at a constant rate.
    
    private func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return initialVelocity / 10000 * decelerationRate / (1 - decelerationRate)
    }

    // Calculates the relative velocity needed for the initial velocity of the animation (decrease swipe velocity).
    
    private func relativeVelocity(velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0  else { return 0 }
        return velocity / (targetValue - currentValue)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    // don't forget to connect delegates in IB for each gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

