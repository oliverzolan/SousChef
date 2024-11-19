//
//  ObjectScannerView.swift
//  SousChef
//
//  Created by Oliver Zolan on 10/29/24.
//

import UIKit
import CoreML
import Vision

class ObjectRecognitionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView = UIImageView()
    private let resultLabel = UILabel()
    private let selectImageButton = UIButton(type: .system)

    // Model instance
    private var model: VNCoreMLModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupModel()
        setupUI()
    }

    func setupModel() {
        do {
            let mlModel = try mobilenetv3_jaja(configuration: MLModelConfiguration()) // INPUT MODEL HERE
            model = try VNCoreMLModel(for: mlModel.model)
        } catch {
            print("Error loading model: \(error)")
        }
    }

    // Set up the UI layout
    func setupUI() {
        // ImageView setup
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // Result Label setup
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)

        //Button setup
        selectImageButton.setTitle("Select Image", for: .normal)
        selectImageButton.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectImageButton)

        // Constraints
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            selectImageButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // Button select an image
    @objc func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // Image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            recognizeObject(in: image)
        }
    }

    // Run the model
    func recognizeObject(in image: UIImage) {
        guard let cgImage = image.cgImage
        else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation]
            else {
                return
            }
            let topResult = results.first
            DispatchQueue.main.async {
                self?.resultLabel.text = "Detected: \(topResult?.identifier ?? "Unknown")\nConfidence: \(topResult?.confidence ?? 0)"
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}
