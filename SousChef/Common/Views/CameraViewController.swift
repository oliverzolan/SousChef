//
//  CameraViewController.swift
//  SousChef
//
//  Created by Oliver Zolan on 12/6/24.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession = AVCaptureSession()
    var previewView = UIImageView()
    var videoOutput: AVCaptureVideoDataOutput!
    var videoSize = CGSize.zero
    var frameCounter = 0
    let frameInterval = 1
    let colors: [UIColor] = {
        var colorSet: [UIColor] = []
        for _ in 0...80 {
            let color = UIColor(red: CGFloat.random(in: 0...1),
                                green: CGFloat.random(in: 0...1),
                                blue: CGFloat.random(in: 0...1),
                                alpha: 1)
            colorSet.append(color)
        }
        return colorSet
    }()
    var classes: [String] = []

    lazy var modelRequest: VNCoreMLRequest! = {
        do {
            let model = try hundredepoc().model
            guard let classes = model.modelDescription.classLabels as? [String] else {
                fatalError("Failed to load class labels.")
            }
            self.classes = classes
            let vnModel = try VNCoreMLModel(for: model)
            let request = VNCoreMLRequest(model: vnModel)
            return request
        } catch {
            fatalError("Error loading the CoreML model: \(error)")
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeviceOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    var detectionOverlay: UIView!

    func setupCamera() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        detectionOverlay = UIView(frame: view.bounds)
        detectionOverlay.backgroundColor = .clear
        detectionOverlay.isUserInteractionEnabled = false
        view.addSubview(detectionOverlay)

        captureSession.beginConfiguration()

        guard let device = AVCaptureDevice.default(for: .video),
              let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            fatalError("Failed to access the camera.")
        }

        captureSession.addInput(deviceInput)

        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)

        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = false
        }

        captureSession.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCounter += 1
        if frameCounter == frameInterval {
            frameCounter = 0
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            if videoSize == .zero {
                videoSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            }

            detectObjects(pixelBuffer: pixelBuffer)
        }
    }

    func detectObjects(pixelBuffer: CVPixelBuffer) {
        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try handler.perform([modelRequest])
            guard let results = modelRequest.results as? [VNRecognizedObjectObservation] else {
                print("No results from detection.")
                return
            }

            var detections: [Detection] = []
            let confidenceThreshold: Float = 0.72

            for result in results {
                guard result.confidence >= confidenceThreshold else { continue }

                let flippedBox = CGRect(
                    x: result.boundingBox.minX,
                    y: 1 - result.boundingBox.maxY,
                    width: result.boundingBox.width,
                    height: result.boundingBox.height
                )

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let overlaySize = self.detectionOverlay.bounds.size
                    let box = CGRect(
                        x: flippedBox.origin.x * overlaySize.width,
                        y: flippedBox.origin.y * overlaySize.height,
                        width: flippedBox.width * overlaySize.width,
                        height: flippedBox.height * overlaySize.height
                    )

                    if let label = result.labels.first?.identifier,
                       let colorIndex = self.classes.firstIndex(of: label) {
                        let detection = Detection(box: box, confidence: result.confidence, label: label, color: self.colors[colorIndex])
                        detections.append(detection)
                    }

                    self.drawDetections(detections)
                }
            }
        } catch {
            print("Error during detection: \(error)")
        }
    }

    func drawDetections(_ detections: [Detection]) {
        DispatchQueue.main.async {
            self.detectionOverlay.layer.sublayers?.removeAll()
            for detection in detections {
                let boxLayer = CALayer()
                boxLayer.frame = detection.box
                boxLayer.borderColor = detection.color.cgColor
                boxLayer.borderWidth = 2.0

                let textLayer = CATextLayer()
                textLayer.string = "\(detection.label ?? "Unknown") \(Int(detection.confidence * 100))%"
                textLayer.fontSize = 18
                textLayer.foregroundColor = detection.color.cgColor
                textLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
                textLayer.alignmentMode = .center
                textLayer.frame = CGRect(
                    x: detection.box.origin.x,
                    y: detection.box.origin.y - 20,
                    width: detection.box.width,
                    height: 20
                )

                self.detectionOverlay.layer.addSublayer(boxLayer)
                self.detectionOverlay.layer.addSublayer(textLayer)
            }
        }
    }

    @objc func handleDeviceOrientationChange() {
        guard let connection = videoOutput.connection(with: .video) else {
            print("No video connection found.")
            return
        }

        let deviceOrientation = UIDevice.current.orientation
        
        switch deviceOrientation {
        case .portrait:
            connection.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft
        default:
            connection.videoOrientation = .portrait
        }
    }
}
