import SwiftUI

// Defines categories and their associated colors and icons
enum IngredientCategory: String {
    case vegetable, fruit, grain, protein, dairy, condiment, canned, spice, drink

    var color: Color {
        switch self {
        case .vegetable: return Color(red: 0.14, green: 0.58, blue: 0.14)
        case .fruit: return Color(red: 0.86, green: 0.33, blue: 0.33)
        case .grain: return Color(red: 0.42, green: 0.32, blue: 0.18)
        case .protein: return Color(red: 0.45, green: 0.16, blue: 0.07)
        case .dairy: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .condiment: return Color(red: 0.32, green: 0.69, blue: 0.49)
        case .canned: return Color(red: 0.58, green: 0.18, blue: 0.18)
        case .spice: return Color(red: 0.33, green: 0.34, blue: 0.32)
        case .drink: return Color(red: 0.84, green: 0.73, blue: 0.31)
        }
    }
    
    var defaultEmoji: String {
        switch self {
        case .vegetable: return "🥬"
        case .fruit: return "🍎"
        case .grain: return "🌾"
        case .protein: return "🍗"
        case .dairy: return "🥛"
        case .condiment: return "🧂"
        case .canned: return "🥫"
        case .spice: return "🌶️"
        case .drink: return "🥤"
        }
    }
}

// Maps ingredient names to specific emojis
func emojiForIngredient(_ name: String, in category: IngredientCategory) -> String {
    let lowercaseName = name.lowercased()
    
    // Vegetables
    if lowercaseName == "carrot" { return "🥕" }
    if lowercaseName == "broccoli" { return "🥦" }
    if lowercaseName == "eggplant" || lowercaseName == "aubergine" { return "🍆" }
    if lowercaseName == "potato" { return "🥔" }
    if lowercaseName == "tomato" { return "🍅" }
    if lowercaseName == "cucumber" { return "🥒" }
    if lowercaseName == "corn" { return "🌽" }
    if lowercaseName == "garlic" { return "🧄" }
    if lowercaseName == "onion" { return "🧅" }
    
    // Fruits
    if lowercaseName == "apple" { return "🍎" }
    if lowercaseName == "banana" { return "🍌" }
    if lowercaseName == "orange" { return "🍊" }
    if lowercaseName == "strawberry" { return "🍓" }
    if lowercaseName == "pineapple" { return "🍍" }
    if lowercaseName == "grapes" { return "🍇" }
    
    return category.defaultEmoji
}

// Custom shape for card with flat bottom
struct CardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: 25))
        path.addArc(center: CGPoint(x: rect.width - 25, y: 25),
                    radius: 25,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: 25, y: 0))
        path.addArc(center: CGPoint(x: 25, y: 25),
                    radius: 25,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

// Displays a single ingredient card
struct IngredientCard: View {
    let ingredient: AWSIngredientModel
    let category: IngredientCategory
    
    init(ingredient: AWSIngredientModel, category: IngredientCategory) {
        self.ingredient = ingredient
        self.category = category
        
        
    }
    
    private func fontSizeForText(_ text: String) -> CGFloat {
        if text.count > 15 { return 14 }
        else if text.count > 10 { return 16 }
        else { return 18 }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(category.color)
                .frame(width: 110, height: 150)
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(width: 110, height: 100)
                    .overlay {
                        // Get the image URL directly from the ingredient or generate from category pattern
                        let imageUrl = IngredientImageService.shared.getImageURL(
                            for: ingredient.name,
                            category: ingredient.foodCategory,
                            existingURL: ingredient.imageURL
                        )
                        
                        // Build the view with the image URL
                        VStack {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 80, height: 80)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                case .failure:
                                    // Fall back to emoji if image fails to load - without showing the error
                                    Text(emojiForIngredient(ingredient.name, in: category))
                                        .font(.system(size: 60))
                                        .frame(width: 80, height: 80)
                                @unknown default:
                                    Text(emojiForIngredient(ingredient.name, in: category))
                                        .font(.system(size: 60))
                                        .frame(width: 80, height: 80)
                                }
                            }
                            .frame(width: 80, height: 80)
                            .onAppear {
                                // Remove debug logging for image loading
                            }
                        }
                        .padding(10)
                    }
                Spacer()
            }
            .frame(height: 150)
            
            VStack {
                Spacer()
                Text(ingredient.name.capitalized)
                    .font(.system(size: fontSizeForText(ingredient.name), weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                    .padding(.top, 5)
                    .padding(.bottom, 15)
                    .frame(height: 50)
            }
            .frame(height: 150)
        }
        .frame(width: 110, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// Main page view for displaying ingredients
struct BaseIngredientsPage: View {
    let title: String
    let ingredients: [AWSIngredientModel]
    let category: IngredientCategory
    
    @EnvironmentObject var userSession: UserSession
    @State private var showAddIngredientSheet = false
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var filteredIngredients: [AWSIngredientModel] {
        if searchText.isEmpty {
            return ingredients
        } else {
            return ingredients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.leading, 8)
                
                TextField("Search...", text: $searchText)
                    .padding(.vertical, 8)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                } else {
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredIngredients, id: \.edamamFoodId) { ingredient in
                        IngredientCard(ingredient: ingredient, category: category)
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(action: { showAddIngredientSheet = true }) {
                Text("Add Ingredient")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary2)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showAddIngredientSheet) {
            AddIngredientPopup()
                .environmentObject(userSession)
        }
    }
}

struct BaseIngredientsPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BaseIngredientsPage(
                title: "Vegetables",
                ingredients: [],
                category: .vegetable
            )
        }
        .environmentObject(UserSession())
    }
}
