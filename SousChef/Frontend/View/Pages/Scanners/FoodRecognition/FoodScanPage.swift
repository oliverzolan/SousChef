//
//  FoodScanPage.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/8/25.
//

import SwiftUI

struct FoodScanPage: View {
    @State private var selectedImage: UIImage?
    @State private var recognizedFoods: [EdamamIngredientModel] = []
    @State private var isShowingCamera = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            Button("Take Photo") {
                isShowingCamera = true
            }
            .padding()
            .sheet(isPresented: $isShowingCamera) {
                CameraView(selectedImage: $selectedImage, isPresented: $isShowingCamera)
            }
            
            Button("Recognize Food") {
                if let image = selectedImage {
                    FatSecretToEdamamController.shared.recognizeAndMatchFood(image: image) { foods in
                        recognizedFoods = foods
                    }
                }
            }
            .padding()
            
            List(recognizedFoods, id: \.id) { food in
                HStack {
                    VStack(alignment: .leading) {
                        Text(food.label).font(.headline)
                        if let category = food.category {
                            Text(category).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    if let imageUrl = food.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit().frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}
