//
//  ScanViewController.swift
//  MediScan
//
//  Created by Tony Wu on 4/14/18.
//  Copyright © 2018 Erlun Lian. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import Photos
import TesseractOCR

class ScanViewController: UIViewController {

    var drug_list = Drugs()
    @IBOutlet weak var drug: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var count = 0
    var true_false = true
    var photoOutput: AVCapturePhotoOutput?
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    
    // Setting up Camera
    func startLiveVideo() {
        if(count == 0) {
            //1
            session.sessionPreset = AVCaptureSession.Preset.photo
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            //2
            let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
            let deviceOutput = AVCaptureVideoDataOutput()
            self.photoOutput = AVCapturePhotoOutput()
            deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
            session.addInput(deviceInput)
            session.addOutput(deviceOutput)
            session.addOutput(photoOutput!)
            
            //3
            let imageLayer = AVCaptureVideoPreviewLayer(session: session)
            imageLayer.frame = imageView.bounds
            imageLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            imageView.layer.addSublayer(imageLayer)
            count = 1
        }
        
        session.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startLiveVideo()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    // Vision Stuff
    
    func startTextDetection() {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true_false
        self.requests = [textRequest]
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
        
        let result = observations.map({$0 as? VNTextObservation})
        
        DispatchQueue.main.async() {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            for region in result {
                guard let rg = region else {
                    continue
                }
                
                self.highlightWord(box: rg)
                
                /*
                if let boxes = region?.characterBoxes {
                    for characterBox in boxes {
                        self.highlightLetters(box: characterBox)
                    }
                }
                */
            }
        }
    }
    
    func highlightWord(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else {
            return
        }
        
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
        
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
        
        let xCord = maxX * imageView.frame.size.width
        let yCord = (1 - minY) * imageView.frame.size.height
        let width = (minX - maxX) * imageView.frame.size.width
        let height = (minY - maxY) * imageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(outline)
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
            let acquired_text: String = tesseract.recognizedText
            let trimmed = acquired_text.trimmingCharacters(in: .whitespacesAndNewlines)
            print(trimmed.uppercased())
            // For some reason cannot print database side effects
            drug.text = trimmed
        }
        // 7
    }
    
    @IBAction func pressScan(_ sender: UIButton) {
        true_false = false
        startTextDetection()
    }
    @IBAction func pressButton(_ sender: UIButton) {
        true_false = true
        startTextDetection()
    }
    
    @IBAction func capture_image(_ sender: UIButton) {
        func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
            let session = self.session
            if (session.isRunning) {}
                else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
            
            let settings = AVCapturePhotoSettings()
            
            self.photoOutput?.capturePhoto(with: settings, delegate: self)
            self.photoCaptureCompletionBlock = completion
        }
        captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            let selectedPhoto = image as UIImage
            let scaledImage = selectedPhoto.scaleImage(640)
            self.performImageRecognition(scaledImage!)
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    /*
    func highlightLetters(box: VNRectangleObservation) {
        let xCord = box.topLeft.x * imageView.frame.size.width
        let yCord = (1 - box.topLeft.y) * imageView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        imageView.layer.addSublayer(outline)
    }
 
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTextDetection()
        // Do any additional setup after loading the view.
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        // Was an error before. I manually fixed
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}

extension ScanViewController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                            resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            
            self.photoCaptureCompletionBlock?(image, nil)
        }
            
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

