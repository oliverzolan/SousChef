//
//  Main.swift
//  SousChef
//
//  Created by Sutter Reynolds on 3/2/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSession: UserSession
    
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
    let tabs: [(view: AnyView, icon: String)] = [
        (AnyView(HomePage()), "home_icon"),
        (AnyView(PantryPage(userSession: UserSession())), "fridge_icon"),
        (AnyView(ScanIngredientPage()), "scan_icon"),
        (AnyView(PantryPage(userSession: UserSession())), "list_icon"),
        (AnyView(ChatbotPage(userSession: UserSession())), "chef_hat_icon")
    ]
    
    //Navigation bar and associated Views
    var body: some View {
        TabView {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                NavigationStack {
                    tab.view
                }
                .tabItem {
                    Image(tab.icon)
                }
                .tag(index)
            }
        }
        .accentColor(.black)
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserSession())
    }
}
