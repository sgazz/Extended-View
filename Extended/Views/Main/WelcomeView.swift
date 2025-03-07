//
//  WelcomeView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 8)
    }
}

struct WelcomeView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool
    @Binding var isLeftHandMode: Bool
    
    // Хаптички фидбек
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            // Модерни градијент background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1a2a6c"),
                    Color(hex: "b21f1f"),
                    Color(hex: "fdbb2d")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Главни садржај
            VStack(spacing: 30) {
                // Наслов апликације
                VStack(spacing: 10) {
                    Text("Extended")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Напредни прегледач слика")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 50)
                
                // Листа функција
                VStack(alignment: .leading, spacing: 5) {
                    Text("Функције")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    FeatureRow(icon: "hand.tap", text: "Интуитивне контроле за једну руку")
                    FeatureRow(icon: "plus.magnifyingglass", text: "Напредно зумирање")
                    FeatureRow(icon: "arrow.clockwise", text: "Прецизна ротација")
                    FeatureRow(icon: "move.3d", text: "Тилт контрола за померање")
                    FeatureRow(icon: "hand.point.left.fill", text: "Подршка за леворуке и десноруке")
                    FeatureRow(icon: "circle.grid.2x2", text: "Радијални мени за брзи приступ")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            
            // Дугмад у Green Thumb Zone
            VStack {
                Spacer()
                
                // Избор начина коришћења (лево/десноруки)
                HStack {
                    if isLeftHandMode {
                        // Леворуки распоред - дугмад на левој страни
                        thumbZoneButtons
                        Spacer()
                    } else {
                        // Десноруки распоред - дугмад на десној страни
                        Spacer()
                        thumbZoneButtons
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 20)
            }
        }
    }
    
    // Дугмад у Green Thumb Zone
    private var thumbZoneButtons: some View {
        VStack(alignment: isLeftHandMode ? .leading : .trailing, spacing: 20) {
            // Дугме за избор слике
            Button(action: {
                isImagePickerPresented = true
                hapticFeedback.impactOccurred(intensity: 0.7)
            }) {
                HStack {
                    if isLeftHandMode {
                        Image(systemName: "photo")
                            .font(.title2)
                        
                        Text("Изаберите слику")
                            .font(.title3)
                            .fontWeight(.semibold)
                    } else {
                        Text("Изаберите слику")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "photo")
                            .font(.title2)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 250)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            }
            
            // Дугмад за избор начина коришћења
            HStack(spacing: 15) {
                // Дугме за леворуки начин
                Button(action: {
                    isLeftHandMode = true
                    hapticFeedback.impactOccurred(intensity: 0.7)
                }) {
                    VStack {
                        Image(systemName: "hand.point.left.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("Леворуки")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(isLeftHandMode ? Color.white.opacity(0.3) : Color.black.opacity(0.3))
                    )
                    .overlay(
                        Circle()
                            .stroke(isLeftHandMode ? Color.white : Color.white.opacity(0.3), lineWidth: 2)
                    )
                }
                
                // Дугме за десноруки начин
                Button(action: {
                    isLeftHandMode = false
                    hapticFeedback.impactOccurred(intensity: 0.7)
                }) {
                    VStack {
                        Image(systemName: "hand.point.right.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("Десноруки")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(!isLeftHandMode ? Color.white.opacity(0.3) : Color.black.opacity(0.3))
                    )
                    .overlay(
                        Circle()
                            .stroke(!isLeftHandMode ? Color.white : Color.white.opacity(0.3), lineWidth: 2)
                    )
                }
            }
        }
    }
}

#Preview {
    WelcomeView(
        selectedImage: .constant(nil),
        isImagePickerPresented: .constant(false),
        isLeftHandMode: .constant(false)
    )
} 