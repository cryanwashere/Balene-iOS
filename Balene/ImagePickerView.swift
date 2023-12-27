//
//  ImagePickerView.swift
//  Visual Search
//
//  Created by CJ Ryan on 9/21/22.
//

import UIKit
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    

    @Binding var isPickerShowing: Bool
        
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parent: ImagePickerView
    
    init(_ picker: ImagePickerView) {
        self.parent = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("selected image from photo library...")
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async{
                //print("hello")
                APIClient.shared.makeAPIrequest(uiimage: image)
            }
        }
        self.parent.isPickerShowing = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //runs when the image picker was cancelled
        self.parent.isPickerShowing = false
    }
}

