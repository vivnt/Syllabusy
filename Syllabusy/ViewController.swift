//
//  ViewController.swift
//  Syllabusy
//
//  Created by Vivian Tran on 1/31/18.
//  Copyright © 2018 Vivian Tran. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tesseract:G8Tesseract = G8Tesseract(language:"eng")
        //tesseract.language = "eng+ita"
        tesseract.delegate = self
        tesseract.image = UIImage(named: "image_sample.jpg")?.g8_blackAndWhite()
        tesseract.recognize()
        
        textView.text = tesseract.recognizedText
        print(tesseract.recognizedText)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }
}

