import SwiftUI

struct TiltButton: View {
    @ObservedObject var tiltController: TiltController
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private let buttonSize: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 12) {
            // Тилт индикатор
            TiltIndicator(tiltController: tiltController)
                .frame(width: buttonSize * 1.4, height: buttonSize * 1.4)
            
            // Контроле за осе
            HStack(spacing: 8) {
                // Хоризонтално закључавање
                Button(action: {
                    tiltController.isHorizontalLocked.toggle()
                }) {
                    Image(systemName: tiltController.isHorizontalLocked ? "lock.horizontal.fill" : "lock.horizontal")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: buttonSize * 0.7, height: buttonSize * 0.7)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // Главно дугме
                Button(action: {
                    if tiltController.isTiltActive {
                        tiltController.stopTilt()
                    } else {
                        tiltController.startTilt()
                    }
                }) {
                    Image(systemName: "move.3d")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: buttonSize, height: buttonSize)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            tiltController.isTiltActive ? Color.blue.opacity(0.8) : Color.blue.opacity(0.6),
                                            tiltController.isTiltActive ? Color.blue : Color.blue.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                .scaleEffect(tiltController.isCalibrating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                          value: tiltController.isCalibrating)
                .onTapGesture(count: 2) {
                    tiltController.resetPosition()
                }
                
                // Вертикално закључавање
                Button(action: {
                    tiltController.isVerticalLocked.toggle()
                }) {
                    Image(systemName: tiltController.isVerticalLocked ? "lock.vertical.fill" : "lock.vertical")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: buttonSize * 0.7, height: buttonSize * 0.7)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            
            // Контроле за осетљивост
            if tiltController.isTiltActive {
                HStack(spacing: 16) {
                    Button(action: {
                        tiltController.decreaseSensitivity()
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    Text(String(format: "%.1fx", tiltController.sensitivity))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        tiltController.increaseSensitivity()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.3))
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(), value: verticalSizeClass)
    }
}

#Preview {
    TiltButton(tiltController: TiltController())
        .padding()
        .background(Color.gray.opacity(0.2))
} 