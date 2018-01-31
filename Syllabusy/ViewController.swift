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

class ViewController: UIViewController, G8TesseractDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var origImageView: UIImageView!
    @IBOutlet weak var boxedImageView: UIImageView!
    let image = UIImage(named: "image_sample.jpg")?.g8_blackAndWhite()
    
    
    
    var imageToAnalyis : CIImage?
    
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentifiaction)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        origImageView.image = image
        boxedImageView.image = image
        guard let uiImage = UIImage(named: "image_sample.jpg")?.g8_blackAndWhite()
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
        //self.recognizeText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func CreateBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
    
    //Convert Vision Frame to UIKit Frame
    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    
    func handleTextIdentifiaction (request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNTextObservation]
            else { print("unexpected result type from VNTextObservation")
                return
        }
        guard observations.first != nil else {
            return
        }
        DispatchQueue.main.async {
            self.boxedImageView.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for box in observations {
                guard let chars = box.characterBoxes else {
                    print("no char values found")
                    return
                }
                let view = self.CreateBoxView(withColor: UIColor.green)
                view.frame = self.transformRect(fromRect: box.boundingBox, toViewRect: self.boxedImageView)
                self.boxedImageView.image = self.origImageView.image
                self.boxedImageView.addSubview(view)
                
                for char in chars
                {
                    let view = self.CreateBoxView(withColor: UIColor.green)
                    view.frame = self.transformRect(fromRect: char.boundingBox, toViewRect: self.boxedImageView)
                    self.boxedImageView.image = self.origImageView.image
                    self.boxedImageView.addSubview(view)
                }
            }
        }
        
    }
    
    func recognizeText() {
        var tesseract:G8Tesseract = G8Tesseract(language:"eng")
        tesseract.delegate = self
        tesseract.image = image
        tesseract.recognize()
        
        textView.text = tesseract.recognizedText
        print(tesseract.recognizedText)
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }
}

