//
//  ViewController.swift
//  CameraRecognization
//
//  Created by Abdelrahman Shehab on 4/12/20.
//  Copyright © 2020 Abdelrahman Shehab. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var objectLabel: UILabel!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        blurView.layer.cornerRadius = 10
        blurView.clipsToBounds = true

    }
    //MARK: - Camera Handler
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose your source that you want to pick up your photo", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Photo Liberary", style: .default, handler: { (action: UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }

    //MARK: - Detector Method

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading Core Model Failed!")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed To Process Image!")
            }
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier)
            DispatchQueue.main.async {

                self.objectLabel.text = "\(firstObservation.identifier)"
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch  {
            print(error)
        }
    }

}

//MARK: - Image Picker Controller

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let userImagePicked = info[.originalImage] as? UIImage {

            imageView.image = userImagePicked

            guard let ciimage = CIImage(image: userImagePicked) else {
                fatalError("Could Not Convert UIImage into CIImage!")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
