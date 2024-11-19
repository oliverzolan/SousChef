//
//  ObjectRecognitionManager.swift
//  SousChef
//
//  Created by Oliver Zolan on 10/29/24.
//

import CoreML
import Vision
import UIKit

class ObjectRecognitionManager {
    private var model: VNCoreMLModel!

    init() {
        setupModel()
    }

    private func setupModel() {
        do {
            let mlModel = try mobilenetv3_jaja(configuration: MLModelConfiguration()) // INPUT MODEL HERE
            model = try VNCoreMLModel(for: mlModel.model)
        } catch {
            print("Error loading model: \(error)")
        }
    }

    func recognizeObject(in image: UIImage, completion: @escaping (String, Float) -> Void) {
        guard let cgImage = image.cgImage else { return }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first
            else {
                return
            }
            completion(topResult.identifier, topResult.confidence)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}
