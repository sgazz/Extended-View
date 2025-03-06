//
//  ContentView.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var settings = Settings.shared
    @StateObject private var imageLoader = ImageLoader.shared
    
    var body: some View {
        Group {
            if imageLoader.isImageLoaded {
                ImageEditorView()
                    .environmentObject(settings)
                    .environmentObject(imageLoader)
            } else {
                WelcomeScreen()
                    .environmentObject(settings)
                    .environmentObject(imageLoader)
            }
        }
    }
}

#Preview {
    ContentView()
}
