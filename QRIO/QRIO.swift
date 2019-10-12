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
	
	private let barCodeMetaType: [AVMetadataObject.ObjectType] = [
        .qr,
        .code128,
        .pdf417,
        .aztec
    ]
    
	open func scanForBarcodeImage(previewIn previewContainer: UIView? = nil, rectOfInterest: CGRect? = nil, completion: @escaping ((_ string: String) -> ())) {
		let session = AVCaptureSession()
        self.session = session
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
		
		do {
			let input = try AVCaptureDeviceInput(device: device)
			session.addInput(input)
		} catch {
			// Trying to run in simulator
			return
		}
		
		let output = AVCaptureMetadataOutput()
		output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
		session.addOutput(output)
		output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
		
		imageScanCompletionBlock = completion
		
		if let previewContainer = previewContainer {
			previewLayer = AVCaptureVideoPreviewLayer(session: session)
			previewContainer.layer.addSublayer(previewLayer!)
			previewLayer!.frame = previewContainer.bounds
			previewLayer!.videoGravity = .resizeAspectFill
			
		}
		DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
			self?.session?.startRunning()
		}
		
		if let rectOfInterest = rectOfInterest, let previewLayer = previewLayer {
			output.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: rectOfInterest)
		}
	}
	
	open func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var QRCode: String?
        for metadata in metadataObjects {
            if barCodeMetaType.contains(metadata.type) {
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
				session.removeInput(input )
			}
			for output in session.outputs{
				session.removeOutput(output )
			}
		}
		previewLayer?.removeFromSuperlayer()
		previewLayer = nil
	}
}

public extension UIImage {
    private static func barcode(from data: Data, filter: CIFilter, containingViewSize: CGSize? = nil) -> UIImage? {

        filter.setValue(data, forKey: "inputMessage")

        guard let resultImage = filter.outputImage else { return nil }
        
        var scaleX = resultImage.extent.size.width
        var scaleY = resultImage.extent.size.height
        if let size = containingViewSize {
            scaleX = size.width / resultImage.extent.size.width
            scaleY = size.height / resultImage.extent.size.height
        }
        
        let qrImage = resultImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        let context = CIContext()
        if let tempImage: CGImage = context.createCGImage(qrImage, from: qrImage.extent) {
            return UIImage(cgImage: tempImage)
        }

        return nil
    }

    static func pdf417CodeFrom(string: String, containingViewSize: CGSize? = nil, correctionLevel: NSNumber = NSNumber(integerLiteral: 0)) -> UIImage? {

        guard let stringData = string.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else { return nil }

        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        return barcode(from: stringData, filter: filter, containingViewSize: containingViewSize)
    }

    static func barcode128From(string: String, containingViewSize: CGSize? = nil) -> UIImage? {

        guard let stringData = string.data(using: .ascii),
            let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }

        return barcode(from: stringData, filter: filter, containingViewSize: containingViewSize)
    }

    static func aztecCodeFrom(string: String, containingViewSize: CGSize? = nil, correctionLevel: NSNumber = NSNumber(integerLiteral: 23)) -> UIImage? {
        
        guard let stringData = string.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIAztecCodeGenerator") else { return nil }

        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        return barcode(from: stringData, filter: filter, containingViewSize: containingViewSize)
    }

    static func QRImageFrom(string: String, containingViewSize: CGSize? = nil, correctionLevel: String = "L") -> UIImage? {
        
        guard let stringData = string.data(using: .isoLatin1),
            let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        return barcode(from: stringData, filter: filter, containingViewSize: containingViewSize)
    }
}
