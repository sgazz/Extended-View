//
//  ZoomControls.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import UIKit

struct ZoomControls: View {
    @Binding var scale: Double
    let minZoomScale: Double
    let maxZoomScale: Double
    let isLeftHandMode: Bool
    let verticalSizeClass: UserInterfaceSizeClass?
    
    @State private var isZoomingIn = false
    @State private var isZoomingOut = false
    @State private var zoomTimer: Timer?
    
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        VStack(spacing: 10) {
            // Zoom In дугме
            Button(action: {
                lightHaptic.impactOccurred(intensity: 0.5)
                self.isZoomingIn = true
                self.zoomIn()
                self.startZoomTimer(for: .in)
            }) {
                Image(systemName: "plus.circle.fill")
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
                        self.isZoomingIn = false
                        self.stopZoomTimer()
                    }
            )
            
            // Zoom Out дугме
            Button(action: {
                lightHaptic.impactOccurred(intensity: 0.5)
                self.isZoomingOut = true
                self.zoomOut()
                self.startZoomTimer(for: .out)
            }) {
                Image(systemName: "minus.circle.fill")
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
                        self.isZoomingOut = false
                        self.stopZoomTimer()
                    }
            )
        }
        .padding()
        .background(Color.clear)
    }
    
    private enum ZoomDirection {
        case `in`, out
    }
    
    private func startZoomTimer(for direction: ZoomDirection) {
        stopZoomTimer()
        
        zoomTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            switch direction {
            case .in:
                if isZoomingIn {
                    zoomIn()
                }
            case .out:
                if isZoomingOut {
                    zoomOut()
                }
            }
        }
    }
    
    private func stopZoomTimer() {
        zoomTimer?.invalidate()
        zoomTimer = nil
    }
    
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.1)) {
            let zoomIncrement = 0.1
            scale = min(scale + zoomIncrement, maxZoomScale)
            if scale >= maxZoomScale * 0.95 {
                heavyHaptic.impactOccurred(intensity: 1.0)
            } else {
                lightHaptic.impactOccurred(intensity: 0.5)
            }
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.1)) {
            let zoomDecrement = 0.1
            scale = max(scale - zoomDecrement, minZoomScale)
            if scale <= minZoomScale * 1.05 {
                heavyHaptic.impactOccurred(intensity: 1.0)
            } else {
                lightHaptic.impactOccurred(intensity: 0.5)
            }
        }
    }
}

#Preview {
    ZoomControls(
        scale: .constant(1.0),
        minZoomScale: 0.5,
        maxZoomScale: 5.0,
        isLeftHandMode: false,
        verticalSizeClass: .regular
    )
    .padding()
    .background(Color.gray.opacity(0.5))
} 