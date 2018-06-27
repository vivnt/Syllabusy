//
//  SYLBUploadViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 4/4/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import TesseractOCR
import Vision
import CropViewController
import AVFoundation

class SYLBUploadViewController: UIViewController, G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    // TODO: Make private vars
    // TODO: remove UI elements for testing
    lazy var image = UIImage(named: "sampleDates.jpg")?.g8_blackAndWhite()
    let imagePicker = UIImagePickerController()
    
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    var recognizedText = [String]()
    var dateFormats = ["MM dd", "MMM d", "MMM d yyyy", "MMM d yy", "d MMM yy", "d MMM yyyy", "d MMM", "yyyy MMM d", "yy MMM d", "d MMM yyyy", "d MMM yy", "MM dd yyyy"]
    lazy var syllabus = Syllabus()
    var instruction = "Upload Dates"
    
    // Currently taking sample images and setting it.
    // TODO: Move Image setting to Func
    // TODO: Grab user chosen images
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        instructionLabel.text = instruction
        imageView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        imageView.image = UIImage(named: "placeHolderImage.png")
        
        // TODO: Remove after testing
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // TODO: Change
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentification)
        textRequest.reportCharacterBoxes = false
        return textRequest
    }()
    
    func presentCropViewController(image: UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        imageView.image = image
        self.image = image
        imageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        dismiss(animated: true)
        startRecognition()
    }
    
    @objc func selectImage(tapGestureRecognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { action in
            let cameraMediaType = AVMediaType.video
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) && (cameraAuthorizationStatus == AVAuthorizationStatus.authorized || cameraAuthorizationStatus == AVAuthorizationStatus.notDetermined) {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                let alert  = UIAlertController(title: "Warning", message: "No camera found. Be sure to enable permissions for the camera in settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        alertController.addAction(takePhotoAction)
        
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { action in
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
        }
        alertController.addAction(choosePhotoAction)
        
        self.present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Couldn't load image")
        }
        self.imageView.image = image
        self.detectText(image: image)
    }
    
    func detectText(image: UIImage) {
        let ciImage = CIImage(image: image)
        let handler = VNImageRequestHandler(ciImage: ciImage!)
        let request: VNDetectTextRectanglesRequest =
            VNDetectTextRectanglesRequest(completionHandler: { [unowned self] (request, error) in
                if (error != nil) {
                    print("Got Error In Run Text Dectect Request :(")
                } else {
                    guard let results = request.results as? Array<VNTextObservation> else {
                        fatalError("Unexpected result type from VNDetectTextRectanglesRequest")
                    }
                    for textObservation in results {
                        let croppedImage = self.crop(image: image, rectangle: textObservation)
                        if let croppedImage = croppedImage {
                            self.recognizeText(image: croppedImage)
                        }
                    }
                }
            })
        request.reportCharacterBoxes = true
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        segue()
    }
    
    func startRecognition() {
        guard let uiImage = self.image?.g8_blackAndWhite()
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        
        self.imageView.image = uiImage
        // Create vision image request
        // TODO: Get image from handler instead of making a global value
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: UInt32(Int32(uiImage.imageOrientation.rawValue)))!)
        
        do {
            try handler.perform([self.textRectangleRequest])
        } catch {
            print(error)
        }
    }
    
    func handleTextIdentification (request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation]
            else { print("unexpected result type from VNTextObservation")
                return
        }
        guard observations.first != nil else {
            return
        }
        self.segue()
    }
    
    // TODO: Error check if no date is replied
    // TODO: End of the year case if it goes from dec 2018 to jan 2019
    // Handles text to date object
    func textToDate(text: String) -> Date? {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let currentDate = Date()
        let date = Date()
        
        // Insert Test case here
        // TODO: Add in confirmation for date type and if not then ask for date type
        //let testText = ["April 2 18", "April 03 2018", "Apr 4", "April 5", "02/06", "02/07/2018", "02/08/2018"]
        let removeCharacters = text.replacingOccurrences(of: "[\\/,-.]", with: " ", options: .regularExpression, range: nil)
        //let removeWhitespace = removeCharacters.replacingOccurrences(of: " ", with: "")
        
        for format in dateFormats {
            dateFormatter.dateFormat = format
            if var date = dateFormatter.date(from: removeCharacters) {
                var year = calendar.component(.year, from: date)
                let currentYear = calendar.component(.year, from: currentDate)
                
                // Accounts for no year in the date.
                if year < currentYear {
                    year = currentYear
                }
                
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                date = getDateObject(month: month, day: day, year: year, hour: 0, min: 0)
                return date
            }
            return nil
        }
        return date
    }
    
    // FEATURE: Move to next button instead ? / Done?
    
    // TODO: Add in error checking
    // TODO: Need to add in multiple line assignments
    func segue() {
        // Filters which are dates and which aren't
        var wasDateLast = false
        
        // Checks if first date has been added yet.
        var firstDate = false
        
        for text in self.recognizedText {
            if let date = textToDate(text: text) {
                syllabus.dates.append(date)
                wasDateLast = true
                firstDate = true
            }
            else if (firstDate == true) {
                if (wasDateLast == true) {
                    syllabus.assignments.append(text)
                } else {
                    let index = syllabus.assignments.count - 1
                    syllabus.assignments[index] = syllabus.assignments[index] + " " + text
                }
                wasDateLast = false
            }
        }
        
        // To make sure dates are in order
        syllabus.dates = syllabus.dates.sorted(by: { $0.compare($1) == .orderedAscending })
        
        // Creates a new VC and sends over syllabus to new VC
        // Also checks if the number of assigments and dates are the same
        
        if syllabus.assignments.count != syllabus.assignments.count {
            // When it has the wrong number of assignments or dates
            let reviewVC = UIStoryboard(name: "SYLBUpload", bundle: nil).instantiateViewController(withIdentifier: "reviewVC") as! SYLBReviewViewController
            reviewVC.syllabus = syllabus
            
            self.navigationController?.pushViewController(reviewVC, animated: true)
        } else {
            // When it is the correct number of assignments to dates
            let tableViewVC = UIStoryboard(name: "SYLBUpload", bundle: nil).instantiateViewController(withIdentifier: "tableViewVC") as! SYLBTableViewViewController
            tableViewVC.syllabus = syllabus
            self.navigationController?.pushViewController(tableViewVC, animated: true)
        }
    }
    
    // Crops the image so Tesseract can OCR per section
    func crop(image: UIImage, rectangle: VNTextObservation) -> UIImage? {
        var t: CGAffineTransform = CGAffineTransform.identity;
        t = t.scaledBy(x: image.size.width, y: -image.size.height);
        t = t.translatedBy(x: 0, y: -1 );
        let x = rectangle.boundingBox.applying(t).origin.x
        let y = rectangle.boundingBox.applying(t).origin.y
        let width = rectangle.boundingBox.applying(t).width
        let height = rectangle.boundingBox.applying(t).height
        let fromRect = CGRect(x: x, y: y, width: width, height: height)
        let drawImage = image.cgImage!.cropping(to: fromRect)
        if let drawImage = drawImage {
            let uiImage = UIImage(cgImage: drawImage)
            return uiImage
        }
        return nil
    }
    
    // Gets string using Tesseract
    // Seperate for date and assignments?
    func recognizeText(image: UIImage) {
        let tesseract:G8Tesseract = G8Tesseract(language:"eng")
        tesseract.charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\\/-:@"
        tesseract.delegate = self
        tesseract.image = image
        tesseract.recognize()
        
        let text = String(tesseract.recognizedText.filter{ !"\n".contains($0) })
        recognizedText.append(text)
    }
    
    // Gets the date object from inputted text
    // TODO: Handle no hour and min
    func getDateObject(month: Int, day: Int, year: Int, hour: Int = 0, min: Int = 0) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = min
        // if min and hour are equal to zero, make it all day
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        
        return date!
    }
    
    // Convert Vision Frame to UIKit Frame
    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }
}
