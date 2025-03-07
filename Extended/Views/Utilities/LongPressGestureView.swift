//
//  LongPressGestureView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI

/// Модификатор погледа који додаје гест дугог притиска за активирање радијалног менија
struct LongPressGestureModifier: ViewModifier {
    // Позиција где је корисник притиснуо екран
    @Binding var menuPosition: CGPoint
    
    // Да ли је мени приказан
    @Binding var isMenuShowing: Bool
    
    // Минимално трајање притиска за активирање менија (у секундама)
    let minimumDuration: Double = 0.5
    
    // Хаптички фидбек
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    func body(content: Content) -> some View {
        content
            .gesture(
                LongPressGesture(minimumDuration: minimumDuration)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onChanged { value in
                        switch value {
                        case .first(true):
                            // Дуги притисак је почео, али још није завршен
                            break
                        case .second(true, let drag):
                            // Дуги притисак је завршен, активирамо мени
                            if let drag = drag {
                                menuPosition = drag.location
                                if !isMenuShowing {
                                    hapticFeedback.impactOccurred(intensity: 1.0)
                                    isMenuShowing = true
                                }
                            }
                        default:
                            break
                        }
                    }
            )
    }
}

/// Екстензија за View која додаје функцију за лако додавање гестa дугог притиска
extension View {
    func withLongPressGesture(menuPosition: Binding<CGPoint>, isMenuShowing: Binding<Bool>) -> some View {
        self.modifier(LongPressGestureModifier(menuPosition: menuPosition, isMenuShowing: isMenuShowing))
    }
} 