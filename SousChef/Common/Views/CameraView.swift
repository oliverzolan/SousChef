//
//  ContentView.swift
//  SousChef
//
//  Created by Oliver Zolan on 12/6/24.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No updates needed
    }
}
