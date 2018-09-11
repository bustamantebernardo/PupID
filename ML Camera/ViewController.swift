//
//  ViewController.swift
//  ML Camera
//
//  Created by Bernardo Bustamante on 3/28/18.
//  Copyright © 2018 Bernardo Bustamante. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var idLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    //Camera Start Up
    let captureSession = AVCaptureSession()
    //Crop top & bottom preset
    //captureSession.sessionPreset = .photo
        
    //Set captureDevice to default video camera
    guard let captureDevice =
        AVCaptureDevice.default(for: .video) else {return}
        
    //Assign captureDevice as our input
    guard let input = try? AVCaptureDeviceInput(device:
        captureDevice) else {return}
        
    captureSession.addInput(input)
    captureSession.startRunning()
        
    let previewLayer = AVCaptureVideoPreviewLayer(session:
            captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue:
            DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else
            {return}
        
        //PupID Model
        guard let model = try? VNCoreMLModel(for: PupIDModel().model) else
            {return}
        
        let request = VNCoreMLRequest(model: model)
            { (finishedReq, err) in
            
            //check error
            
            //print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else
                {return}
            
            guard let firstObservation = results.first else
                {return}
            //Print Identifier & Confidence level in console
            print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                if firstObservation.confidence * 100 >= 70 {
                    self.idLabel.text = firstObservation.identifier
                }
            }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

