//
//  ZoomIndicator.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI

struct ZoomIndicator: View {
    let scale: Double
    let showZoomIndicator: Bool
    let persistentIndicators: Bool
    let isChangingValue: Bool
    let verticalSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack {
            if showZoomIndicator || (persistentIndicators && isChangingValue) {
                Text(String(format: "%.1fx", scale))
                    .font(.system(.title3, design: .monospaced).bold())
                    .padding(12)
                    .background(Color.black.opacity(0.75))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    .transition(.opacity)
                    .padding(.bottom, verticalSizeClass == .compact ? 60 : 100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showZoomIndicator)
        .animation(.easeInOut(duration: 0.3), value: isChangingValue)
    }
}

#Preview {
    ZoomIndicator(
        scale: 2.5,
        showZoomIndicator: true,
        persistentIndicators: true,
        isChangingValue: false,
        verticalSizeClass: .regular
    )
    .padding()
    .background(Color.gray)
} 