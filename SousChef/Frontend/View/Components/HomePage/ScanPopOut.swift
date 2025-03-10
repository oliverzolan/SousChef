//
//  ScanPopOut.swift
//  SousChef
//
//  Created by Bennet Rau on 3/3/25.
//

import SwiftUI

struct ScanOptionsPopout: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var userSession: UserSession
    @State private var popUpOffset: CGFloat = 100
    @State private var popUpOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background Dim Effect
            if isShowing {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        closePopup()
                    }
            }

            VStack {
                Spacer() // Push popout to the bottom
                
                VStack(spacing: 15) {
                    scanButton(destination: FoodScanPage(), icon: "camera", label: "Scan Ingredients")
                    scanButton(destination: ReceiptPage(), icon: "doc.text.viewfinder", label: "Scan Receipt")
                    scanButton(destination: ScanBarcodePage(userSession: _userSession), icon: "barcode.viewfinder", label: "Scan Barcode")
                }
                .padding()
                .background(Color.black.opacity(0.75))
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
                .opacity(popUpOpacity)
                .offset(y: popUpOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        popUpOffset = 0
                        popUpOpacity = 1
                    }
                }
            }
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

    private func closePopup() {
        withAnimation(.easeIn(duration: 0.2)) {
            popUpOpacity = 0
            popUpOffset = 100
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isShowing = false
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
