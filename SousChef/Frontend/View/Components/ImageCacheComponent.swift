//
//  ImageCacheComponent.swift
//  SousChef
//
//  Created by Oliver Zolan on 3/31/25.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
    }
    
    func addImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let content: (Image) -> AnyView
    let placeholder: AnyView
    
    init(url: URL?, 
         @ViewBuilder content: @escaping (Image) -> some View,
         @ViewBuilder placeholder: @escaping () -> some View) {
        self.url = url
        self.content = { AnyView(content($0)) }
        self.placeholder = AnyView(placeholder())
    }
    
    @State private var cachedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let image = cachedImage {
                content(Image(uiImage: image))
            } else {
                placeholder
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, isLoading else { return }
        
        // Check cache first
        if let urlString = url.absoluteString as String?,
           let cachedUIImage = ImageCache.shared.getImage(for: urlString) {
            self.cachedImage = cachedUIImage
            self.isLoading = false
            return
        }
        
        // Not in cache, load from network
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let uiImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Add to cache
            if let urlString = url.absoluteString as String? {
                ImageCache.shared.addImage(uiImage, for: urlString)
            }
            
            DispatchQueue.main.async {
                self.cachedImage = uiImage
                self.isLoading = false
            }
        }.resume()
    }
} 
