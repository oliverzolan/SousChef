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
    var onItemsScanned: (([String]) -> Void)? // Closure to send scanned items back to SwiftUI

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
            fatalError("No video camera available")
        }
        captureSession.addInput(videoInput)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraFrameProcessingQueue"))
        captureSession.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    private func setupTextRecognition() {
        textDetectionRequest = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            if let error = error {
                print("Text recognition error: \(error)")
                return
            }
            self.handleTextRecognitionResults(request.results)
        }
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }

    private func setupOverlay() {
        // Configure the overlay view
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 10
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        // Configure the table view for displaying recognized items
        itemsTableView.backgroundColor = .clear
        itemsTableView.separatorStyle = .none
        itemsTableView.dataSource = self
        itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(itemsTableView)

        // Configure the "Done" button
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor.systemBlue
        doneButton.layer.cornerRadius = 10
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        overlayView.addSubview(doneButton)


        // Layout the overlay view, table view, and done button
        NSLayoutConstraint.activate([
            // Overlay view constraints
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            overlayView.heightAnchor.constraint(equalToConstant: 200),

            // Items table view constraints (above the "Done" button)
            itemsTableView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8),
            itemsTableView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            itemsTableView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8),
            itemsTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -10),

            // Done button constraints (at the bottom of the overlay)
            doneButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8),
            doneButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -8),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    @objc private func doneButtonTapped() {
        print("Done button tapped!") // Debugging

        // Ensure the `onItemsScanned` closure is called
        onItemsScanned?(recognizedItems)

        // Navigate to the ScannedIngredientsViewController
        let summaryViewController = ScannedIngredientsViewController()
        summaryViewController.scannedItems = recognizedItems

        if let navigationController = navigationController {
            // Push the new view controller if inside a UINavigationController
            navigationController.pushViewController(summaryViewController, animated: true)
        } else {
            // Present the view controller modally
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
            self.itemsTableView.reloadData() // Update the table view
            self.onItemsScanned?(self.recognizedItems) // Notify SwiftUI about updates
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
