//
//  ScanPopOut.swift
//  SousChef
//
//  Created by Bennet Rau on 3/3/25.
//

import SwiftUI
import AVFoundation

struct ScanPopOut: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var userSession: UserSession
    @State private var selectedOption: ScanOption? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage? = nil
    @State private var recognizedText: String = ""
    @State private var isAnalyzing = false
    @State private var internalIsShowing: Bool = true // Internal state to control visibility
    @State private var slideOffset: CGFloat = 0 // For slide animation
    
    // Added for the vision API integration
    @State private var recognizedIngredients: [RecognizedIngredient] = []
    @State private var enrichedIngredients: [RecognizedIngredientWithDetails] = []
    @State private var showRecognizedIngredients: Bool = false
    @State private var showEnrichedIngredients: Bool = false
    @State private var errorMessage: String? = nil
    @State private var progressText: String = "Analyzing image..."
    @State private var progressSubtext: String = "We're extracting ingredients from your image"
    
    // Animation duration - adjust this to match the appearance animation
    private let animationDuration: Double = 0.3
    
    enum ScanOption {
        case camera
        case gallery
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Scan Ingredients")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    // Close with animation
                    withAnimation(.easeIn(duration: animationDuration)) {
                        internalIsShowing = false
                        slideOffset = 500 // Slide down off screen
                    }
                    
                    // Set the binding after the animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            if showEnrichedIngredients {
                enrichedIngredientsView
            } else if showRecognizedIngredients {
                recognizedIngredientsView
            } else if selectedImage != nil {
                imagePreviewView
            } else if isAnalyzing {
                analyzeLoadingView
            } else if !recognizedText.isEmpty {
                recognizedTextView
            } else {
                optionsView
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
        .padding()
        .opacity(internalIsShowing ? 1 : 0.4) // Fade out but not completely
        .offset(y: slideOffset) // Apply the slide offset
        .animation(.easeIn(duration: animationDuration), value: internalIsShowing) // Match animation
        .animation(.easeIn(duration: animationDuration), value: slideOffset) // Match animation for sliding
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .onAppear {
            // Reset internal state when view appears
            internalIsShowing = true
            slideOffset = 0 // Reset slide position
        }
        .alert(item: Binding<AlertItem?>(
            get: { 
                if let error = errorMessage {
                    return AlertItem(message: error)
                }
                return nil
            },
            set: { _ in 
                errorMessage = nil
            }
        )) { alertItem in
            Alert(
                title: Text("Error"),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var optionsView: some View {
        VStack(spacing: 20) {
            Button(action: {
                // Navigate to barcode scanner using UIKit presentation for better camera access
                presentBarcodeScannerUsingUIKit()
                isShowing = false
            }) {
                optionCard(
                    icon: "barcode.viewfinder",
                    title: "Scan Barcode",
                    description: "Scan product barcode to add to pantry"
                )
            }
            
            Button(action: {
                selectedOption = .camera
                showCamera = true
            }) {
                optionCard(
                    icon: "camera.fill",
                    title: "Scan Ingredient",
                    description: "Take a photo of ingredients"
                )
            }
            
            Button(action: {
                // Navigate to receipt scanner using UIKit presentation
                presentReceiptScannerUsingUIKit()
                isShowing = false
            }) {
                optionCard(
                    icon: "doc.text.viewfinder",
                    title: "Scan Receipt",
                    description: "Capture grocery receipt items"
                )
            }
            
            Button(action: {
                selectedOption = .gallery
                showImagePicker = true
            }) {
                optionCard(
                    icon: "photo.on.rectangle",
                    title: "Choose from Gallery",
                    description: "Select a photo from your gallery"
                )
            }
        }
        .padding()
    }
    
    func optionCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(AppColors.primary2)
                .frame(width: 60, height: 60)
                .background(AppColors.primary2.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    var imagePreviewView: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            }
            
            HStack {
                Button(action: {
                    selectedImage = nil
                    selectedOption = nil
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    analyzeImageWithVisionAPI()
                }) {
                    Text("Analyze")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.primary1)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .padding()
    }
    
    var analyzeLoadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text(progressText)
                .font(.headline)
            
            Text(progressSubtext)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 250)
        .padding()
    }
    
    var recognizedIngredientsView: some View {
        VStack {
            RecognizedIngredientsView(ingredients: $recognizedIngredients)
                .frame(height: 350)
            
            HStack {
                Button(action: {
                    // Go back to image
                    showRecognizedIngredients = false
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    processSelectedIngredients()
                }) {
                    Text("Process")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.primary1)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    var enrichedIngredientsView: some View {
        VStack {
            EnrichedIngredientsView(ingredients: $enrichedIngredients)
                .frame(height: 350)
            
            HStack {
                Button(action: {
                    // Go back to basic ingredients
                    showEnrichedIngredients = false
                    showRecognizedIngredients = true
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    addSelectedIngredientsToPantry()
                }) {
                    Text("Add to Pantry")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.secondary2)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    var recognizedTextView: some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(recognizedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .frame(height: 250)
            
            HStack {
                Button(action: {
                    reset()
                }) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // Add to pantry
                    isShowing = false
                }) {
                    Text("Add to Pantry")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.secondary2)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .padding()
    }
    
    private func analyzeImage() {
        guard selectedImage != nil else { return }
        
        isAnalyzing = true
        
        // Simulate image analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // In a real app, you would use Vision or another API to extract text
            recognizedText = "Tomatoes\nOnions\nGarlic\nOlive Oil\nBasil\nPepper\nSalt"
            isAnalyzing = false
        }
    }
    
    private func analyzeImageWithVisionAPI() {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        progressText = "Analyzing image..."
        progressSubtext = "We're extracting ingredients from your image"
        
        VisionAPIService.shared.recognizeIngredientsInImage(image) { result in
            switch result {
            case .success(let ingredients):
                if ingredients.isEmpty {
                    isAnalyzing = false
                    errorMessage = "No ingredients were recognized in the image."
                } else {
                    // Convert string list to RecognizedIngredient objects
                    recognizedIngredients = ingredients.map { RecognizedIngredient(name: $0) }
                    isAnalyzing = false
                    showRecognizedIngredients = true
                }
                
            case .failure(let error):
                isAnalyzing = false
                errorMessage = "Failed to analyze image: \(error.localizedDescription)"
            }
        }
    }
    
    private func processSelectedIngredients() {
        let selectedItems = recognizedIngredients.filter { $0.selected }
        
        if selectedItems.isEmpty {
            errorMessage = "Please select at least one ingredient to process."
            return
        }
        
        // Set to analyzing state
        isAnalyzing = true
        progressText = "Processing ingredients..."
        progressSubtext = "We're matching your ingredients with our database"
        showRecognizedIngredients = false
        
        // Get the selected names
        let selectedNames = selectedItems.map { $0.name }
        
        // Process the ingredients using our matcher service
        IngredientMatchingService.shared.matchIngredients(selectedNames) { result in
            isAnalyzing = false
            
            switch result {
            case .success(let matchedIngredients):
                enrichedIngredients = matchedIngredients
                showEnrichedIngredients = true
                
            case .failure(let error):
                errorMessage = "Failed to process ingredients: \(error.localizedDescription)"
                showRecognizedIngredients = true
            }
        }
    }
    
    private func addSelectedIngredientsToPantry() {
        let selectedItems = enrichedIngredients.filter { $0.selected }
        
        if selectedItems.isEmpty {
            errorMessage = "Please select at least one ingredient to add."
            return
        }
        
        // Get the ingredient controller to add the ingredients to the pantry
        let ingredientController = IngredientController(userSession: userSession)
        
        // Create loading indicators and success messages
        isAnalyzing = true
        progressText = "Adding to pantry..."
        progressSubtext = "Adding your ingredients to your pantry"
        showEnrichedIngredients = false
        
        // Process each ingredient and add it to the pantry
        let dispatchGroup = DispatchGroup()
        var successCount = 0
        
        for ingredient in selectedItems {
            dispatchGroup.enter()
            
            // Add to database using the AWS model conversion
            ingredientController.addIngredientToDatabase(ingredient.asAWSIngredientModel) {
                successCount += 1
                dispatchGroup.leave()
            }
        }
        
        // When all ingredients have been processed
        dispatchGroup.notify(queue: .main) {
            isAnalyzing = false
            
            // Show success and close
            if successCount > 0 {
                // Close with animation
                withAnimation(.easeIn(duration: animationDuration)) {
                    internalIsShowing = false
                    slideOffset = 500 // Slide down off screen
                }
                
                // Set the binding after the animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    isShowing = false
                }
            } else {
                errorMessage = "Failed to add ingredients to pantry. Please try again."
                showEnrichedIngredients = true
            }
        }
    }
    
    private func reset() {
        selectedImage = nil
        selectedOption = nil
        recognizedText = ""
        recognizedIngredients = []
        enrichedIngredients = []
        showRecognizedIngredients = false
        showEnrichedIngredients = false
    }
    
    // Present the barcode scanner using UIKit for better camera access
    private func presentBarcodeScannerUsingUIKit() {
        // Create a new NavigationView to contain the scanner
        let scannerView = NavigationView {
            ScanBarcodePage()
                .environmentObject(userSession)
                .navigationBarHidden(true)
                .ignoresSafeArea(.all)
        }
        
        let hostingController = UIHostingController(rootView: scannerView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        
        // Close with animation
        withAnimation(.easeIn(duration: animationDuration)) {
            internalIsShowing = false
            slideOffset = 500 // Slide down off screen
        }
        
        // Present the scanner after the animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            // Update binding
            isShowing = false
            
            // Present the scanner
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                
                // Find the topmost presented controller
                var topController = rootViewController
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                
                // Present the barcode scanner
                print("Presenting barcode scanner...")
                topController.present(hostingController, animated: true)
            }
        }
    }
    
    // Similar function for receipt scanner
    private func presentReceiptScannerUsingUIKit() {
        // Create a new NavigationView to contain the scanner
        let receiptView = NavigationView {
            ReceiptPage()
                .environmentObject(userSession)
                .navigationBarHidden(true)
                .ignoresSafeArea(.all)
        }
        
        let hostingController = UIHostingController(rootView: receiptView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        
        // Close with animation
        withAnimation(.easeIn(duration: animationDuration)) {
            internalIsShowing = false
            slideOffset = 500 // Slide down off screen
        }
        
        // Present the scanner after the animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            // Update binding
            isShowing = false
            
            // Present the scanner
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                
                // Find the topmost presented controller
                var topController = rootViewController
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                
                // Present the receipt scanner
                print("Presenting receipt scanner...")
                topController.present(hostingController, animated: true)
            }
        }
    }
}

// Alert item for error messages
struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    struct ScanOptionsPopoutPreview: View {
        @State private var isShowingPreview = true

        var body: some View {
            NavigationStack {
                ScanPopOut(isShowing: $isShowingPreview)
            }
        }
    }

    return ScanOptionsPopoutPreview()
}
