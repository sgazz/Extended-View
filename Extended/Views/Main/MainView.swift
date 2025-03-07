//
//  MainView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI
import UIKit
import CoreMotion

struct MainView: View {
    // MARK: - State
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var lastDragPosition: CGPoint?
    @State private var initialDragPosition: CGPoint?
    @State private var initialScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    @State private var isMaxZoomed: Bool = false
    @State private var maxZoomScale: CGFloat = 10.0
    @State private var isDraggingForZoom: Bool = false
    @State private var isLeftHandMode: Bool = false
    @State private var zoomTimer: Timer?
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var showZoomIndicator: Bool = false
    @State private var showRotationIndicator: Bool = false
    @State private var isLargeButtonMode: Bool = false
    @State private var persistentIndicators: Bool = false
    @State private var isChangingValue: Bool = false
    @State private var rotationTimer: Timer?
    @State private var isRotating: Bool = false
    @State private var isAngleSnappingEnabled: Bool = true
    
    // Радијални мени
    @State private var isRadialMenuShowing: Bool = false
    @State private var radialMenuPosition: CGPoint = .zero
    
    // Тилт контролер
    @StateObject private var tiltController = TiltController()
    
    // MARK: - Константе
    private let zoomInFactor: CGFloat = 1.5
    private let zoomOutFactor: CGFloat = 0.75
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private let indicatorDisplayDuration: Double = 5.0
    private let standardButtonSize: CGFloat = 60
    private let largeButtonSize: CGFloat = 80
    private let rotationSpeed: Double = 2.0
    private let snapAngle: Double = 45.0
    
    // MARK: - Environment
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Позадина
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            if let image = selectedImage {
                // Приказ слике
                imageView(image)
            } else {
                // Почетни екран
                WelcomeView(
                    selectedImage: $selectedImage,
                    isImagePickerPresented: $isImagePickerPresented
                )
            }
            
            // Радијални мени
            RadialMenuView(
                menuItems: radialMenuItems,
                position: $radialMenuPosition,
                isShowing: $isRadialMenuShowing
            )
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { oldImage, newImage in
            // Центрирамо слику када се изабере нова
            centerImage()
        }
    }
    
    // MARK: - Приказ слике
    private func imageView(_ image: UIImage) -> some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(scale)
                .offset(offset)
                .offset(tiltController.offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .onChange(of: scale) { oldScale, newScale in
                    let imageSize = CGSize(
                        width: image.size.width,
                        height: image.size.height
                    )
                    tiltController.updateDimensions(
                        imageSize: imageSize,
                        viewSize: geometry.size,
                        scale: newScale
                    )
                }
                .onAppear {
                    let imageSize = CGSize(
                        width: image.size.width,
                        height: image.size.height
                    )
                    tiltController.updateDimensions(
                        imageSize: imageSize,
                        viewSize: geometry.size,
                        scale: scale
                    )
                    
                    // Експлицитно центрирамо слику када се учита
                    DispatchQueue.main.async {
                        centerImage()
                    }
                }
                .withLongPressGesture(
                    menuPosition: $radialMenuPosition,
                    isMenuShowing: $isRadialMenuShowing
                )
        }
    }
    
    // MARK: - Ставке радијалног менија
    private var radialMenuItems: [RadialMenuItem] {
        [
            // Зумирање
            RadialMenuItem(
                icon: "plus.magnifyingglass",
                title: "Зум",
                action: {
                    withAnimation(.spring()) {
                        scale = min(maxZoomScale, scale * zoomInFactor)
                        showZoomIndicator = true
                        
                        // Сакривамо индикатор након одређеног времена
                        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                            showZoomIndicator = false
                        }
                    }
                    mediumHaptic.impactOccurred(intensity: 0.8)
                }
            ),
            
            // Ротација
            RadialMenuItem(
                icon: "arrow.clockwise",
                title: "Ротација",
                action: {
                    withAnimation(.spring()) {
                        rotationAngle += 90
                        showRotationIndicator = true
                        
                        // Сакривамо индикатор након одређеног времена
                        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                            showRotationIndicator = false
                        }
                    }
                    mediumHaptic.impactOccurred(intensity: 0.8)
                }
            ),
            
            // Тилт контрола
            RadialMenuItem(
                icon: "move.3d",
                title: "Тилт",
                action: {
                    if tiltController.isTiltActive {
                        tiltController.stopTilt()
                    } else {
                        tiltController.startTilt()
                    }
                    mediumHaptic.impactOccurred(intensity: 0.8)
                }
            ),
            
            // Ресетовање
            RadialMenuItem(
                icon: "arrow.counterclockwise",
                title: "Ресет",
                action: {
                    centerImage()
                    heavyHaptic.impactOccurred(intensity: 1.0)
                }
            ),
            
            // Избор слике
            RadialMenuItem(
                icon: "photo",
                title: "Слика",
                action: {
                    isImagePickerPresented = true
                    mediumHaptic.impactOccurred(intensity: 0.8)
                }
            ),
            
            // Подешавања
            RadialMenuItem(
                icon: "gear",
                title: "Подешавања",
                action: {
                    // Овде ћемо имплементирати отварање подешавања
                    mediumHaptic.impactOccurred(intensity: 0.8)
                }
            )
        ]
    }
    
    // MARK: - Функције
    
    // Функција за центрирање слике
    private func centerImage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
            rotationAngle = 0.0
            offset = .zero
            lastOffset = .zero
            isMaxZoomed = false
            
            // Осигуравамо да се тилт контролер такође ресетује
            if tiltController.isTiltActive {
                tiltController.stopTilt()
            }
        }
    }
}

#Preview {
    MainView()
} 