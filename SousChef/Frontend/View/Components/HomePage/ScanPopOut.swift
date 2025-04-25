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
            
            if selectedImage != nil {
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
            
//            Button(action: {
//                selectedOption = .camera
//                showCamera = true
//            }) {
//                optionCard(
//                    icon: "camera.fill",
//                    title: "Scan Ingredient",
//                    description: "Take a photo of ingredients"
//                )
//            }
            
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
            
//            Button(action: {
//                selectedOption = .gallery
//                showImagePicker = true
//            }) {
//                optionCard(
//                    icon: "photo.on.rectangle",
//                    title: "Choose from Gallery",
//                    description: "Select a photo from your gallery"
//                )
//            }
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
                    analyzeImage()
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
            
            Text("Analyzing image...")
                .font(.headline)
            
            Text("We're extracting ingredients from your image")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 250)
        .padding()
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
    
    private func reset() {
        selectedImage = nil
        selectedOption = nil
        recognizedText = ""
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
