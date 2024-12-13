//
//  ReceiptScannerViewController.swift
//  SousChef
//
//  Created by Bennet Rau on 11/14/24.
//

import UIKit
import AVFoundation
import Vision

class LiveReceiptScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var recognizedItems: [String] = []
    var onItemsScanned: (([String]) -> Void)? //need for sending back to UI for display
    private let doneButton = UIButton(type: .system)
    private let overlayView = UIView()
    private let itemsTableView = UITableView()

    let commonIngredients: Set<String> = [
        "apple", "banana", "carrot", "onion", "garlic", "potato", "tomato", "chicken", "beef", "pork",
        "fish", "rice", "pasta", "cheese", "milk", "butter", "salt", "sugar", "flour", "egg",
        "pepper", "olive oil", "lemon", "lime", "bread", "spinach", "broccoli", "cucumber", "lettuce",
        "mushroom", "corn", "peanut butter", "honey", "chocolate", "cream", "yogurt", "beans",
        "peas", "lentils", "avocados", "chili", "soy sauce", "vinegar", "basil", "parsley", "cilantro",
        "mint", "rosemary", "thyme", "oregano", "paprika", "cinnamon", "cumin", "turmeric",
        "ginger", "watermelon", "strawberry", "blueberry", "raspberry", "orange", "peach",
        "pear", "grape", "pineapple", "coconut", "almond", "walnut", "cashew", "hazelnut",
        "shrimp", "crab", "lobster", "salmon", "tuna", "cod", "bread crumbs", "zucchini",
        "eggplant", "bell pepper", "cauliflower", "cabbage", "celery", "kale", "chard",
        "beet", "radish", "asparagus", "artichoke", "leek", "scallion", "bok choy",
        "tofu", "tempeh", "seitan", "quinoa", "bulgur", "oats", "barley", "chia", "flaxseed", "poppi", "eggs"
    ]

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var textDetectionRequest: VNRecognizeTextRequest!
    private var frameCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupTextRecognition()
        setupOverlay()
    }

    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            fatalError("no camera")
        }
        captureSession.addInput(videoInput)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraFrameProcessingQueue"))
        captureSession.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        

        captureSession.startRunning()
    }

    private func setupTextRecognition() {
        textDetectionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            if let error = error {
                print("Cant recognize: \(error)")
                return
            }
            self.handleTextRecognitionResults(request.results)
        }
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }

    //bottom view need to be connected (ignore edges)
    private func setupOverlay() {
        view.layer.addSublayer(previewLayer)
        
        overlayView.backgroundColor = AppColors.backgroundUIColor.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 20
        overlayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        itemsTableView.backgroundColor = .clear
        itemsTableView.separatorStyle = .none
        itemsTableView.dataSource = self
        itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(itemsTableView)
        //DOne button
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = AppColors.navBarUIColor
        doneButton.layer.cornerRadius = 10
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        overlayView.addSubview(doneButton)
        //overlay
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.30),

            //anchor above done button
            itemsTableView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 16),
            itemsTableView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            itemsTableView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            itemsTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),

            doneButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }





    @objc private func doneButtonTapped() {
        print("Done button tapped!") //test
        onItemsScanned?(recognizedItems)
        //nav to scnaned
        let summaryViewController = ScannedIngredientsViewController()
        summaryViewController.scannedItems = recognizedItems

        if let navigationController = navigationController {
            navigationController.pushViewController(summaryViewController, animated: true)
        } else {
            present(summaryViewController, animated: true, completion: nil)
        }
    }


    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCount += 1
        if frameCount % 10 != 0 { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? requestHandler.perform([textDetectionRequest])
    }

    private func handleTextRecognitionResults(_ results: [Any]?) {
        guard let results = results as? [VNRecognizedTextObservation] else { return }

        for observation in results {
            if let recognizedText = observation.topCandidates(1).first?.string {
                let components = recognizedText.split(whereSeparator: { $0.isPunctuation || $0.isWhitespace })
                for component in components {
                    let normalizedText = normalizeText(String(component))
                    if commonIngredients.contains(normalizedText) && !recognizedItems.contains(normalizedText) {
                        recognizedItems.append(normalizedText)
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.itemsTableView.reloadData() //update
            self.onItemsScanned?(self.recognizedItems)
        }
    }

    private func normalizeText(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

extension LiveReceiptScannerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recognizedItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = recognizedItems[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        return cell
    }
}
