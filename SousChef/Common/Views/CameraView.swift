import SwiftUI
import Vision
import AVFoundation

struct CameraView: UIViewRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        private let model: VNCoreMLModel

        init(parent: CameraView) {
            self.parent = parent
            let mlModel = try! mobilenetv3_jaja(configuration: MLModelConfiguration()) // INPUT MODEL HERE
            self.model = try! VNCoreMLModel(for: mlModel.model)
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else {
                return
            }

            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                    DispatchQueue.main.async {
                        self?.parent.result = "Detected: \(topResult.identifier) with confidence \(topResult.confidence)"
                    }
                }
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? handler.perform([request])
        }
    }

    @Binding var result: String
    private let session = AVCaptureSession()

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // Camera session setup
        session.sessionPreset = .photo
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera)
        else {
            return view
        }
        
        session.addInput(input)
        
        // Preview layer setup
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "cameraQueue"))
        session.addOutput(output)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
    
    func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        session.stopRunning()
    }
}
