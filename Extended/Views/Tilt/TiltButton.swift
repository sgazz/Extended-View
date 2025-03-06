//
//  TiltButton.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import CoreMotion
import UIKit

struct TiltButton: View {
    @Binding var isTiltEnabled: Bool
    @Binding var tiltSensitivity: Double
    @Binding var lockTiltHorizontal: Bool
    @Binding var lockTiltVertical: Bool
    
    var onToggle: () -> Void
    
    @State private var showSettings = false
    
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let selectionHaptic = UISelectionFeedbackGenerator()
    
    var body: some View {
        Button(action: {
            isTiltEnabled.toggle()
            mediumHaptic.impactOccurred(intensity: 0.8)
            onToggle()
        }) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                
                Image(systemName: "gyroscope")
                    .font(.system(size: 24))
                    .foregroundColor(isTiltEnabled ? .green : .white)
            }
            .frame(width: 50, height: 50)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    heavyHaptic.impactOccurred(intensity: 1.0)
                    showSettings = true
                }
        )
        .sheet(isPresented: $showSettings) {
            tiltSettingsView
        }
    }
    
    private var tiltSettingsView: some View {
        NavigationView {
            Form {
                Section(header: Text("Sensitivity")) {
                    VStack {
                        Slider(value: $tiltSensitivity, in: 0.1...1.0, step: 0.1)
                            .onChange(of: tiltSensitivity) { _ in
                                lightHaptic.impactOccurred(intensity: 0.5)
                            }
                        
                        HStack {
                            Text("Low")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("High")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Axis Lock")) {
                    Toggle("Lock Horizontal Axis", isOn: $lockTiltHorizontal)
                        .onChange(of: lockTiltHorizontal) { _ in
                            selectionHaptic.selectionChanged()
                        }
                    
                    Toggle("Lock Vertical Axis", isOn: $lockTiltVertical)
                        .onChange(of: lockTiltVertical) { _ in
                            selectionHaptic.selectionChanged()
                        }
                }
                
                Section {
                    HStack {
                        Spacer()
                        TiltIndicator(
                            sensitivity: tiltSensitivity,
                            lockHorizontal: lockTiltHorizontal, 
                            lockVertical: lockTiltVertical
                        )
                        .frame(width: 200, height: 200)
                        Spacer()
                    }
                    .padding(.vertical)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Tilt Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                showSettings = false
                selectionHaptic.selectionChanged()
            })
        }
    }
}

#Preview {
    TiltButton(isTiltEnabled: .constant(true), tiltSensitivity: .constant(0.5), lockTiltHorizontal: .constant(false), lockTiltVertical: .constant(false)) {
        // Placeholder for the onToggle closure
    }
    .padding()
    .background(Color.gray.opacity(0.2))
} 