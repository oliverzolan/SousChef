import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var homepageController: HomepageController
    @EnvironmentObject var pantryController: PantryController

    @State private var selectedTab = 0
    @State private var isShowingScanOptions = false

    init() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.layer.shadowColor = UIColor.black.cgColor
        tabBarAppearance.layer.shadowOpacity = 0.15
        tabBarAppearance.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBarAppearance.layer.shadowRadius = 6
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
            (AnyView(ChatbotPage()), "chef_hat_icon", "Chef", 4)
        ]
    }
    
    // Navigation bar and associated Views
    var body: some View {
        NavigationStack {
            ZStack {
                // Intercept the Scan tab tap via a custom Binding
                TabView(selection: Binding(
                    get: { selectedTab },
                    set: { newValue in
                        if newValue == 2 {
                            // Instead of switching to tab 2, show the pop-up
                            withAnimation(.spring()) {
                                isShowingScanOptions = true
                            }
                        } else {
                            selectedTab = newValue
                        }
                    }
                )) {
                    HomePage()
                        .tabItem { Label("Home",   systemImage: "house.fill") }
                        .tag(0)

                    PantryPage(userSession: userSession)
                        .tabItem { Label("Pantry", systemImage: "refrigerator.fill") }
                        .tag(1)

                    // Empty placeholder — the user never actually lands here
                    Color.clear
                        .tabItem { Label("Scan",   systemImage: "barcode.viewfinder") }
                        .tag(2)

                    ShoppingListsPage(userSession: _userSession)
                        .tabItem { Label("Shopping", systemImage: "cart.fill") }
                        .tag(3)

                    ChatbotPage()
                        .tabItem {
                            Label {
                                Text("Chef")
                            } icon: {
                                Image("chef_hat_icon")
                                    .renderingMode(.template)
                            }
                        }
                        .tag(4)
                }
                .accentColor(.black)

                // Your scan-options overlay
                if isShowingScanOptions {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { isShowingScanOptions = false }

                    ScanPopOut(isShowing: $isShowingScanOptions)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: isShowingScanOptions)
                        .zIndex(1)
                }
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
