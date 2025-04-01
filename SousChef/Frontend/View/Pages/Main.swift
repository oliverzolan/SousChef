//
//  Main.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/2/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var isShowingScanOptions = false
    @State private var selectedTab = 0
    
    //UI Adjustment
    init() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.backgroundColor = UIColor.white
        
        tabBarAppearance.layer.shadowColor = UIColor.black.cgColor
        tabBarAppearance.layer.shadowOpacity = 0.1
        tabBarAppearance.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarAppearance.layer.shadowRadius = 5
    }
    
    //Main Tabs
    var tabs: [(view: AnyView, icon: String, tag: Int)] {
            [
                (AnyView(HomePage()), "home_icon", 0),
                (AnyView(PantryPage(userSession: userSession)), "fridge_icon", 1),
                (AnyView(EmptyView()), "scan_icon", 2),
                (AnyView(ShoppingListsPage(userSession: _userSession)), "list_icon", 3),
                (AnyView(ChatbotPage(userSession: userSession)), "chef_hat_icon", 4)
            ]
        }
    
    //Navigation bar and associated Views
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ForEach(tabs, id: \.tag) { tab in
                    NavigationStack {
                        tab.view
                    }
                    .tabItem {
                        Image(tab.icon)
                    }
                    .tag(tab.tag)
                }
            }
            .accentColor(.black)
            
            // Show the scan options when scan tab is selected
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
        MainTabView()
            .environmentObject(UserSession())
    }
}
