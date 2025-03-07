//
//  RadialMenuView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI

/// Радијални мени који се појављује око прста када корисник дуго притисне екран
struct RadialMenuView: View {
    // Листа ставки менија
    let menuItems: [RadialMenuItem]
    
    // Позиција где се мени приказује (центар менија)
    @Binding var position: CGPoint
    
    // Да ли је мени приказан
    @Binding var isShowing: Bool
    
    // Пречник менија
    let diameter: CGFloat = 250
    
    // Пречник појединачне ставке менија
    let itemDiameter: CGFloat = 60
    
    // Хаптички фидбек
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            // Позадина која затамњује екран и омогућава затварање менија тапом изван
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
            }
            
            // Радијални мени
            ZStack {
                ForEach(Array(menuItems.enumerated()), id: \.element.id) { index, item in
                    menuItemView(for: item, at: index)
                }
            }
            .position(position)
            .opacity(isShowing ? 1 : 0)
            .scaleEffect(isShowing ? 1 : 0.5)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isShowing)
        }
    }
    
    /// Креира поглед за појединачну ставку менија
    private func menuItemView(for item: RadialMenuItem, at index: Int) -> some View {
        let angle = 2 * .pi / Double(menuItems.count) * Double(index)
        let radius = diameter / 2 - itemDiameter / 2
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        
        return Button(action: {
            hapticFeedback.impactOccurred()
            item.action()
            closeMenu()
        }) {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundColor(item.iconColor)
                
                Text(item.title)
                    .font(.caption)
                    .foregroundColor(item.titleColor)
                    .lineLimit(1)
            }
            .frame(width: itemDiameter, height: itemDiameter)
            .background(
                Circle()
                    .fill(item.backgroundColor)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: x, y: y)
    }
    
    /// Затвара мени
    private func closeMenu() {
        withAnimation {
            isShowing = false
        }
    }
}

#Preview {
    // Пример радијалног менија за преглед у Canvas-у
    let exampleItems = [
        RadialMenuItem(icon: "plus.magnifyingglass", title: "Зум", action: {}),
        RadialMenuItem(icon: "arrow.clockwise", title: "Ротација", action: {}),
        RadialMenuItem(icon: "move.3d", title: "Тилт", action: {}),
        RadialMenuItem(icon: "arrow.counterclockwise", title: "Ресет", action: {}),
        RadialMenuItem(icon: "photo", title: "Слика", action: {}),
        RadialMenuItem(icon: "gear", title: "Подешавања", action: {})
    ]
    
    return RadialMenuView(
        menuItems: exampleItems,
        position: .constant(CGPoint(x: 200, y: 300)),
        isShowing: .constant(true)
    )
} 