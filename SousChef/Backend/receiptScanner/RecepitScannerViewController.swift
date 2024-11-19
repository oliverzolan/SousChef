//
//  ReceiptScannerViewController.swift
//  SousChef
//
//  Created by Bennet Rau on 11/14/24.
//

import UIKit
import Vision
import VisionKit

class ReceiptScannerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var recognizedItems: [String] = []
    var onItemsScanned: (([String]) -> Void)? // Completion handler to pass data back

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


    lazy var scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Receipt", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startScanning), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Smaller font size
        return button
    }()

    lazy var resultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Scan a receipt to see ingredients."
        label.backgroundColor = UIColor.systemGray6 // Light gray background
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scanButton)
        view.addSubview(resultsLabel)
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.bottomAnchor.constraint(equalTo: resultsLabel.topAnchor, constant: -20),
            scanButton.heightAnchor.constraint(equalToConstant: 40),
            scanButton.widthAnchor.constraint(equalToConstant: 150),

            resultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultsLabel.heightAnchor.constraint(equalToConstant: 100), // Fixed height for results area
            resultsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }

    @objc func startScanning() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[.originalImage] as? UIImage else {
            resultsLabel.text = "No image found. Please try again."
            return
        }

        processImage(selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        resultsLabel.text = "Scanning cancelled."
    }
    
    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            resultsLabel.text = "Unable to convert UIImage to CGImage. Please try again."
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                self.resultsLabel.text = "Text recognition error: \(error.localizedDescription)"
                return
            }

            self.handleTextRecognitionResults(request.results)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            self.resultsLabel.text = "Failed to perform text recognition: \(error.localizedDescription)"
        }
    }

    private func handleTextRecognitionResults(_ results: [Any]?) {
        guard let results = results as? [VNRecognizedTextObservation] else {
            resultsLabel.text = "No text found. Please try again."
            return
        }

        recognizedItems = [] // Clear previous results

        for observation in results {
            let topCandidate = observation.topCandidates(1).first
            if let recognizedText = topCandidate?.string {
                // Split text into components based on common delimiters
                let components = recognizedText.split(whereSeparator: { $0.isPunctuation || $0.isWhitespace })
                
                for component in components {
                    let normalizedText = normalizeText(String(component)) // Normalize each part
                    if commonIngredients.contains(normalizedText) {
                        recognizedItems.append(normalizedText)
                    }
                }
            }
        }

        DispatchQueue.main.async {
            if self.recognizedItems.isEmpty {
                self.resultsLabel.text = "No common ingredients found. Please try again."
            } else {
                self.resultsLabel.text = "Recognized Ingredients: \(self.recognizedItems.joined(separator: ", "))"
            }
            self.onItemsScanned?(self.recognizedItems)
        }
    }

    // Helper function to normalize text
    private func normalizeText(_ text: String) -> String {
        // Remove punctuation and trim whitespace
        let cleanedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() // Convert to lowercase
            .filter { $0.isLetter || $0.isWhitespace } // Remove non-letter characters
        return cleanedText
    }
}
