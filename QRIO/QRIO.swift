//
//  QRIO.swift
//  Nodes
//
//  Created by Chris on 30/06/16.
//  Copyright © 2016 Nodes. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

open class QRInput: NSObject, AVCaptureMetadataOutputObjectsDelegate {
	fileprivate var session: AVCaptureSession?
	fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
	
	open var imageScanCompletionBlock: ((_ string: String) -> ())?
	
	
	open func scanForQRImage(previewIn previewContainer: UIView? = nil, rectOfInterest: CGRect? = nil, completion: @escaping ((_ string: String) -> ())) {
		session = AVCaptureSession()
		let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		
		do {
			let input = try AVCaptureDeviceInput(device: device)
			session?.addInput(input)
		} catch {
			// Trying to run in simulator
			return
		}
		
		let output = AVCaptureMetadataOutput()
		output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		session?.addOutput(output)
		output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
		
		imageScanCompletionBlock = completion
		
		if let previewContainer = previewContainer {
			previewLayer = AVCaptureVideoPreviewLayer(session: session)
			previewContainer.layer.addSublayer(previewLayer!)
			previewLayer!.frame = previewContainer.bounds
			previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
			
		}
		DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
			self?.session?.startRunning()
		}
		
		if let rectOfInterest = rectOfInterest, let previewLayer = previewLayer {
			output.rectOfInterest = previewLayer.metadataOutputRectOfInterest(for: rectOfInterest)
		}
	}
	
	open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
		var QRCode: String?
		for metadata in metadataObjects as! [AVMetadataObject] {
			if metadata.type == AVMetadataObjectTypeQRCode {
				QRCode = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
			}
		}
		if let code = QRCode {
			imageScanCompletionBlock?(code)
		}
	}
	
	open func finish() {
		imageScanCompletionBlock = nil
		if let session = session {
			session.stopRunning()
			for input in session.inputs{
				session.removeInput(input as! AVCaptureInput)
			}
			for output in session.outputs{
				session.removeOutput(output as! AVCaptureOutput)
			}
		}
		previewLayer?.removeFromSuperlayer()
		previewLayer = nil
	}
}


public extension UIImage {
	public static func QRImageFrom(string: String, containingViewSize: CGSize? = nil, correctionLevel: String = "L") -> UIImage? {
		let stringData = string.data(using: String.Encoding.isoLatin1)
        let filter = CIFilter(name: "CICode128BarcodeGenerator")
		filter?.setValue(stringData, forKey: "inputMessage")
		filter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
		
		guard let resultImage = filter?.outputImage else { return nil }
		
		var scaleX = resultImage.extent.size.width
		var scaleY = resultImage.extent.size.height
		if let size = containingViewSize {
			scaleX = size.width / resultImage.extent.size.width
			scaleY = size.height / resultImage.extent.size.height
		}
		
		let qrImage = resultImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
		let context = CIContext()
		if let tempImage: CGImage = context.createCGImage(qrImage, from: qrImage.extent) {
			return UIImage(cgImage: tempImage)
		}
		return nil
	}
}
