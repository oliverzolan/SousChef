//
//  ReceiptScannerViewController.swift
//  SousChef
//
//  Created by Bennet Rau on 11/14/24.
//

import UIKit
import AVFoundation
import Vision
import SwiftUI

class LiveReceiptScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDelegate, UITableViewDataSource {
    var recognizedItems: [String] = []
    var validatedItems: [AWSIngredientModel] = []
    var isProcessingValidation = false
    
    var onItemsScanned: (([String]) -> Void)? //need for sending back to UI for display
    private let doneButton = UIButton(type: .system)
    private let overlayView = UIView()
    private let itemsTableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var userSession: UserSession?

    var commonIngredients: Set<String> = []

    private func loadCommonIngredients() {
        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let ingredientList = try? JSONDecoder().decode([String].self, from: data) else {
            print("Failed to load ingredients.json")
            return
        }
        commonIngredients = Set(ingredientList.map { $0.lowercased() })
    }


    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var textDetectionRequest: VNRecognizeTextRequest!
    private var frameCount = 0
    
    // Default initializer
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // Initializer with user session
    init(userSession: UserSession) {
        self.userSession = userSession
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupTextRecognition()
        setupOverlay()
        addCloseButton()
        loadCommonIngredients()
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

    //bottom view need to be connected
    private func setupOverlay() {
        view.layer.addSublayer(previewLayer)
        
        overlayView.backgroundColor = AppColors.backgroundUIColor.withAlphaComponent(0.8) // Darker background for better readability
        overlayView.layer.cornerRadius = 20
        overlayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Add a title label for the overlay
        let titleLabel = UILabel()
        titleLabel.text = "Recognized Ingredients"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(titleLabel)
        
        // Setup table view with layout manager
        itemsTableView.backgroundColor = .clear
        itemsTableView.separatorStyle = .none
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        itemsTableView.rowHeight = 44
        itemsTableView.estimatedRowHeight = 44
        itemsTableView.isScrollEnabled = true
        itemsTableView.showsVerticalScrollIndicator = true
        overlayView.addSubview(itemsTableView)
        
        // Setup loading indicator
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(loadingIndicator)
        
        // Setup done button
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor(AppColors.secondary1)
        doneButton.layer.cornerRadius = 10
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        overlayView.addSubview(doneButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            titleLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),

            //anchor below title and above done button
            itemsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            itemsTableView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            itemsTableView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            itemsTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),

            doneButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])
    }

    // Add method to create a close button in top-left corner
    private func addCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        // Updated style
        closeButton.tintColor = UIColor.gray
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        closeButton.layer.cornerRadius = 20
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowOpacity = 0.5
        closeButton.layer.shadowRadius = 3
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    
    @objc private func closeButtonTapped() {
        // Stop the camera session
        captureSession.stopRunning()
        // Dismiss the scanner view controller
        dismiss(animated: true, completion: nil)
    }

    @objc private func doneButtonTapped() {
        print("Done button tapped!")
        
        // Validate all recognized items against AWS server
        validateIngredientsWithAWS { [weak self] in
            guard let self = self else { return }
            
            // Filter out any unknown or empty items
            let filteredItems = self.validatedItems.filter { ingredient in
                // Ensure the item has a valid name and category
                return !ingredient.name.isEmpty && 
                       !ingredient.name.lowercased().contains("unknown") &&
                       !ingredient.edamamFoodId.isEmpty &&
                       !ingredient.foodCategory.isEmpty
            }
            
            // Only proceed if we have valid items
            if filteredItems.isEmpty {
                print("No valid ingredients found after filtering!")
                
                // Show an alert to the user
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "No Valid Ingredients",
                        message: "We couldn't identify any ingredients from your receipt. Please try scanning again or add items manually.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
                return
            }
            
            // Dismiss the scanner and present the results in the pantry interface
            if let presentingVC = self.presentingViewController {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        // Create and present the pantry ingredients view with scanned items
                        let pantryView = ScannedItemsPantryView(validatedItems: filteredItems, userSessionParam: self.userSession)
                            .environmentObject(self.userSession ?? UserSession())
                        
                        let hostingController = UIHostingController(rootView: pantryView)
                        hostingController.modalPresentationStyle = .fullScreen
                        
                        presentingVC.present(hostingController, animated: true)
                    }
                }
            }
        }
    }

    private func validateIngredientsWithAWS(completion: @escaping () -> Void) {
        guard !recognizedItems.isEmpty else {
            completion()
            return
        }
        
        // Show loading indicator while validating
        DispatchQueue.main.async { [weak self] in
            self?.isProcessingValidation = true
            self?.loadingIndicator.startAnimating()
            self?.itemsTableView.reloadData()
        }
        
        let awsInternalIngredientsAPI = AWSInternalIngredientsComponent(userSession: userSession ?? UserSession())
        let dispatchGroup = DispatchGroup()
        
        // Clear previous validated items
        validatedItems.removeAll()
        
        // Store unique ingredient IDs to avoid duplicates
        var uniqueIngredientIds = Set<String>()
        
        // For each recognized item, check if it exists in the AWS database
        for item in recognizedItems {
            dispatchGroup.enter()
            
            // Try with original form first
            searchIngredient(query: item, api: awsInternalIngredientsAPI) { [weak self] result in
                guard let self = self else {
                    dispatchGroup.leave()
                    return
                }
                
                switch result {
                case .success(let ingredients):
                    if let firstIngredient = ingredients.first, !uniqueIngredientIds.contains(firstIngredient.edamamFoodId) {
                        uniqueIngredientIds.insert(firstIngredient.edamamFoodId)
                        self.validatedItems.append(firstIngredient)
                        dispatchGroup.leave()
                    } else if item.hasSuffix("s") && item.count > 2 {
                        // If plural, try singular form
                        let singular = String(item.dropLast())
                        self.searchIngredient(query: singular, api: awsInternalIngredientsAPI) { result in
                            switch result {
                            case .success(let ingredients):
                                if let firstIngredient = ingredients.first, !uniqueIngredientIds.contains(firstIngredient.edamamFoodId) {
                                    uniqueIngredientIds.insert(firstIngredient.edamamFoodId)
                                    self.validatedItems.append(firstIngredient)
                                }
                            case .failure:
                                print("Failed to validate ingredient \(singular)")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        // If singular, try plural form
                        let plural = item + "s"
                        self.searchIngredient(query: plural, api: awsInternalIngredientsAPI) { result in
                            switch result {
                            case .success(let ingredients):
                                if let firstIngredient = ingredients.first, !uniqueIngredientIds.contains(firstIngredient.edamamFoodId) {
                                    uniqueIngredientIds.insert(firstIngredient.edamamFoodId)
                                    self.validatedItems.append(firstIngredient)
                                }
                            case .failure:
                                print("Failed to validate ingredient \(plural)")
                            }
                            dispatchGroup.leave()
                        }
                    }
                case .failure:
                    // Special case for "eggs"/"egg"
                    if item.lowercased() == "eggs" {
                        self.searchIngredient(query: "egg", api: awsInternalIngredientsAPI) { result in
                            switch result {
                            case .success(let ingredients):
                                if let firstIngredient = ingredients.first, !uniqueIngredientIds.contains(firstIngredient.edamamFoodId) {
                                    uniqueIngredientIds.insert(firstIngredient.edamamFoodId)
                                    self.validatedItems.append(firstIngredient)
                                }
                            case .failure:
                                print("Failed to validate ingredient egg")
                            }
                            dispatchGroup.leave()
                        }
                    } else if item.lowercased() == "egg" {
                        self.searchIngredient(query: "eggs", api: awsInternalIngredientsAPI) { result in
                            switch result {
                            case .success(let ingredients):
                                if let firstIngredient = ingredients.first, !uniqueIngredientIds.contains(firstIngredient.edamamFoodId) {
                                    uniqueIngredientIds.insert(firstIngredient.edamamFoodId)
                                    self.validatedItems.append(firstIngredient)
                                }
                            case .failure:
                                print("Failed to validate ingredient eggs")
                            }
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.isProcessingValidation = false
            self?.loadingIndicator.stopAnimating()
            self?.itemsTableView.reloadData()
            
            // Add print statements for debugging
            if let self = self {
                print("Validated Items:")
                for item in self.validatedItems {
                    print("- \(item.name) (ID: \(item.edamamFoodId))")
                }
                if self.validatedItems.isEmpty {
                    print("No items were validated!")
                }
            }
            
            completion()
        }
    }
    
    // Helper to search for an ingredient with better error handling
    private func searchIngredient(query: String, api: AWSInternalIngredientsComponent, completion: @escaping (Result<[AWSIngredientModel], Error>) -> Void) {
        Task {
            await api.searchIngredients(query: query, limit: 1) { result in
                completion(result)
            }
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

        var newItems: [String] = []
        
        for observation in results {
            if let recognizedText = observation.topCandidates(1).first?.string {
                // First check if the full text is a known multi-word ingredient
                let normalizedFullText = normalizeText(recognizedText)
                if !recognizedItems.contains(normalizedFullText) && checkIngredientsMatch(normalizedFullText) {
                    recognizedItems.append(normalizedFullText)
                    newItems.append(normalizedFullText)
                    continue
                }
                
                // Try chunks of 2-3 words for multi-word ingredients
                let words = recognizedText.split(separator: " ").map(String.init)
                if words.count >= 2 {
                    for i in 0..<(words.count - 1) {
                        // Check pairs of words
                        let twoWordIngredient = normalizeText(words[i] + " " + words[i+1])
                        if !recognizedItems.contains(twoWordIngredient) && checkIngredientsMatch(twoWordIngredient) {
                            recognizedItems.append(twoWordIngredient)
                            newItems.append(twoWordIngredient)
                        }
                        
                        // Check triplets if possible
                        if i < words.count - 2 {
                            let threeWordIngredient = normalizeText(words[i] + " " + words[i+1] + " " + words[i+2])
                            if !recognizedItems.contains(threeWordIngredient) && checkIngredientsMatch(threeWordIngredient) {
                                recognizedItems.append(threeWordIngredient)
                                newItems.append(threeWordIngredient)
                            }
                        }
                    }
                }
                
                // Individual words as fallback
                let components = recognizedText.split(whereSeparator: { $0.isPunctuation || $0.isWhitespace })
                for component in components {
                    let normalizedText = normalizeText(String(component))
                    if !recognizedItems.contains(normalizedText) && checkIngredientsMatch(normalizedText) {
                        recognizedItems.append(normalizedText)
                        newItems.append(normalizedText)
                    }
                }
            }
        }

        // Only update UI if we actually added new items
        if !newItems.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Calculate the indices of the new items
                let startIndex = self.recognizedItems.count - newItems.count
                let newIndexPaths = (startIndex..<self.recognizedItems.count).map { 
                    IndexPath(row: $0, section: 0) 
                }
                
                // Insert the new rows with animation
                self.itemsTableView.beginUpdates()
                self.itemsTableView.insertRows(at: newIndexPaths, with: .automatic)
                self.itemsTableView.endUpdates()
                
                // Scroll to show the latest items
                if !self.recognizedItems.isEmpty {
                    let lastIndex = IndexPath(row: self.recognizedItems.count - 1, section: 0)
                    self.itemsTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
                }
                
                self.onItemsScanned?(self.recognizedItems)
            }
        }
    }

    // Helper to check if an ingredient matches, including handling plurals
    private func checkIngredientsMatch(_ ingredient: String) -> Bool {
        // Direct match
        if commonIngredients.contains(ingredient) {
            return true
        }
        
        // Plural check - if ending with 's' try without it
        if ingredient.hasSuffix("s") && ingredient.count > 2 {
            let singular = String(ingredient.dropLast())
            if commonIngredients.contains(singular) {
                return true
            }
        }
        
        // Singular check - if ingredient list has plural but text is singular
        let pluralForm = ingredient + "s"
        if commonIngredients.contains(pluralForm) {
            return true
        }
        
        return false
    }

    func normalizeText(_ text: String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recognizedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)

        // Clear old views to prevent stacking
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        // Main container with smaller footprint
        let container = UIView()
        container.backgroundColor = UIColor(AppColors.primary1)
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(container)

        // Label for ingredient name
        let label = UILabel()
        label.text = recognizedItems[indexPath.row].capitalized
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            container.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            container.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),

            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])

        return cell
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 // Consistent height for all rows
    }
}
