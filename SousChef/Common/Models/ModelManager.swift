//
//  ObjectRecognitionManager.swift
//  SousChef
//
//  Created by Oliver Zolan on 10/29/24.
//

import CoreML
import Vision
import UIKit

class ModelManager {
    static let shared = ModelManager()
    private init() {}

    private lazy var yoloRequest: VNCoreMLRequest! = {
        do {
            let model = try hundredepoc().model
            guard let classes = model.modelDescription.classLabels as? [String] else {
                fatalError("Failed to load class labels.")
            }
            self.classes = classes
            let vnModel = try VNCoreMLModel(for: model)
            return VNCoreMLRequest(model: vnModel)
        } catch {
            fatalError("Error initializing CoreML model: \(error)")
        }
    }()

    var classes: [String] = []

    func performDetection(on pixelBuffer: CVPixelBuffer, videoSize: CGSize) -> [Detection]? {
        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try handler.perform([yoloRequest])
            guard let results = yoloRequest.results as? [VNRecognizedObjectObservation] else {
                return nil
            }

            var detections: [Detection] = []
            for result in results {
                let flippedBox = CGRect(x: result.boundingBox.minX,
                                        y: 1 - result.boundingBox.maxY,
                                        width: result.boundingBox.width,
                                        height: result.boundingBox.height)
                let box = VNImageRectForNormalizedRect(flippedBox, Int(videoSize.width), Int(videoSize.height))
                if let label = result.labels.first?.identifier {
                    let color = UIColor(red: CGFloat.random(in: 0...1),
                                        green: CGFloat.random(in: 0...1),
                                        blue: CGFloat.random(in: 0...1),
                                        alpha: 1)
                    let detection = Detection(box: box, confidence: result.confidence, label: label, color: color)
                    detections.append(detection)
                }
            }
            return detections
        } catch {
            print("Error during inference: \(error)")
            return nil
        }
    }
}
