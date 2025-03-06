//
//  ImageEditorView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI
import CoreMotion
import UIKit

struct ImageEditorView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var imageLoader: ImageLoader
    
    @StateObject private var tiltController = TiltController()
    
    @State private var scale: Double = 1.0
    @State private var rotationAngle: Double = 0.0
    @State private var offset: CGSize = .zero
    @State private var isChangingValue = false
    @State private var showZoomIndicator = false
    @State private var showRotationIndicator = false
    @State private var lastScale: Double = 1.0
    
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Позадина
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                if let image = imageLoader.selectedImage {
                    // Приказ слике
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(CGFloat(scale))
                        .rotationEffect(.degrees(rotationAngle))
                        .offset(
                            x: offset.width + tiltController.offset.width,
                            y: offset.height + tiltController.offset.height
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .imageGestures(
                            scale: $scale,
                            rotationAngle: $rotationAngle,
                            offset: $offset,
                            isChangingValue: $isChangingValue,
                            minZoomScale: settings.minZoomScale,
                            maxZoomScale: settings.maxZoomScale,
                            snapAngle: settings.snapAngle,
                            isAngleSnappingEnabled: settings.isAngleSnappingEnabled
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                // Двоструки тап за ресетовање
                                if scale == 1.0 && rotationAngle == 0.0 && offset == .zero {
                                    scale = 2.0
                                    showZoomIndicator = true
                                    mediumHaptic.impactOccurred(intensity: 0.8)
                                } else {
                                    resetImage()
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showZoomIndicator = false
                                    showRotationIndicator = false
                                }
                            }
                        }
                        .onAppear {
                            let imageSize = CGSize(
                                width: image.size.width,
                                height: image.size.height
                            )
                            tiltController.updateDimensions(
                                imageSize: imageSize,
                                viewSize: proxy.size,
                                scale: CGFloat(scale)
                            )
                        }
                        .onChange(of: scale) { newScale in
                            if let image = imageLoader.selectedImage {
                                let imageSize = CGSize(
                                    width: image.size.width,
                                    height: image.size.height
                                )
                                tiltController.updateDimensions(
                                    imageSize: imageSize,
                                    viewSize: proxy.size,
                                    scale: CGFloat(newScale)
                                )
                            }
                        }
                }
                
                // Индикатори
                ZoomIndicator(
                    scale: scale,
                    showZoomIndicator: showZoomIndicator,
                    persistentIndicators: settings.persistentIndicators,
                    isChangingValue: isChangingValue,
                    verticalSizeClass: verticalSizeClass
                )
                
                RotationIndicator(
                    rotationAngle: rotationAngle,
                    showRotationIndicator: showRotationIndicator,
                    persistentIndicators: settings.persistentIndicators,
                    isChangingValue: isChangingValue,
                    verticalSizeClass: verticalSizeClass
                )
                
                // Контроле
                VStack {
                    Spacer()
                    
                    if verticalSizeClass == .regular {
                        // Контроле за portrait мод
                        HStack {
                            if settings.isLeftHandMode {
                                // Контроле на левој страни
                                controlsStack
                                Spacer()
                            } else {
                                // Контроле на десној страни
                                Spacer()
                                controlsStack
                            }
                        }
                        .padding(.bottom, 50)
                        .padding(.horizontal, 20)
                    } else {
                        // Контроле за landscape мод
                        HStack {
                            if settings.isLeftHandMode {
                                // Контроле на левој страни за landscape
                                landscapeControlsStack
                                Spacer()
                            } else {
                                // Контроле на десној страни за landscape
                                Spacer()
                                landscapeControlsStack
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
    
    // Контроле за портрет
    private var controlsStack: some View {
        VStack(spacing: 20) {
            // Tilt контрола
            TiltButton(
                isTiltEnabled: $settings.isTiltEnabled,
                tiltSensitivity: $settings.tiltSensitivity,
                lockTiltHorizontal: $settings.lockTiltHorizontal,
                lockTiltVertical: $settings.lockTiltVertical,
                onToggle: toggleTilt
            )
            
            // Контрола ротације
            RotationControls(
                rotationAngle: $rotationAngle,
                isAngleSnappingEnabled: settings.isAngleSnappingEnabled,
                snapAngle: settings.snapAngle,
                isLeftHandMode: settings.isLeftHandMode,
                verticalSizeClass: verticalSizeClass
            )
            
            // Контрола зумирања
            ZoomControls(
                scale: $scale,
                minZoomScale: settings.minZoomScale,
                maxZoomScale: settings.maxZoomScale,
                isLeftHandMode: settings.isLeftHandMode,
                verticalSizeClass: verticalSizeClass
            )
            
            // Ресет дугме
            Button(action: {
                mediumHaptic.impactOccurred(intensity: 0.8)
                withAnimation(.spring()) {
                    resetImage()
                }
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
            
            // Дугме за одабир слике
            PhotosPicker(
                selection: $imageLoader.selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Image(systemName: "photo.circle.fill")
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
            .onChange(of: imageLoader.selectedItem) { _ in
                imageLoader.loadImage(from: imageLoader.selectedItem)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // Контроле за landscape
    private var landscapeControlsStack: some View {
        VStack(spacing: 10) {
            // Tilt контрола
            TiltButton(
                isTiltEnabled: $settings.isTiltEnabled,
                tiltSensitivity: $settings.tiltSensitivity,
                lockTiltHorizontal: $settings.lockTiltHorizontal,
                lockTiltVertical: $settings.lockTiltVertical,
                onToggle: toggleTilt
            )
            
            // Контрола ротације
            RotationControls(
                rotationAngle: $rotationAngle,
                isAngleSnappingEnabled: settings.isAngleSnappingEnabled,
                snapAngle: settings.snapAngle,
                isLeftHandMode: settings.isLeftHandMode,
                verticalSizeClass: verticalSizeClass
            )
            
            // Контрола зумирања
            ZoomControls(
                scale: $scale,
                minZoomScale: settings.minZoomScale,
                maxZoomScale: settings.maxZoomScale,
                isLeftHandMode: settings.isLeftHandMode,
                verticalSizeClass: verticalSizeClass
            )
            
            // Дугме за одабир слике
            PhotosPicker(
                selection: $imageLoader.selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Image(systemName: "photo.circle.fill")
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
            .onChange(of: imageLoader.selectedItem) { _ in
                imageLoader.loadImage(from: imageLoader.selectedItem)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Ресет дугме
            Button(action: {
                mediumHaptic.impactOccurred(intensity: 0.8)
                withAnimation(.spring()) {
                    resetImage()
                }
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
        }
    }
    
    // Функција за ресетовање слике
    private func resetImage() {
        scale = 1.0
        rotationAngle = 0.0
        offset = .zero
        
        if settings.isTiltEnabled {
            settings.isTiltEnabled = false
            toggleTilt()
        }
        
        showZoomIndicator = true
        showRotationIndicator = true
        
        heavyHaptic.impactOccurred(intensity: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showZoomIndicator = false
            showRotationIndicator = false
        }
    }
    
    // Функције за управљање тилтом
    private func toggleTilt() {
        if settings.isTiltEnabled {
            tiltController.startTiltDetection(
                sensitivity: settings.tiltSensitivity,
                lockHorizontal: settings.lockTiltHorizontal,
                lockVertical: settings.lockTiltVertical
            )
        } else {
            tiltController.stopTiltDetection()
        }
        
        tiltController.updateSettings(
            sensitivity: settings.tiltSensitivity,
            lockHorizontal: settings.lockTiltHorizontal,
            lockVertical: settings.lockTiltVertical
        )
    }
}

#Preview {
    let mockSettings = Settings.shared
    let mockImageLoader = ImageLoader.shared
    mockImageLoader.isImageLoaded = true
    // Поставити тест слику ако је потребно
    // mockImageLoader.selectedImage = UIImage(named: "example")
    
    return ImageEditorView()
        .environmentObject(mockSettings)
        .environmentObject(mockImageLoader)
} 