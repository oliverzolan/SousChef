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
    @State private var isEditingMode = false
    @State private var selectedIngredients: Set<String> = [] // Using food IDs to track selection
    @State private var showDeleteAlert = false
    @State private var isDeleting = false
    
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
                if isEditingMode {
                    Text("Tap ingredients to select them for deletion")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredIngredients, id: \.edamamFoodId) { ingredient in
                        if isEditingMode {
                            // When in edit mode, wrap with selectable version
                            SelectableIngredientCard(
                                ingredient: ingredient, 
                                category: category,
                                isSelected: selectedIngredients.contains(ingredient.edamamFoodId)
                            )
                            .onTapGesture {
                                toggleSelection(ingredient)
                            }
                        } else {
                            // Normal display mode
                            IngredientCard(ingredient: ingredient, category: category)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditingMode {
                    Button(action: {
                        if !selectedIngredients.isEmpty {
                            showDeleteAlert = true
                        } else {
                            isEditingMode = false
                        }
                    }) {
                        if selectedIngredients.isEmpty {
                            Text("Cancel")
                                .foregroundColor(.blue)
                        } else {
                            Text("Delete \(selectedIngredients.count)")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    Button(action: {
                        isEditingMode = true
                        selectedIngredients.removeAll()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isEditingMode && !selectedIngredients.isEmpty {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Selected (\(selectedIngredients.count))")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
                .background(Color(.systemBackground))
            } else if !isEditingMode {
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
        }
        .sheet(isPresented: $showAddIngredientSheet) {
            AddIngredientPopup()
                .environmentObject(userSession)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Ingredients"),
                message: Text("Are you sure you want to delete the selected ingredients from your pantry?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteSelectedIngredients()
                },
                secondaryButton: .cancel()
            )
        }
        .overlay(
            Group {
                if isDeleting {
                    ZStack {
                        Color.black.opacity(0.4)
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Deleting...")
                                .foregroundColor(.white)
                                .padding(.top)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }
    
    private func toggleSelection(_ ingredient: AWSIngredientModel) {
        if selectedIngredients.contains(ingredient.edamamFoodId) {
            selectedIngredients.remove(ingredient.edamamFoodId)
        } else {
            selectedIngredients.insert(ingredient.edamamFoodId)
        }
    }
    
    private func deleteSelectedIngredients() {
        guard !selectedIngredients.isEmpty else { return }
        
        isDeleting = true
        let api = AWSUserIngredientsComponent(userSession: userSession)
        let dispatchGroup = DispatchGroup()
        
        for foodId in selectedIngredients {
            if let ingredient = ingredients.first(where: { $0.edamamFoodId == foodId }) {
                dispatchGroup.enter()
                
                Task {
                    await api.deleteIngredient(ingredient: ingredient) { result in
                        switch result {
                        case .success:
                            print("Successfully deleted \(ingredient.name)")
                        case .failure(let error):
                            print("Failed to delete \(ingredient.name): \(error.localizedDescription)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            isDeleting = false
            isEditingMode = false
            selectedIngredients.removeAll()
            
            // Post notification to refresh pantry contents
            NotificationCenter.default.post(name: NSNotification.Name("RefreshPantryContents"), object: nil)
        }
    }
}

// Add selectable ingredient card component
struct SelectableIngredientCard: View {
    let ingredient: AWSIngredientModel
    let category: IngredientCategory
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            IngredientCard(ingredient: ingredient, category: category)
                .opacity(isSelected ? 0.7 : 1.0)
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(Circle())
                    .padding(8)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
        )
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
