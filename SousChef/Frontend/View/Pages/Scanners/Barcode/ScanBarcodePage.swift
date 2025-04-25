import SwiftUI
import AVFoundation
import Foundation


struct ScanBarcodePage: View {
    @EnvironmentObject var userSession: UserSession
    @State private var scannedItems: [ScannedItem] = []
    @State private var showAddIngredientPopup = false
    @State private var isFlashlightOn = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var isFlashing = false
    @Environment(\.dismiss) private var dismiss
    
    // Load ingredients from JSON file
    @State private var knownIngredients: [String] = []

    var body: some View {
        ZStack {
            // Background and camera view
            BarcodeScannerView(scannedItems: $scannedItems, showToast: $showToast, toastMessage: $toastMessage)
                .edgesIgnoringSafeArea(.all)
            
            // Scanner frame overlay - always visible at a fixed position
            ZStack {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .mask(
                        Rectangle()
                            .frame(width: 300, height: 100)
                            .cornerRadius(10)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()

                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFlashing ? Color.green : Color.white, lineWidth: 4)
                    .frame(width: 300, height: 100)

                VStack {
                    Spacer()
                    Text("Align the barcode within the frame")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom, 100)
                }
            }
            .onAppear {
                // Start the flashing animation when the view appears
                withAnimation(Animation.easeInOut(duration: 0.7).repeatForever()) {
                    isFlashing = true
                }
                // Load the ingredients when the view appears
                loadIngredients()
            }
            
            // UI Controls and scanned items overlay
            VStack {
                // Top controls - always on top and accessible
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Button(action: {
                        toggleFlashlight()
                    }) {
                        Image(systemName: isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 20)
                }
                
                // Scanned items list - below the top controls
                if !scannedItems.isEmpty {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(scannedItems) { item in
                                HStack {
                                    Text(item.ingredient.label)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 200)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // "Add to Pantry" button at the bottom
                if !scannedItems.isEmpty {
                    Button(action: {
                        addScannedItemsToPantry()
                        dismiss()
                    }) {
                        Text("Add to Pantry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
            }
            
            // Toast notification
            if showToast {
                ToastView(message: toastMessage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
            }
        }
    }
    
    private func loadIngredients() {
        // Use IngredientController to load ingredients from JSON
        let ingredientController = IngredientController(userSession: userSession)
        let ingredients = ingredientController.getBasicIngredientsList()
        
        // Make sure all ingredients have proper capitalization
        knownIngredients = ingredients.map { 
            $0.split(separator: " ").map { 
                $0.prefix(1).uppercased() + $0.dropFirst().lowercased() 
            }.joined(separator: " ")
        }
    }
    
    private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            try? device.lockForConfiguration()
            
            if isFlashlightOn {
                device.torchMode = .off
            } else {
                try? device.setTorchModeOn(level: 1.0)
            }
            
            device.unlockForConfiguration()
            isFlashlightOn.toggle()
        }
    }
    
    private func addScannedItemsToPantry() {
        let internalIngredientsComponent = AWSInternalIngredientsComponent(userSession: userSession)
        let userIngredientsComponent = AWSUserIngredientsComponent(userSession: userSession)
        
        for item in scannedItems {
            // Check if the ingredient exists in the backend
            internalIngredientsComponent.checkIngredientExists(name: item.ingredient.label) { exists in
                if exists {
                    // Fetch the ingredient details from the backend
                    internalIngredientsComponent.searchIngredients(query: item.ingredient.label, limit: 1) { result in
                        switch result {
                        case .success(let ingredients):
                            if let ingredient = ingredients.first {
                                let newIngredient = AWSIngredientModel(
                                    edamamFoodId: ingredient.edamamFoodId,
                                    foodCategory: ingredient.foodCategory,
                                    name: ingredient.name,
                                    quantityType: ingredient.quantityType,
                                    experiationDuration: ingredient.experiationDuration,
                                    imageURL: ingredient.imageURL
                                )
                                
                                userIngredientsComponent.addIngredients(ingredients: [newIngredient]) { result in
                                    switch result {
                                    case .success:
                                        print("Added \(ingredient.name) to pantry")
                                    case .failure(let error):
                                        print("Error adding \(ingredient.name) to pantry: \(error)")
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Error fetching ingredient details: \(error)")
                        }
                    }
                } else {
                    print("Ingredient \(item.ingredient.label) does not exist in the backend")
                }
            }
        }
        
        // Restart the scanner after adding ingredients
        NotificationCenter.default.post(name: NSNotification.Name("RestartScanner"), object: nil)
    }
}
