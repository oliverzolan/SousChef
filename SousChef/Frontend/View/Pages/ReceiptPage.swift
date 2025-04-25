//
//  recipe_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct ReceiptPage: View {
    @State private var scannedItems: [String] = []
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        ZStack {
            ReceiptScannerView(scannedItems: $scannedItems, userSession: userSession)
                .ignoresSafeArea()
        }
    }
}

struct receipt_activity_Previews: PreviewProvider {
    static var previews: some View {
        let mockUserSession = UserSession()
        
        ReceiptPage()
            .environmentObject(mockUserSession)
    }
}
