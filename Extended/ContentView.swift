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
    
    // Konstante za kontrolu zuma dugmadima
    private let zoomInFactor: CGFloat = 1.5
    private let zoomOutFactor: CGFloat = 0.75
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Pregled slika")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        isLeftHandMode.toggle()
                    }) {
                        Image(systemName: isLeftHandMode ? "hand.point.left.fill" : "hand.point.right.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                
                Spacer()
                
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    
                } else {
                    VStack {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding()
                        
                        Text("Nema izabrane slike")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Kliknite na dugme ispod da izaberete sliku iz galerije")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Koristite plutajuća dugmad za zumiranje")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Dvostruki tap na dugme za maksimalni zoom/unzoom")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Pritisnite dugme \(isLeftHandMode ? "leve" : "desne") ruke u gornjem uglu za promenu režima rada")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.headline)
                        Text("Izaberi sliku iz galerije")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                }
                .padding(.bottom)
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
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
                    .padding(.bottom, 100) // Iznad dugmeta za izbor slike
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var zoomButtonsStack: some View {
        VStack(spacing: 16) {
            // Zoom In dugme
            Button(action: { }) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
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
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
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
    }
    
    // Dodajemo nove funkcije za kontinuirano zumiranje
    private func startContinuousZoom(zoomingIn: Bool) {
        // Zaustavimo postojeći timer ako postoji
        stopContinuousZoom()
        
        // Kreiramo novi timer koji će se izvršavati svakih 0.016 sekundi (približno 60fps)
        zoomTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                if zoomingIn {
                    let zoomFactor = 1.02 // Manji faktor za glatkije zumiranje
                    let newScale = min(scale * zoomFactor, maxZoomScale)
                    scale = newScale
                    isMaxZoomed = newScale >= maxZoomScale
                    if newScale >= maxZoomScale {
                        hapticFeedback.impactOccurred(intensity: 1.0)
                        stopContinuousZoom()
                    }
                } else {
                    let zoomFactor = 0.98 // Manji faktor za glatkije odzumiranje
                    scale = max(0.5, scale * zoomFactor)
                    if scale <= 1.0 {
                        offset = .zero
                        lastOffset = .zero
                    }
                    if scale <= 0.5 {
                        hapticFeedback.impactOccurred(intensity: 1.0)
                        stopContinuousZoom()
                    }
                }
            }
        }
        
        // Dodajemo RunLoop za glatkije izvršavanje na glavnoj niti
        RunLoop.current.add(zoomTimer!, forMode: .common)
    }
    
    private func stopContinuousZoom() {
        zoomTimer?.invalidate()
        zoomTimer = nil
    }
    
    // Dodajemo cleanup kod
    private func cleanup() {
        stopContinuousZoom()
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

#Preview {
    ContentView()
}
