//
//  TaskDetailViewController.swift
//  lab-task-squirrel
//
//  Created by Charlie Hieger on 11/15/22.
//

import UIKit
import MapKit
import PhotosUI
import SwiftUI

// TODO: Import PhotosUI

class TaskDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet private weak var completedImageView: UIImageView!
    @IBOutlet private weak var completedLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var attachPhotoButton: UIButton!
    
    
    // MapView outlet
    @IBOutlet private weak var mapView: MKMapView!
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Register custom annotation view
        // Register custom annotation view
        mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)
        // TODO: Set mapView delegate
        // Set mapView delegate
        mapView.delegate = self
        // UI Candy
        mapView.layer.cornerRadius = 12
        
        // Add tap gesture recognizer to mapView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapView.addGestureRecognizer(tapGesture)
        
        updateUI()
        updateMapView()
    }
    
    /// Configure UI for the given task
    private func updateUI() {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        
        let completedImage = UIImage(systemName: task.isComplete ? "circle.inset.filled" : "circle")
        
        // calling `withRenderingMode(.alwaysTemplate)` on an image allows for coloring the image via it's `tintColor` property.
        completedImageView.image = completedImage?.withRenderingMode(.alwaysTemplate)
        completedLabel.text = task.isComplete ? "Complete" : "Incomplete"
        
        let color: UIColor = task.isComplete ? .systemBlue : .tertiaryLabel
        completedImageView.tintColor = color
        completedLabel.textColor = color
        
        mapView.isHidden = !task.isComplete
        attachPhotoButton.isHidden = task.isComplete
        
    }
    
    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        // TODO: Check and/or request photo library access authorization.
        let alertController = UIAlertController(title: "Attach Photo", message: nil, preferredStyle: .actionSheet)
        
        let choosePhotoAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(choosePhotoAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Source type \(sourceType) is not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func mapViewTapped() {
        // Handle tap on mapView
        let alertController = UIAlertController(title: "Attach Photo", message: nil, preferredStyle: .actionSheet)
        
        let choosePhotoAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(choosePhotoAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateMapView() {
        // TODO: Set map viewing region and scale
        
        // Make sure the task has image location.
        guard let imageLocation = task.imageLocation else { return }
        
        // Get the coordinate from the image location. This is the latitude / longitude of the location.
        // https://developer.apple.com/documentation/mapkit/mkmapview
        let coordinate = imageLocation.coordinate
        
        // Set the map view's region based on the coordinate of the image.
        // The span represents the maps's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        // TODO: Add annotation to map view
        
        // Add an annotation to the map view based on image location.
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

// TODO: Conform to PHPickerViewControllerDelegate + implement required method(s)

// TODO: Conform to MKMapKitDelegate + implement mapView(_:viewFor:) delegate method.

// Helper methods to present various alerts
extension TaskDetailViewController {
    @objc func handleMapAnnotationTap(_ sender: UITapGestureRecognizer) {
        // Present photo picker to allow selecting a new photo
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}

extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Check if the selected media is an image
        guard let selectedImage = info[.originalImage] as? UIImage else {
            showAlert(for: NSError(domain: "TaskDetailViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve image"]))
            return
        }
        
        // Set the selected image to the completed image view
        completedImageView.image = selectedImage
        
        // Get the selected image asset
        if let result = info[.phAsset] as? PHAsset {
            // Get image location
            guard let location = result.location else {
                showAlert(for: NSError(domain: "TaskDetailViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve location"]))
                return
            }
            
            print("📍 Image location coordinate: \(location.coordinate)")
            
            // Load a UIImage from the asset
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(for: result, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFill, options: options) { [weak self] image, info in
                guard let image = image else { return }
                
                // UI updates should be done on the main thread
                DispatchQueue.main.async {
                    // Set the picked image and location on the task
                    self?.task.set(image, with: location)
                    
                    // Update the UI since we've updated the task
                    self?.updateUI()
                    
                    // Update the map view since we now have an image and location
                    self?.updateMapView()
                }
            }
        } else {
            // If there is no PHAsset provided, only set the selected image to the completed image view
            DispatchQueue.main.async {
                self.setNewImage(selectedImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func setNewImage(_ image: UIImage) {
        task.set(image, with: CLLocation(latitude: 0, longitude: 0)) // Provide a default location or any other desired logic
        updateUI()
        updateMapView() // You may need to adjust this depending on how updateMapView() works
    }
}



extension TaskDetailViewController: MKMapViewDelegate {
    // Implement mapView(_:viewFor:) delegate method.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Dequeue the annotation view for the specified reuse identifier and annotation.
        // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
        // 💡 This is very similar to how we get and prepare cells for use in table views.
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
            fatalError("Unable to dequeue TaskAnnotationView")
        }
        
        // Configure the annotation view, passing in the task's image.
        annotationView.configure(with: task.image)
        return annotationView
    }
}
