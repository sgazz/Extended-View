//
//  ImageLoader.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI
import PhotosUI
import UIKit

class ImageLoader: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedItem: PhotosPickerItem?
    @Published var isImageLoaded = false
    
    func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        item.loadTransferable(type: Data.self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                        self.isImageLoaded = true
                        // Користимо класу директно
                        let hapticManager = UIImpactFeedbackGenerator(style: .medium)
                        hapticManager.impactOccurred(intensity: 0.8)
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                    self.isImageLoaded = false
                }
            }
        }
    }
    
    static let shared = ImageLoader()
} 