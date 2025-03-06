//
//  WelcomeScreen.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI

struct WelcomeScreen: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var imageLoader: ImageLoader
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Позадина
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: verticalSizeClass == .compact ? 20 : 60)
                
                // Наслов
                Text("Extended Image")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, verticalSizeClass == .compact ? 0 : 20)
                
                Text("Advanced Image Manipulation")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if verticalSizeClass == .compact {
                    // Лендскејп изглед
                    HStack(spacing: 20) {
                        // Функционалности на левој страни
                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(icon: "hand.tap.fill", text: "Tailored for one-handed use")
                            FeatureRow(icon: "rotate.3d", text: "Precise rotation")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Функционалности на десној страни
                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(icon: "magnifyingglass.circle.fill", text: "Smart zoom")
                            FeatureRow(icon: "hand.draw.fill", text: "Intuitive movement and positioning")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                } else {
                    // Портретни изглед
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "hand.tap.fill", text: "Tailored for one-handed use")
                        FeatureRow(icon: "rotate.3d", text: "Precise rotation")
                        FeatureRow(icon: "magnifyingglass.circle.fill", text: "Smart zoom")
                        FeatureRow(icon: "hand.draw.fill", text: "Intuitive movement and positioning")
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Дугмад за избор руке
                HStack(spacing: 20) {
                    Button(action: {
                        settings.isLeftHandMode = true
                        let selectionHaptic = UISelectionFeedbackGenerator()
                        selectionHaptic.selectionChanged()
                    }) {
                        Text("Left Hand")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "43e97b"), Color(hex: "38f9d7")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color(hex: "43e97b").opacity(0.5), radius: 10, x: 0, y: 5)
                            .opacity(settings.isLeftHandMode ? 1 : 0.6)
                    }
                    
                    Button(action: {
                        settings.isLeftHandMode = false
                        let selectionHaptic = UISelectionFeedbackGenerator()
                        selectionHaptic.selectionChanged()
                    }) {
                        Text("Right Hand")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color(hex: "4facfe").opacity(0.5), radius: 10, x: 0, y: 5)
                            .opacity(settings.isLeftHandMode ? 0.6 : 1)
                    }
                }
                .padding(.top, verticalSizeClass == .compact ? 20 : 40)
                
                Spacer()
                
                // Дугме за одабир слике
                PhotosPicker(
                    selection: $imageLoader.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.black.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
                .onChange(of: imageLoader.selectedItem) { _ in
                    imageLoader.loadImage(from: imageLoader.selectedItem)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 40)
            }
            .padding()
            
            // Додатно дугме за одабир слике у лендскејп оријентацији
            if verticalSizeClass == .compact {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        PhotosPicker(
                            selection: $imageLoader.selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "photo.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding(8)
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
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

#Preview {
    WelcomeScreen()
        .environmentObject(Settings.shared)
        .environmentObject(ImageLoader.shared)
} 