//
//  GestureHandlers.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import UIKit

struct ImageGestureModifier: ViewModifier {
    @Binding var scale: Double
    @Binding var rotationAngle: Double
    @Binding var offset: CGSize
    @Binding var isChangingValue: Bool
    let minZoomScale: Double
    let maxZoomScale: Double
    let snapAngle: Double
    let isAngleSnappingEnabled: Bool
    
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isChangingValue = true
                        offset = CGSize(
                            width: offset.width + value.translation.width,
                            height: offset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        isChangingValue = false
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        isChangingValue = true
                        let newScale = scale * value
                        scale = min(max(newScale, minZoomScale), maxZoomScale)
                        triggerZoomHaptic(
                            scale: scale,
                            maxScale: maxZoomScale,
                            minScale: minZoomScale
                        )
                    }
                    .onEnded { _ in
                        isChangingValue = false
                    }
            )
            .gesture(
                RotationGesture()
                    .onChanged { value in
                        isChangingValue = true
                        let newAngle = rotationAngle + value.degrees
                        let snappedAngle = snapToNearestAngle(newAngle)
                        
                        let isSnapping = abs(snappedAngle - newAngle) < 1.0 && isAngleSnappingEnabled
                        if isSnapping {
                            rotationAngle = snappedAngle
                        } else {
                            rotationAngle = newAngle
                        }
                        
                        triggerRotationHaptic(
                            angle: rotationAngle,
                            isSnapping: isSnapping
                        )
                    }
                    .onEnded { _ in
                        isChangingValue = false
                        if isAngleSnappingEnabled {
                            rotationAngle = snapToNearestAngle(rotationAngle)
                        }
                    }
            )
    }
    
    private func snapToNearestAngle(_ angle: Double) -> Double {
        if !isAngleSnappingEnabled { return angle }
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
        let snapCount = round(normalizedAngle / snapAngle)
        return snapCount * snapAngle
    }
    
    private func triggerZoomHaptic(scale: Double, maxScale: Double, minScale: Double) {
        if scale >= maxScale * 0.95 || scale <= minScale * 1.05 {
            heavyHaptic.impactOccurred(intensity: 1.0)
        } else if scale >= maxScale * 0.8 || scale <= 0.7 {
            mediumHaptic.impactOccurred(intensity: 0.7)
        } else {
            lightHaptic.impactOccurred(intensity: 0.3)
        }
    }
    
    private func triggerRotationHaptic(angle: Double, isSnapping: Bool) {
        if isSnapping {
            mediumHaptic.impactOccurred(intensity: 0.8)
        } else {
            lightHaptic.impactOccurred(intensity: 0.3)
        }
    }
}

extension View {
    func imageGestures(
        scale: Binding<Double>,
        rotationAngle: Binding<Double>,
        offset: Binding<CGSize>,
        isChangingValue: Binding<Bool>,
        minZoomScale: Double,
        maxZoomScale: Double,
        snapAngle: Double,
        isAngleSnappingEnabled: Bool
    ) -> some View {
        self.modifier(
            ImageGestureModifier(
                scale: scale,
                rotationAngle: rotationAngle,
                offset: offset,
                isChangingValue: isChangingValue,
                minZoomScale: minZoomScale,
                maxZoomScale: maxZoomScale,
                snapAngle: snapAngle,
                isAngleSnappingEnabled: isAngleSnappingEnabled
            )
        )
    }
} 