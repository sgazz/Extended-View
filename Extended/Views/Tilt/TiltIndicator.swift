import SwiftUI

struct TiltIndicator: View {
    @ObservedObject var tiltController: TiltController
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private let maxAngle: CGFloat = 45.0
    private let indicatorSize: CGFloat = 60
    private let dotSize: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Позадински круг
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: indicatorSize, height: indicatorSize)
            
            // Мрежа
            ForEach([0, 90, 180, 270], id: \.self) { angle in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: indicatorSize)
                    .rotationEffect(.degrees(Double(angle)))
            }
            
            // Индикатор позиције
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            tiltController.isTiltActive ? Color.blue : Color.gray,
                            tiltController.isTiltActive ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: dotSize, height: dotSize)
                .offset(
                    x: min(max(CGFloat(tiltController.tiltAngle.width) / maxAngle * (indicatorSize/2 - dotSize/2), -(indicatorSize/2 - dotSize/2)), indicatorSize/2 - dotSize/2),
                    y: min(max(CGFloat(tiltController.tiltAngle.height) / maxAngle * (indicatorSize/2 - dotSize/2), -(indicatorSize/2 - dotSize/2)), indicatorSize/2 - dotSize/2)
                )
                .animation(.linear(duration: 0.1), value: tiltController.tiltAngle)
        }
        .opacity(tiltController.isTiltActive ? 1 : 0.6)
        .animation(.easeInOut, value: tiltController.isTiltActive)
    }
}

#Preview {
    TiltIndicator(tiltController: TiltController())
        .padding()
        .background(Color.black)
} 