//
//  TiltController.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import CoreMotion

class TiltController: ObservableObject {
    @Published var offset: CGSize = .zero
    @Published var isAvailable: Bool = false
    
    private var motionManager: CMMotionManager?
    private var sensitivity: Double = 0.5
    private var imageSize: CGSize = .zero
    private var viewSize: CGSize = .zero
    private var scale: CGFloat = 1.0
    private var lockHorizontal: Bool = false
    private var lockVertical: Bool = false
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1/60
        isAvailable = motionManager?.isDeviceMotionAvailable ?? false
    }
    
    func startTiltDetection(sensitivity: Double, lockHorizontal: Bool, lockVertical: Bool) {
        guard let motionManager = motionManager, motionManager.isDeviceMotionAvailable else { return }
        
        self.sensitivity = sensitivity
        self.lockHorizontal = lockHorizontal
        self.lockVertical = lockVertical
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            
            let sensitivityFactor = self.sensitivity * 100
            
            var xOffset: CGFloat = 0
            var yOffset: CGFloat = 0
            
            if !self.lockHorizontal {
                xOffset = CGFloat(motion.gravity.x * sensitivityFactor)
            }
            
            if !self.lockVertical {
                yOffset = CGFloat(motion.gravity.y * sensitivityFactor)
            }
            
            withAnimation(.spring()) {
                self.offset = CGSize(width: xOffset, height: yOffset)
            }
        }
    }
    
    func stopTiltDetection() {
        motionManager?.stopDeviceMotionUpdates()
        withAnimation(.spring()) {
            offset = .zero
        }
    }
    
    func updateDimensions(imageSize: CGSize, viewSize: CGSize, scale: CGFloat) {
        self.imageSize = imageSize
        self.viewSize = viewSize
        self.scale = scale
    }
    
    func updateSettings(sensitivity: Double, lockHorizontal: Bool, lockVertical: Bool) {
        self.sensitivity = sensitivity
        self.lockHorizontal = lockHorizontal
        self.lockVertical = lockVertical
    }
    
    deinit {
        motionManager?.stopDeviceMotionUpdates()
    }
} 