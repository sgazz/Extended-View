//
//  RotationControls.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import UIKit

struct RotationControls: View {
    @Binding var rotationAngle: Double
    let isAngleSnappingEnabled: Bool
    let snapAngle: Double
    let isLeftHandMode: Bool
    let verticalSizeClass: UserInterfaceSizeClass?
    
    @State private var isRotatingLeft = false
    @State private var isRotatingRight = false
    @State private var rotationTimer: Timer?
    
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: 10) {
            // Rotate Left дугме
            Button(action: {
                lightHaptic.impactOccurred(intensity: 0.5)
                self.isRotatingLeft = true
                self.rotateLeft()
                self.startRotationTimer(for: .left)
            }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        self.isRotatingLeft = false
                        self.stopRotationTimer()
                    }
            )
            
            // Rotate Right дугме
            Button(action: {
                lightHaptic.impactOccurred(intensity: 0.5)
                self.isRotatingRight = true
                self.rotateRight()
                self.startRotationTimer(for: .right)
            }) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        self.isRotatingRight = false
                        self.stopRotationTimer()
                    }
            )
        }
        .padding()
        .background(Color.clear)
    }
    
    private enum RotationDirection {
        case left, right
    }
    
    private func startRotationTimer(for direction: RotationDirection) {
        stopRotationTimer()
        
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            switch direction {
            case .left:
                if isRotatingLeft {
                    rotateLeft()
                }
            case .right:
                if isRotatingRight {
                    rotateRight()
                }
            }
        }
    }
    
    private func stopRotationTimer() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }
    
    private func rotateLeft() {
        withAnimation(.easeInOut(duration: 0.1)) {
            let rotationIncrement = 5.0
            let newAngle = rotationAngle - rotationIncrement
            if isAngleSnappingEnabled {
                rotationAngle = snapToNearestAngle(newAngle)
            } else {
                rotationAngle = newAngle
            }
            
            triggerRotationHaptic(
                isSnapping: isAngleSnappingEnabled && abs(rotationAngle.truncatingRemainder(dividingBy: snapAngle)) < 0.1
            )
        }
    }
    
    private func rotateRight() {
        withAnimation(.easeInOut(duration: 0.1)) {
            let rotationIncrement = 5.0
            let newAngle = rotationAngle + rotationIncrement
            if isAngleSnappingEnabled {
                rotationAngle = snapToNearestAngle(newAngle)
            } else {
                rotationAngle = newAngle
            }
            
            triggerRotationHaptic(
                isSnapping: isAngleSnappingEnabled && abs(rotationAngle.truncatingRemainder(dividingBy: snapAngle)) < 0.1
            )
        }
    }
    
    private func snapToNearestAngle(_ angle: Double) -> Double {
        if !isAngleSnappingEnabled { return angle }
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
        let snapCount = round(normalizedAngle / snapAngle)
        return snapCount * snapAngle
    }
    
    private func triggerRotationHaptic(isSnapping: Bool) {
        if isSnapping {
            mediumHaptic.impactOccurred(intensity: 0.8)
        } else {
            lightHaptic.impactOccurred(intensity: 0.3)
        }
    }
}

#Preview {
    RotationControls(
        rotationAngle: .constant(0.0),
        isAngleSnappingEnabled: true,
        snapAngle: 45.0,
        isLeftHandMode: false,
        verticalSizeClass: .regular
    )
    .padding()
    .background(Color.gray.opacity(0.5))
} 