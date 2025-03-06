//
//  TiltIndicator.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import CoreMotion

struct TiltIndicator: View {
    let sensitivity: Double
    let lockHorizontal: Bool
    let lockVertical: Bool
    
    @State private var motionManager = CMMotionManager()
    @State private var pitch: Double = 0
    @State private var roll: Double = 0
    
    var body: some View {
        ZStack {
            // Позадина
            Circle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                )
            
            // Хоризонтални и вертикални индикатори
            VStack {
                Rectangle()
                    .fill(lockVertical ? Color.red.opacity(0.5) : Color.gray.opacity(0.3))
                    .frame(width: 2, height: 80)
            }
            
            HStack {
                Rectangle()
                    .fill(lockHorizontal ? Color.red.opacity(0.5) : Color.gray.opacity(0.3))
                    .frame(width: 80, height: 2)
            }
            
            // Покретна тачка која репрезентује тилт
            Circle()
                .fill(Color.blue)
                .frame(width: 24, height: 24)
                .offset(
                    x: lockHorizontal ? 0 : CGFloat(roll * 40 * sensitivity),
                    y: lockVertical ? 0 : CGFloat(pitch * 40 * sensitivity)
                )
        }
        .onAppear {
            startMotionUpdates()
        }
        .onDisappear {
            stopMotionUpdates()
        }
    }
    
    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                guard let motion = motion, error == nil else { return }
                
                self.pitch = motion.attitude.pitch
                self.roll = motion.attitude.roll
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

#Preview {
    TiltIndicator(sensitivity: 1.0, lockHorizontal: false, lockVertical: false)
        .padding()
        .background(Color.black)
} 