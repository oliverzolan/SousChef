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
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

extension UIColor {
    convenience init(color: Color) {
        let uiColor = UIColor(color)
        self.init(cgColor: uiColor.cgColor)
    }
}

struct AppColors {
    // Main colors
    static let background = Color(hex: "#FFFFFF")
    static let cardColor = Color(hex: "#637186")
    static let navBar = Color(hex: "#284757")

    // Gradient colors
    static let gradientCardLight = Color(hex: "#0F5A80")
    static let gradientCardDark = Color(hex: "#05293B")
    static let gradientSearchBar = Color(hex: "#BAE3F7")
    
    // UIKit compatibility
    static var backgroundUIColor: UIColor { UIColor(background) }
    static var cardUIColor: UIColor { UIColor(cardColor) }
    static var navBarUIColor: UIColor { UIColor(navBar) }
    static var gradientCardLightUIColor: UIColor { UIColor(gradientCardLight) }
    static var gradientCardDarkUIColor: UIColor { UIColor(gradientCardDark) }
    static var gradientSearchBarUIColor: UIColor { UIColor(gradientSearchBar) }
    
    // New Main Colors
    static let primary1 = Color(hex: "#36622B")
    static let primary2 = Color(hex: "#729D39")
    static let primary3 = Color(hex: "#C6E377")
    static let secondary1 = Color(hex: "#FFAAAA")
    static let secondary2 = Color(hex: "#FF7777")
    static let secondary3 = Color(hex: "#FF5C5C")
    static let shade = Color(hex: "#DCE0DA")
    
    
}

