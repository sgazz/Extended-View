//
//  Settings.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @Published var isLeftHandMode: Bool = false
    @Published var persistentIndicators: Bool = true
    @Published var isAngleSnappingEnabled: Bool = true
    @Published var snapAngle: Double = 45.0
    @Published var maxZoomScale: Double = 5.0
    @Published var minZoomScale: Double = 0.5
    
    // Тилт подешавања
    @Published var isTiltEnabled: Bool = false
    @Published var tiltSensitivity: Double = 0.5
    @Published var lockTiltHorizontal: Bool = false
    @Published var lockTiltVertical: Bool = false
    
    static let shared = Settings()
    
    private init() {}
} 