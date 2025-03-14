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

        captureSession.stopRunning()

        BarcodeScannerHelper.shared.fetchIngredient(by: scannedValue) { ingredient in
            guard let ingredient = ingredient else {
                BarcodeScannerHelper.shared.showBarcodeNotRecognizedAlert(
                    retryHandler: { self.restartScanner() },
                    searchHandler: { self.navigateToIngredientSearch() }
                )
                return
            }

            self.presentAddIngredientPage(ingredient: ingredient)
        }
    }

    private func presentAddIngredientPage(ingredient: BarcodeModel) {
        let addIngredientPage = AddIngredientBarcodePage(scannedIngredient: ingredient, userSession: self.userSession)
        let hostingController = UIHostingController(rootView: addIngredientPage)
        self.present(hostingController, animated: true, completion: nil)
    }

    @objc private func restartScanner() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    private func navigateToIngredientSearch() {
        DispatchQueue.main.async {
            let searchView = AddIngredientBarcodePage(scannedIngredient: nil, userSession: self.userSession)
            let hostingController = UIHostingController(rootView: searchView)
            self.present(hostingController, animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RestartScanner"), object: nil)
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
}
