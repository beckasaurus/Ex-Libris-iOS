//
//  BarcodeScannerViewController.swift
//  Ex Libris
//
//  Created by Becky Henderson on 2/8/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit
import AVFoundation

let searchForBarcodeSegue = "searchForBarcodeSegue"

/**
Thanks to http://www.appcoda.com/simple-barcode-reader-app-swift/
*/

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	var session: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == searchForBarcodeSegue {
			guard let searchingVC = segue.destination as? SearchingViewController
				else {return}
			
			guard let barcode = sender as? String
				else {return}
			
			searchingVC.barcodeToSearch = barcode
		}
	}
	
	func barcodeDetected(code: String) {
		
		// Let the user know we've found something.
		let alert = UIAlertController(title: "Found a Barcode!", message: "Searching for \(code)?", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
			
			// Remove the spaces.
			let trimmedCode = code.trimmingCharacters(in: CharacterSet.whitespaces)
			
			// EAN or UPC?
			// Check for added "0" at beginning of code.
			
			let trimmedCodeString = "\(trimmedCode)"
			var trimmedCodeNoZero: String
			
			var barcode = trimmedCodeString
			
			if trimmedCodeString.hasPrefix("0") && trimmedCodeString.characters.count > 1 {
				trimmedCodeNoZero = String(trimmedCodeString.characters.dropFirst())
				
				// Send the doctored UPC to DataService.searchAPI()
				barcode = trimmedCodeNoZero
			}
			
			self.performSegue(withIdentifier: searchForBarcodeSegue,
			                  sender: barcode)
			
		}))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		session = AVCaptureSession()
		
		let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		
		let videoInput: AVCaptureDeviceInput?
		
		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}
		
		if (session.canAddInput(videoInput)) {
			session.addInput(videoInput)
		} else {
			failureAlert()
		}
		
		let metadataOutput = AVCaptureMetadataOutput()
		
		if (session.canAddOutput(metadataOutput)) {
			session.addOutput(metadataOutput)
			metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code]
		} else {
			failureAlert()
		}
		
		previewLayer = AVCaptureVideoPreviewLayer(session: session);
		previewLayer.frame = view.layer.bounds;
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		view.layer.addSublayer(previewLayer);
		
		session.startRunning()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		if (session?.isRunning == false) {
			session.startRunning()
		}
	}
 
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (session?.isRunning == true) {
			session.stopRunning()
		}
	}
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		if let barcodeData = metadataObjects.first {
			let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
			if let readableCode = barcodeReadable {
				barcodeDetected(code: readableCode.stringValue);
			}
			
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			
			session.stopRunning()
		}
	}
	
	func failureAlert() {
		let alert = UIAlertController(title: "Cannot add books by barcode.", message: "There was an issue finding a camera to use for scanning.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
		session = nil
	}
}
