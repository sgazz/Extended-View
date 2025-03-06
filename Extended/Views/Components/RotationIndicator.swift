//
//  RotationIndicator.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI

struct RotationIndicator: View {
    let rotationAngle: Double
    let showRotationIndicator: Bool
    let persistentIndicators: Bool
    let isChangingValue: Bool
    let verticalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack {
            if showRotationIndicator || (persistentIndicators && isChangingValue) {
                Text(String(format: "%.0f°", rotationAngle))
                    .font(.system(.title3, design: .monospaced).bold())
                    .padding(12)
                    .background(Color.black.opacity(0.75))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    .transition(.opacity)
                    .padding(.top, verticalSizeClass == .compact ? 8 : 76)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showRotationIndicator)
        .animation(.easeInOut(duration: 0.3), value: isChangingValue)
    }
}

#Preview {
    RotationIndicator(
        rotationAngle: 45.0,
        showRotationIndicator: true,
        persistentIndicators: true,
        isChangingValue: false,
        verticalSizeClass: .regular
    )
    .padding()
    .background(Color.gray)
} 