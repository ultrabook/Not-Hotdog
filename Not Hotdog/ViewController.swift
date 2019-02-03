//
//  ViewController.swift
//  Not Hotdog
//
//  Created by Randy Hsu on 2019-02-02.
//  Copyright © 2019 DeveloperRandy. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var displayImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let redColor = UIColor(red: Constants.Red.Red, green: Constants.Red.Green, blue: Constants.Red.Blue, alpha: Constants.Red.Alpha)
    let greenColor = UIColor(red: Constants.Green.Red, green: Constants.Green.Green, blue: Constants.Green.Blue, alpha: Constants.Green.Alpha)
    
    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.imagePicker.allowsEditing = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.displayImageView.image == nil {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image Picker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            print("Unable to load image")
            return
        }
        
        self.displayImageView.image = image
        
        if let ciimage = CIImage(image: image) {
            identifyItemFrom(image: ciimage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -
    
    func identifyItemFrom(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            print("Unable to load model")
            return
        }
        
        let MLRequest = VNCoreMLRequest(model: model) { (request, error) in
            if let classifications = request.results as? [VNClassificationObservation],
                let mostCondidentClassification = classifications.first {
                
                if mostCondidentClassification.identifier.contains("hotdog") {
                    self.displayLabel.backgroundColor = self.greenColor
                    self.view.backgroundColor = self.greenColor
                    self.displayLabel.text = "Hotdog"
                } else {
                    self.displayLabel.backgroundColor = self.redColor
                    self.view.backgroundColor = self.redColor
                    self.displayLabel.text = "Not Hotdog"
                    
                }
            }
        }
        
        let requestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            try requestHandler.perform([MLRequest])
        } catch  {
            print(error)
        }
    }

    @IBAction func cameraButtonPressed(_ sender: Any) { 
        self.present(self.imagePicker, animated: true, completion: nil)
    }
}

