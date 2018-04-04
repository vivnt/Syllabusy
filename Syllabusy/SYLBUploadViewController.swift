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

enum OCRType {
    case date
    case assignment
}

class SYLBUploadViewController: UIViewController, G8TesseractDelegate {
    
    // TODO: Make private vars
    // UI elements for testing
    var image = UIImage(named: "sampleDates.jpg")?.g8_blackAndWhite()
    
    var recognizedText = [String]()
    var dateFormats = ["MMMd", "MMMdyyyy", "MMMdyy", "dMMMyy", "dMMMyyyy",  "dMMM", "yyyyMMMd", "yyMMMd", "dMMMyyyy", "dMMMyy", "MMddyyyy"]
    lazy var syllabus = Syllabus()
    var type = OCRType.date
    
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
        guard let uiImage = self.image?.g8_blackAndWhite()
            else { fatalError("no image from image picker") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("can't create CIImage from UIImage") }
        
        // Create vision image request
        // TODO: Get image from handler instead of making a global value
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: UInt32(Int32(uiImage.imageOrientation.rawValue)))!)
        
        do {
            try handler.perform([self.textRectangleRequest])
        } catch {
            print(error)
        }
    }
    
    // TODO: Change
    func handleTextIdentification (request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation]
            else { print("unexpected result type from VNTextObservation")
                return
        }
        guard observations.first != nil else {
            return
        }
        DispatchQueue.main.async {
            // Uses VisionML to pinpoint sections
            for box in observations {
                let croppedImage = self.crop(image: (self.image)!, rectangle: box)
                self.recognizeText(image: croppedImage!)
            }
            self.segue()
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
                return date
            }
        }
        return date
    }
    
    // TODO: Move to next button instead ?
    func segue() {
        if type == .date {
            var dateObjects = [Date]()
            for text in self.recognizedText {
                dateObjects.append(textToDate(text: text))
            }
            print(dateObjects)
            let assignmentsVC = UIStoryboard(name: "SYLBUpload", bundle: nil).instantiateViewController(withIdentifier: "assignmentsVC") as! SYLBUploadViewController
            assignmentsVC.type = .assignment
            
            //TODO: remove after testing
            assignmentsVC.image = UIImage(named: "sampleAssignments.jpg")?.g8_blackAndWhite()
            
            self.navigationController?.pushViewController(assignmentsVC, animated: true)
        } else {
            //TODO: remove after testing
            print(recognizedText)
            
            let tableViewVC = UIStoryboard(name: "SYLBUpload", bundle: nil).instantiateViewController(withIdentifier: "tableViewVC") as! SYLBUploadViewController
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
        tesseract.charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\\/"
        tesseract.delegate = self
        tesseract.image = image
        tesseract.recognize()
        
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
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
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
