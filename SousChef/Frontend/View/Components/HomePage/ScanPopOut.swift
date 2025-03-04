//
//  ScanPopOut.swift
//  SousChef
//
//  Created by Bennet Rau on 3/3/25.
//


import SwiftUI

struct ScanOptionsPopout: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer() // Push popout to the bottom
            
            VStack(spacing: 15) {
                Button(action: { isShowing = false }) {
                    HStack {
                        Image(systemName: "camera")
                            .foregroundColor(.white)
                        Text("Scan Ingridients")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary2)
                    .cornerRadius(10)
                }
                
                Button(action: { isShowing = false }) {
                    HStack {
                        Image(systemName: "doc.text.viewfinder")
                            .foregroundColor(.white)
                        Text("Scan Receipt")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary2)
                    .cornerRadius(10)
                }
                
                Button(action: { isShowing = false }) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(.white)
                        Text("Scan Barcode")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary2)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .cornerRadius(15)
            .padding(.horizontal, 20)
            .padding(.bottom, 90) // ✅ Moves it above the tab bar
            .transition(.move(edge: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(isShowing ? Color.black.opacity(0.3) : Color.clear)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            isShowing = false
        }
    }
}

#Preview {
    struct ScanOptionsPopoutPreview: View {
        @State private var isShowingPreview = true

        var body: some View {
            ScanOptionsPopout(isShowing: $isShowingPreview)
        }
    }

    return ScanOptionsPopoutPreview()
}
