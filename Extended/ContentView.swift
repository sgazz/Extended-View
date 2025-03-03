//
//  ContentView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // Konstante za kontrolu zuma i haptike
    private let zoomInFactor: CGFloat = 1.5
    private let zoomOutFactor: CGFloat = 0.75
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private let indicatorDisplayDuration: Double = 5.0 // Vreme prikazivanja indikatora u sekundama
    private let standardButtonSize: CGFloat = 60
    private let largeButtonSize: CGFloat = 80
    private let rotationSpeed: Double = 2.0 // Stepeni po frame-u
    private let snapAngle: Double = 45.0 // Ugao na koji se zaključava rotacija
    
    private func generateHapticFeedback(for scale: CGFloat) {
        if scale >= maxZoomScale || scale <= 0.5 {
            heavyHaptic.impactOccurred(intensity: 1.0)
        } else if scale >= maxZoomScale * 0.8 || scale <= 0.7 {
            mediumHaptic.impactOccurred(intensity: 0.7)
        } else {
            lightHaptic.impactOccurred(intensity: 0.3)
        }
    }
    
    private var zoomIndicatorOverlay: some View {
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
    
    private var rotationIndicatorOverlay: some View {
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
    
    private func snapToNearestAngle(_ angle: Double) -> Double {
        if !isAngleSnappingEnabled { return angle }
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
        let snapCount = round(normalizedAngle / snapAngle)
        return snapCount * snapAngle
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            RotationGesture()
                                .onChanged { angle in
                                    rotationAngle = angle.degrees
                                    if isAngleSnappingEnabled {
                                        let snappedAngle = snapToNearestAngle(rotationAngle)
                                        if abs(rotationAngle - snappedAngle) < 10 {
                                            rotationAngle = snappedAngle
                                            mediumHaptic.impactOccurred()
                                        }
                                    }
                                    showRotationIndicator = true
                                    isChangingValue = true
                                    lightHaptic.impactOccurred(intensity: 0.3)
                                }
                                .onEnded { _ in
                                    if isAngleSnappingEnabled {
                                        withAnimation(.spring()) {
                                            rotationAngle = snapToNearestAngle(rotationAngle)
                                        }
                                    }
                                    isChangingValue = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                                        showRotationIndicator = false
                                    }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = CGSize(
                                        width: lastOffset.width + gesture.translation.width,
                                        height: lastOffset.height + gesture.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    
                    // Overlay za indikatore
                    VStack(alignment: .leading) {
                        rotationIndicatorOverlay
                            .padding(.horizontal)
                            .padding(.top, verticalSizeClass == .compact ? 8 : 16)
                        Spacer()
                        zoomIndicatorOverlay
                            .padding(.horizontal)
                            .padding(.bottom, verticalSizeClass == .compact ? 8 : 16)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                VStack(spacing: verticalSizeClass == .compact ? 8 : 16) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: verticalSizeClass == .compact ? 50 : 80))
                        .foregroundColor(.white)
                        .padding(verticalSizeClass == .compact ? 8 : 16)
                    
                    Text("Easy for one hand")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(verticalSizeClass == .compact ? 4 : 16)
                    
                    if verticalSizeClass != .compact {
                        Text("Jednostavna manipulacija slikama\njednom rukom")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "hand.draw.fill", text: "Intuitivne kontrole za jednu ruku")
                            FeatureRow(icon: "arrow.clockwise", text: "Precizna rotacija sa zaključavanjem")
                            FeatureRow(icon: "hand.tap", text: "Napredni zoom sa haptičkim feedbackom")
                            FeatureRow(icon: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left", text: "Slobodno pomeranje slike")
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 30)
                        
                        Text("Izaberite način korišćenja")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.top, 30)
                            .padding(.bottom, 10)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                isLeftHandMode = true
                                hapticFeedback.impactOccurred()
                            }) {
                                VStack {
                                    Image(systemName: "hand.point.left.fill")
                                        .font(.system(size: 32))
                                    Text("Leva ruka")
                                        .font(.body)
                                }
                                .foregroundColor(.white)
                                .frame(width: 120, height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.black.opacity(0.5))
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 2.5)
                                )
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                            }
                            
                            Button(action: {
                                isLeftHandMode = false
                                hapticFeedback.impactOccurred()
                            }) {
                                VStack {
                                    Image(systemName: "hand.point.right.fill")
                                        .font(.system(size: 32))
                                    Text("Desna ruka")
                                        .font(.body)
                                }
                                .foregroundColor(.white)
                                .frame(width: 120, height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.black.opacity(0.5))
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 2.5)
                                )
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.bottom, 140)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                if verticalSizeClass != .compact {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Text("Izaberi sliku")
                            .font(.system(size: selectedImage == nil ? 20 : 16, weight: .medium))
                            .padding(.horizontal, selectedImage == nil ? 24 : 16)
                            .padding(.vertical, selectedImage == nil ? 14 : 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2.5)
                            )
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                    .padding(.bottom, selectedImage == nil ? 40 : 30)
                }
            }
            
            // Plutajuća dugmad za zoom
            if selectedImage != nil {
        VStack {
                    Spacer()
                    HStack {
                        if isLeftHandMode {
                            zoomButtonsStack
                            Spacer()
                        } else {
                            Spacer()
                            zoomButtonsStack
                        }
                    }
                    .padding(.bottom, verticalSizeClass == .compact ? 50 : 100)
                    .padding(.horizontal)
                }
            }
        }
        .onTapGesture {
            // Uklanjam activateUI()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private var zoomButtonsStack: some View {
        VStack(spacing: verticalSizeClass == .compact ? (isLargeButtonMode ? 12 : 8) : (isLargeButtonMode ? 24 : 16)) {
            if verticalSizeClass == .compact {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                        Text("Izaberi sliku")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.5))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2.5)
                    )
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }
            }
            
            // Reset rotacije dugme
            if abs(rotationAngle) > 0.1 {
                Button(action: {
                    withAnimation(.spring()) {
                        rotationAngle = 0
                        hapticFeedback.impactOccurred()
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: isLargeButtonMode ? 24 : 20))
                        .padding(isLargeButtonMode ? 24 : 20)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                        .background(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }
            }
            
            // Dugmad za rotaciju
            HStack(spacing: isLargeButtonMode ? 16 : 12) {
                // Rotacija u smeru suprotnom od kazaljke
                Button(action: { }) {
                    Image(systemName: "rotate.left")
                        .font(.system(size: isLargeButtonMode ? 24 : 20))
                        .frame(width: isLargeButtonMode ? largeButtonSize : standardButtonSize,
                              height: isLargeButtonMode ? largeButtonSize : standardButtonSize)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                        .background(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .onEnded { _ in
                            hapticFeedback.prepare()
                            hapticFeedback.impactOccurred()
                            startContinuousRotation(clockwise: false)
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            stopContinuousRotation()
                        }
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        rotationAngle = snapToNearestAngle(rotationAngle - (isAngleSnappingEnabled ? snapAngle : 90))
                        hapticFeedback.impactOccurred()
                        showRotationIndicator = true
                        isChangingValue = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                            showRotationIndicator = false
                            isChangingValue = false
                        }
                    }
                }
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        rotationAngle = snapToNearestAngle(rotationAngle - 45)
                        hapticFeedback.impactOccurred(intensity: 0.7)
                        showRotationIndicator = true
                        isChangingValue = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                            showRotationIndicator = false
                            isChangingValue = false
                        }
                    }
                }
                
                // Rotacija u smeru kazaljke
                Button(action: { }) {
                    Image(systemName: "rotate.right")
                        .font(.system(size: isLargeButtonMode ? 24 : 20))
                        .frame(width: isLargeButtonMode ? largeButtonSize : standardButtonSize,
                              height: isLargeButtonMode ? largeButtonSize : standardButtonSize)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.5))
                        )
                        .background(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .onEnded { _ in
                            hapticFeedback.prepare()
                            hapticFeedback.impactOccurred()
                            startContinuousRotation(clockwise: true)
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            stopContinuousRotation()
                        }
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        rotationAngle = snapToNearestAngle(rotationAngle + (isAngleSnappingEnabled ? snapAngle : 90))
                        hapticFeedback.impactOccurred()
                        showRotationIndicator = true
                        isChangingValue = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                            showRotationIndicator = false
                            isChangingValue = false
                        }
                    }
                }
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        rotationAngle = snapToNearestAngle(rotationAngle + 45)
                        hapticFeedback.impactOccurred(intensity: 0.7)
                        showRotationIndicator = true
                        isChangingValue = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
                            showRotationIndicator = false
                            isChangingValue = false
                        }
                    }
                }
            }
            
            // Zoom In dugme
            Button(action: { }) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: isLargeButtonMode ? 24 : 20))
                    .frame(width: isLargeButtonMode ? largeButtonSize : standardButtonSize,
                          height: isLargeButtonMode ? largeButtonSize : standardButtonSize)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                    )
                    .background(
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                    )
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        hapticFeedback.prepare()
                        hapticFeedback.impactOccurred()
                        startContinuousZoom(zoomingIn: true)
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        stopContinuousZoom()
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    scale = maxZoomScale
                    isMaxZoomed = true
                    hapticFeedback.impactOccurred()
                }
            }
            
            // Zoom Out dugme
            Button(action: { }) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: isLargeButtonMode ? 24 : 20))
                    .frame(width: isLargeButtonMode ? largeButtonSize : standardButtonSize,
                          height: isLargeButtonMode ? largeButtonSize : standardButtonSize)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                    )
                    .background(
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                    )
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        hapticFeedback.prepare()
                        hapticFeedback.impactOccurred()
                        startContinuousZoom(zoomingIn: false)
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        stopContinuousZoom()
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    scale = 1.0
                    offset = .zero
                    lastOffset = .zero
                    isMaxZoomed = false
                    hapticFeedback.impactOccurred()
                }
            }
        }
        .padding(.vertical, verticalSizeClass == .compact ? (isLargeButtonMode ? 8 : 4) : (isLargeButtonMode ? 16 : 8))
    }
    
    // Dodajemo nove funkcije za kontinuirano zumiranje
    private func startContinuousZoom(zoomingIn: Bool) {
        stopContinuousZoom()
        showZoomIndicator = true
        isChangingValue = true
        var lastHapticTime = Date()
        
        zoomTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                if zoomingIn {
                    let zoomFactor = 1.02
                    let newScale = min(scale * zoomFactor, maxZoomScale)
                    scale = newScale
                    isMaxZoomed = newScale >= maxZoomScale
                    
                    // Haptički feedback samo na svakih 100ms
                    if Date().timeIntervalSince(lastHapticTime) >= 0.1 {
                        generateHapticFeedback(for: newScale)
                        lastHapticTime = Date()
                    }
                    
                    if newScale >= maxZoomScale {
                        stopContinuousZoom()
                    }
                } else {
                    let zoomFactor = 0.98
                    scale = max(0.5, scale * zoomFactor)
                    if scale <= 1.0 {
                        offset = .zero
                        lastOffset = .zero
                    }
                    
                    // Haptički feedback samo na svakih 100ms
                    if Date().timeIntervalSince(lastHapticTime) >= 0.1 {
                        generateHapticFeedback(for: scale)
                        lastHapticTime = Date()
                    }
                    
                    if scale <= 0.5 {
                        stopContinuousZoom()
                    }
                }
            }
        }
        
        RunLoop.current.add(zoomTimer!, forMode: .common)
    }
    
    private func stopContinuousZoom() {
        zoomTimer?.invalidate()
        zoomTimer = nil
        isChangingValue = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
            showZoomIndicator = false
        }
    }
    
    // Dodajemo funkcije za kontinuiranu rotaciju
    private func startContinuousRotation(clockwise: Bool) {
        stopContinuousRotation()
        showRotationIndicator = true
        isChangingValue = true
        isRotating = true
        var lastHapticTime = Date()
        
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                rotationAngle += clockwise ? rotationSpeed : -rotationSpeed
                if isAngleSnappingEnabled {
                    let snappedAngle = snapToNearestAngle(rotationAngle)
                    if abs(rotationAngle - snappedAngle) < rotationSpeed {
                        rotationAngle = snappedAngle
                        mediumHaptic.impactOccurred()
                    }
                }
                if abs(rotationAngle.truncatingRemainder(dividingBy: 360)) < rotationSpeed {
                    rotationAngle = round(rotationAngle / 360) * 360
                }
                
                // Haptički feedback samo na svakih 100ms
                if Date().timeIntervalSince(lastHapticTime) >= 0.1 {
                    lightHaptic.impactOccurred(intensity: 0.3)
                    lastHapticTime = Date()
                }
            }
        }
        
        RunLoop.current.add(rotationTimer!, forMode: .common)
    }
    
    private func stopContinuousRotation() {
        rotationTimer?.invalidate()
        rotationTimer = nil
        isRotating = false
        isChangingValue = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + indicatorDisplayDuration) {
            if !self.isRotating {
                self.showRotationIndicator = false
            }
        }
    }
    
    // Dodajemo cleanup kod
    private func cleanup() {
        stopContinuousZoom()
        stopContinuousRotation()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 32)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    ContentView()
}
