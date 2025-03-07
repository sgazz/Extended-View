//
//  RadialMenuItem.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI

/// Модел који представља једну ставку у радијалном менију
struct RadialMenuItem: Identifiable {
    let id = UUID()
    let icon: String          // SF Symbol име иконе
    let title: String         // Назив ставке
    let action: () -> Void    // Акција која се извршава када се ставка изабере
    
    // Опционе особине за прилагођавање изгледа
    var backgroundColor: Color = Color.black.opacity(0.7)
    var iconColor: Color = .white
    var titleColor: Color = .white
} 