//
//  Detection.swift
//  SousChef
//
//  Created by Oliver Zolan on 12/6/24.
//
// Structure for Detection

import CoreGraphics
import UIKit

struct Detection {
    let box: CGRect
    let confidence: Float
    let label: String?
    let color: UIColor
    let id = UUID()
}
