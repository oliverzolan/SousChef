import SwiftUI

struct HomePage: View {
    
    @EnvironmentObject var userSession: UserSession // Access shared user session

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    

                    
                    // 🔹 Greeting Section
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(LinearGradient(gradient: Gradient(colors: [AppColors.gradientCardLight, AppColors.gradientCardDark]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 180)
                            .edgesIgnoringSafeArea(.top)
                        
                        HStack {
                            Text(
                                    userSession.fullName?.isEmpty == false
                                    ? "Welcome Chef \n\(userSession.fullName!)"
                                    : "Welcome Chef"
                                )
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                            Spacer()

                            // Profile Button
                            NavigationLink(destination: ProfilePage().navigationBarBackButtonHidden(true)) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 20)
                            }
                        }
                    }

                    // 🔹 Search Bar
                    HStack {
                        Image(systemName: "line.horizontal.3")
                            .padding(.leading, 8)
                        TextField("Search Recipes . . .", text: .constant(""))
                            .padding(.leading, 5)
                            .frame(height: 50)
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing, 8)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.9), AppColors.gradientSearchBar]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // 🔹 Category ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(["Mexican", "BBQ", "Chinese", "Italian", "Indian", "Korean"], id: \.self) { category in
                                Text(category)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(AppColors.cardColor)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    }

                    Spacer()

                    // 🔹 Recipe Card Section
                    HStack(spacing: 20) {
                        ZStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Spacer()
                                Text("Recipes")
                                    .font(.headline)
                                    .padding(.bottom, 10)
                                    .foregroundColor(.white)

                                Text("Recipe content goes here")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.cardColor)
                            .cornerRadius(20)

                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20))
                                        .padding(10)
                                        .foregroundColor(.yellow)
                                }
                                Spacer()
                            }
                            .cornerRadius(20)
                        }
                        .padding(.horizontal)
                    }

                    // 🔹 Scan & Shopping List Buttons
                    HStack(spacing: 20) {
                        NavigationLink(destination: ReceiptPage()) {
                            VStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 30))
                                    .padding(.bottom, 5)
                                    .foregroundColor(.white)
                                Text("Scan Receipt")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardColor)
                        .cornerRadius(20)

                        VStack {
                            Image(systemName: "cart")
                                .font(.system(size: 30))
                                .padding(.bottom, 5)
                                .foregroundColor(.white)
                            Text("Shopping List")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardColor)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)

                   
                    
                    
                    CustomNavigationBar()
                        .frame(maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width)
                .background(AppColors.background)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserSession())
            .previewDevice("iPhone 16 Pro")
    }
}
