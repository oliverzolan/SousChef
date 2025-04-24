//
//  Main.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/2/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var homepageController: HomepageController
    @EnvironmentObject var pantryController: PantryController
    @State private var isShowingScanOptions = false
    @State private var selectedTab = 0
    
    // UI Adjustment
    init() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.backgroundColor = UIColor.white
        
        tabBarAppearance.layer.shadowColor = UIColor.black.cgColor
        tabBarAppearance.layer.shadowOpacity = 0.15
        tabBarAppearance.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBarAppearance.layer.shadowRadius = 6
        
        // Removes default top border
        tabBarAppearance.standardAppearance.shadowColor = nil
        tabBarAppearance.scrollEdgeAppearance = tabBarAppearance.standardAppearance
    }
    
    // Tab configuration with labels
    var tabs: [(view: AnyView, icon: String, label: String, tag: Int)] {
        [
            (AnyView(HomePage()), "house.fill", "Home", 0),
            (AnyView(PantryPage(userSession: userSession)), "refrigerator.fill", "Pantry", 1),
            (AnyView(EmptyView()), "barcode.viewfinder", "Scan", 2),
            (AnyView(ShoppingListsPage().environmentObject(userSession)), "cart.fill", "Shopping", 3),
            (AnyView(ChatbotPage()), "person.crop.circle", "Chef", 4)
        ]
    }
    
    // Navigation bar and associated Views
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(tabs, id: \.tag) { tab in
                    NavigationStack {
                        tab.view
                            .environmentObject(userSession)
                            .environmentObject(homepageController)
                            .environmentObject(pantryController)
                    }
                    .tabItem {
                        Label(tab.label, systemImage: tab.icon)
                    }
                    .tag(tab.tag)
                }
            }
            .accentColor(.black)
            
            // Show the scan options
            if isShowingScanOptions {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowingScanOptions = false
                    }
                
                ScanPopOut(isShowing: $isShowingScanOptions)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: isShowingScanOptions)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                withAnimation(.spring()) {
                    isShowingScanOptions = true
                }
                selectedTab = oldValue
            }
        }
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let userSession = UserSession()
        let pantryController = PantryController(userSession: userSession)
        let homepageController = HomepageController(pantryController: pantryController)
        
        MainTabView()
            .environmentObject(userSession)
            .environmentObject(pantryController)
            .environmentObject(homepageController)
    }
}
