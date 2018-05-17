//
//  SearchViewController.swift
//  MediScan
//
//  Created by Tony Wu on 4/14/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit
import TesseractOCR
import Foundation

class SearchViewController: UIViewController {

    @IBOutlet weak var result: UILabel!
    var drug_list = Drugs()
    @IBOutlet weak var inputt: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var side_effect: UIButton!
    @IBOutlet weak var main_usage: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return (true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func take_photo(_ sender: UIButton) {
        presentImagePicker()
        view.endEditing(true)
    }
    
    func performImageRecognition(_ image: UIImage) {
        // 1
        if let tesseract = G8Tesseract(language: "eng") {
            // 2
            tesseract.engineMode = .tesseractCubeCombined
            // 3
            tesseract.pageSegmentationMode = .auto
            // 4
            tesseract.image = image.g8_blackAndWhite()
            // 5
            tesseract.recognize()
            // 6
            inputt.text = tesseract.recognizedText
        }
        // 7
        activityIndicator.stopAnimating()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drug_list.set_up_dictionary()
        side_effect.layer.cornerRadius = 10
        main_usage.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func side_effects(_ sender: UIButton) {
        let title = sender.title(for: .normal)!
        let user_input: String = inputt.text!
        let trimmed = user_input.trimmingCharacters(in: .whitespacesAndNewlines)
        print(user_input)
        let title2: String
        if(drug_list.drug_in_database(name: trimmed.uppercased())) {
            if(title == "Side Effects") {
                title2=drug_list.get_side_effects(name: trimmed.uppercased())
            }
            else {
                title2 = drug_list.get_main_usages(name: trimmed.uppercased())
            }
            result.text = title2
        }
        else {
            result.text = "Drug not found in database"
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UINavigationControllerDelegate {
}

// Set up taking a picture
// MARK: - UIImagePickerControllerDelegate
extension SearchViewController: UIImagePickerControllerDelegate {
    func presentImagePicker() {
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 1
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 2
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        // 3
        present(imagePickerActionSheet, animated: true)
    }
    
    // 1
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // 2
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage(640) {
            // 3
            activityIndicator.startAnimating()
            // 4
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
}

// MARK: - UIImage extension
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

