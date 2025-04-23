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
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func addImage(_ image: UIImage, for key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
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
    @State private var loadAttempts = 0
    
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
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // If error or no data, try a fallback URL
            guard let data = data, error == nil,
                  let uiImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.loadAttempts += 1
                    self.isLoading = false
                    
                    // Try fallback
                    if self.loadAttempts <= 2 {
                        let urlString = url.absoluteString
                        // Cache buster to force a fresh request
                        let fallbackUrl = URL(string: "\(urlString)?attempt=\(self.loadAttempts)")
                        if fallbackUrl != nil && fallbackUrl != url {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.isLoading = true
                                self.loadImage()
                            }
                        }
                    }
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
        }
        
        // Set timeout for the request
        task.resume()
        
        // Cancel the task after 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if isLoading && cachedImage == nil {
                task.cancel()
                self.isLoading = false
                
                if self.loadAttempts <= 1 {
                    self.loadAttempts += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.isLoading = true
                        self.loadImage()
                    }
                }
            }
        }
    }
} 
