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
                
                Spacer()
                
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
                
                // Дугме за избор слике
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.title2)
                        
                        Text("Изаберите слику")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView(
        selectedImage: .constant(nil),
        isImagePickerPresented: .constant(false)
    )
} 