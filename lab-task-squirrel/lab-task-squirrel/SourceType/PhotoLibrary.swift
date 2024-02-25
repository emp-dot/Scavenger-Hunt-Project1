//
//  PhotoLibrary.swift
//  lab-task-squirrel
//
//  Created by Gideon Boateng on 2/25/24.
//

import SwiftUI
import PhotosUI

struct PhotoLibrary: UIViewControllerRepresentable {
    
    
    var handlePickedImage: (UIImage?) -> Void
    
    static var isAvailable: Bool {
        return true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Iterate over each PHPickerResult and handle the itemProvider
            for result in results {
                let itemProvider = result.itemProvider
                
                // Load UIImage from the itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        if let image = image as? UIImage {
                            // Handle the picked image
                            self?.handlePickedImage(image)
                        } else if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            // Handle the error
                        } else {
                            // No image found
                            self?.handlePickedImage(nil)
                        }
                    }
                } else {
                    print("Cannot load UIImage from the itemProvider")
                    // Handle the case where UIImage cannot be loaded from the itemProvider
                    // You may want to show an error message or take appropriate action
                }
            }
        }
        
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
    }

    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
}


