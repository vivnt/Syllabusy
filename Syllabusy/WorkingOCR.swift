//
//  ViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 1/31/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import TesseractOCR
import Vision

enum OCRType {
    case date
    case assignment
}

class WorkingOCR: UIViewController, G8TesseractDelegate {
    
    // UI elements for testing
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var origImageView: UIImageView!
    @IBOutlet weak var boxedImageView: UIImageView!
    let type = OCRType.date
    let image = UIImage(named: "sampleDates.jpg")?.g8_blackAndWhite()
    var imageToAnalyis : CIImage?
    
    // To Keep
    var recognizedText = [String]()
    var dateObjects = [Date]()
    
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentification)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
    
    // Currently taking sample images and setting it.
    // TODO: Move Image setting to Func
    // TODO: Grab user chosen images
    override func viewDidLoad() {
        super.viewDidLoad()
        origImageView.image = image
        boxedImageView.image = image
        guard let uiImage = UIImage(named: "sampleDates.jpg")?.g8_blackAndWhite()
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        
        imageToAnalyis = ciImage.oriented(forExifOrientation: Int32(uiImage.imageOrientation.rawValue))
        
        // Create vision image request
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: UInt32(Int32(uiImage.imageOrientation.rawValue)))!)
        
        do {
            try handler.perform([self.textRectangleRequest])
        } catch {
            print(error)
        }
    }
    
    // TODO: Change
    // Add why crop?
    func handleTextIdentification (request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation]
            else { print("unexpected result type from VNTextObservation")
                return
        }
        guard observations.first != nil else {
            return
        }
        DispatchQueue.main.async {
            // Uses VisionML to pinpoint sentences
            for box in observations {
                let view = self.CreateBoxView(withColor: UIColor.red)
                // Shrinks box to boundingbox
                view.frame = self.transformRect(fromRect: box.boundingBox, toViewRect: self.boxedImageView)
                self.boxedImageView.addSubview(view)
                let croppedImage = self.crop(image: (self.image)!, rectangle: box)
                self.recognizeText(image: croppedImage!)
//                guard let boxes = box.characterBoxes else {
//                    continue
//                }
                // TODO: Character boxes
//                for characterBox in boxes {
//                    let view = self.CreateBoxView(withColor: UIColor.green)
//                    // Shrinks box to boundingbox
//                    view.frame = self.transformRect(fromRect: characterBox.boundingBox, toViewRect: self.boxedImageView)
//                    self.boxedImageView.addSubview(view)
//                    let croppedImage = self.crop(image: (self.image)!, rectangle: characterBox)
//                    self.recognizeText(image: croppedImage!)
//                }
            }
            // TODO: Remove after testing purposes
            for text in self.recognizedText {
                self.textToDate(text: text)
            }
        }
        
    }
    
    // Handles text to date object
    func textToDate(text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMd"
        let trimmedString = text.replacingOccurrences(of: " ", with: "")
        print(trimmedString)
        if let date = dateFormatter.date(from: trimmedString) {
            print(date)
        } else {
            // Invalid date
            print("Invalid")
        }
        // for loop of dateformatters strings
        // if let _ = dateFormatterGet.date(from: dateString)
        // break
        
        //
        
        
//         {
//            //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
//            return true
//        } else {
        let date = getDateObject(month: 02, day: 27, year: 2018, hour: 17, min: 0)
        return date
    }
    
    func segueToEvents() {
        print("segueToEvents")
       // if type == .date {
            var dateObjects = [Date]()
            for text in self.recognizedText {
                dateObjects.append(textToDate(text: text))
            }
            // Send over dateObjects
      //  } else {
            // Send over recognizedText
      //  }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Events", bundle: nil)
//        let eventsVC = storyBoard.instantiateViewController(withIdentifier: "EventsViewController")
//
//        addChildViewController(eventsVC)
//        view.addSubview(eventsVC.view)
//        eventsVC.didMove(toParentViewController: self)
//
//        let height = view.frame.height
//        let width  = view.frame.width
//        eventsVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
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
        tesseract.charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\\/"
        tesseract.delegate = self
        tesseract.image = image
        tesseract.recognize()
        
        textView.text = tesseract.recognizedText.lowercased()
        let text = String(tesseract.recognizedText.filter{ !"\n".contains($0) })
        recognizedText.append(text)
    }
    
    // Gets the date object from inputted text
    // Handle no hour and min
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
    
    // Creates red rectangle around text
    // TODO: Remove after done
    func CreateBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }
}
