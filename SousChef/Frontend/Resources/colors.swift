//
//  colors.swift
//  SousChef
//
//  Created by Bennet Rau on 10/28/24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.060
        
        self.init(red: r, green: g, blue: b)
    }
}


struct AppColors{
    
//    static let background = Color(hex: "#2F3C4D")
    //MAIN COLORS
    static let background = Color(hex: "#1F222A")
    static let cardColor = Color(hex: "637186")
    static let navBar = Color(hex: "#284757")
    
    //gradient card
    static let gradientCardLight = Color(hex: "#0F5A80")
    static let gradientCardDark = Color(hex: "#05293B")
    
    //gradient search bar
    static let gradientSearchBar = Color(hex: "#BAE3F7")
    
    
    
}

