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
    private var codeFrameView: UIView?

	open var imageScanCompletionBlock: ((_ string: String) -> ())?

	open func scanForQRImage(previewIn previewContainer: UIView? = nil, rectOfInterest: CGRect? = nil, completion: @escaping ((_ string: String) -> ())) {
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
        
        highlightDetectedCode(in: previewContainer)
	}
	
	open func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		var QRCode: String?
		var metaDataObj: AVMetadataMachineReadableCodeObject?

        for metadata in metadataObjects where metadata.type == AVMetadataObject.ObjectType.qr {
            metaDataObj = metadata as? AVMetadataMachineReadableCodeObject
            QRCode = metaDataObj?.stringValue
        }

        if let metaObj = metaDataObj {
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metaObj)
            codeFrameView?.frame = barCodeObject?.bounds ?? .zero
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
    
    /// Function to display a green box around the detected Code
    /// previewContainer - View in which the highlighted frame should be displayed
    open func highlightDetectedCode(in previewContainer: UIView?) {
        codeFrameView = UIView()

        guard let codeFrameView = codeFrameView, let previewContainer = previewContainer else { return }

        codeFrameView.layer.borderColor = UIColor.green.cgColor
        codeFrameView.layer.borderWidth = 2
        previewContainer.addSubview(codeFrameView)
        previewContainer.bringSubviewToFront(codeFrameView)
    }
}

public extension UIImage {
	static func QRImageFrom(string: String, containingViewSize: CGSize? = nil, correctionLevel: String = "L") -> UIImage? {
		let stringData = string.data(using: String.Encoding.isoLatin1)
        let filter = CIFilter(name: "CIQRCodeGenerator")
		filter?.setValue(stringData, forKey: "inputMessage")
		filter?.setValue(correctionLevel, forKey: "inputCorrectionLevel")
		
		guard let resultImage = filter?.outputImage else { return nil }
		
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
}
