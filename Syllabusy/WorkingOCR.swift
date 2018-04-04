//
//  ViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 1/31/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

// Used for testing images and troubleshooting

import UIKit
import TesseractOCR
import Vision

class WorkingOCR: UIViewController, G8TesseractDelegate {
    
    // UI elements for testing
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var origImageView: UIImageView!
    @IBOutlet weak var boxedImageView: UIImageView!
    let type = OCRType.date
    let image = UIImage(named: "sampleAssignments.jpg")?.g8_blackAndWhite()
    
    // To Keep
    // 2018 first
    var recognizedText = [String]()
    var dateFormats = ["MMMd", "MMMdyyyy", "MMMdyy", "dMMMyy", "dMMMyyyy",  "dMMM", "yyyyMMMd", "yyMMMd", "dMMMyyyy", "dMMMyy", "MMddyyyy"]
    lazy var syllabus = Syllabus()
    
    
    // TODO: Change
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
        guard let uiImage = UIImage(named: "sampleAssignments.jpg")?.g8_blackAndWhite()
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        
        
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
//            for text in self.recognizedText {
//                print(text)
//            }
            self.segueToEvents()
        }
    }
    
    // TODO: Error check if no date is replied
    // TODO: End of the year case if it goes from dec 2018 to jan 2019
    // Handles text to date object
    func textToDate(text: String) -> Date {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let currentDate = Date()
        let date = Date()
        
        // Insert Test case here
        // TODO: Add in confirmation for date type and if not then ask for date type
        //let testText = ["April 2 18", "April 03 2018", "Apr 4", "April 5", "02/06", "02/07/2018", "02/08/2018"]
        let removeCharacters = text.replacingOccurrences(of: "[\\/,-.]", with: "", options: .regularExpression, range: nil)
        let removeWhitespace = removeCharacters.replacingOccurrences(of: " ", with: "")
        
        for format in dateFormats {
            dateFormatter.dateFormat = format
            if var date = dateFormatter.date(from: removeWhitespace) {
                var year = calendar.component(.year, from: date)
                let currentYear = calendar.component(.year, from: currentDate)

                // Accounts for no year in the date.
                if year < currentYear {
                    year = currentYear
                }
                
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                date = getDateObject(month: month, day: day, year: year, hour: 0, min: 0)
                print(date)
                return date
            }
        }
        return date
    }
    
    func segueToEvents() {
        print(recognizedText)
        // if type == .date {
        var dateObjects = [Date]()
        for text in self.recognizedText {
            dateObjects.append(textToDate(text: text))
        }
//        let storyBoard: UIStoryboard = UIStoryboard(name: "DetailedEvent", bundle: nil)
//        let detailedEventVC = storyBoard.instantiateInitialViewController() as! DetailedEventViewController
//
//        // Sends over event details
//        detailedEventVC.event = event
//
//        mainNavigationController.pushViewController(detailedEventVC, animated: true)
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
