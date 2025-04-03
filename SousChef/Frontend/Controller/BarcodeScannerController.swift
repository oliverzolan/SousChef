//
//  BarcodeScannerController.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/7/25.
//

import AVFoundation
import UIKit
import SwiftUI

protocol BarcodeScannerControllerDelegate: AnyObject {
    func didScanBarcode(_ barcode: String)
}

class BarcodeScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: BarcodeScannerControllerDelegate?
    private let userSession: UserSession
    private var recentlyScannedCodes = Set<String>()
    private let scanCooldown: TimeInterval = 3.0

    init(userSession: UserSession) {
        self.userSession = userSession
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restartScanner), name: NSNotification.Name("RestartScanner"), object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Failed to set up camera input: \(error)")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let scannedValue = metadataObject.stringValue else { return }
              
        // Prevent duplicate scans in quick succession
        if recentlyScannedCodes.contains(scannedValue) {
            return
        }
        
        // Add to recently scanned list
        recentlyScannedCodes.insert(scannedValue)
        
        // Clear from recently scanned after cooldown period
        DispatchQueue.main.asyncAfter(deadline: .now() + scanCooldown) {
            self.recentlyScannedCodes.remove(scannedValue)
        }

        // Temporarily pause scanning while processing
        captureSession.stopRunning()

        // Inform delegate about the scanned barcode
        delegate?.didScanBarcode(scannedValue)
    }

    @objc func restartScanner() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RestartScanner"), object: nil)
        stopScanning()
    }
    
    func stopScanning() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}
