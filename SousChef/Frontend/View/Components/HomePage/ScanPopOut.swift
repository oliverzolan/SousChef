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
                scanButton(destination: ScanIngredientPage(), icon: "camera", label: "Scan Ingredients")
                scanButton(destination: ReceiptPage(), icon: "doc.text.viewfinder", label: "Scan Receipt")
                scanButton(destination: EmptyView(), icon: "barcode.viewfinder", label: "Scan Barcode")
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

    private func scanButton<Destination: View>(destination: Destination, icon: String, label: String) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(label)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primary2)
            .cornerRadius(10)
        }
    }
}

#Preview {
    struct ScanOptionsPopoutPreview: View {
        @State private var isShowingPreview = true

        var body: some View {
            NavigationStack {
                ScanOptionsPopout(isShowing: $isShowingPreview)
            }
        }
    }

    return ScanOptionsPopoutPreview()
}
