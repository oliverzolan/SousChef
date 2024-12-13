//
//  recipe_activity.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 11/19/24.
//

import SwiftUI

struct receipt_activity: View {
    @State private var scannedItems : [String] = []
    var body: some View {
        ZStack{
            ReceiptScannerView(scannedItems: $scannedItems)
        }
    }
}

struct receipt_activity_Previews: PreviewProvider {
    static var previews: some View {
        receipt_activity()
    }
}
