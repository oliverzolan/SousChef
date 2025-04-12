import SwiftUI

struct CartItem: Identifiable, Codable {
    let id: UUID
    let name: String
    var price: Double
    var quantity: Int
    
    init(id: UUID = UUID(), name: String, price: Double, quantity: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

class ShoppingList: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    var createdDate: Date
    private var _items: [CartItem]
    var items: [CartItem] {
        get { _items }
        set {
            _items = newValue
            objectWillChange.send()
        }
    }
    
    init(id: UUID = UUID(), name: String, items: [CartItem] = [], createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self._items = items
        self.createdDate = createdDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, items, createdDate
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let items = try container.decode([CartItem].self, forKey: .items)
        let createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.init(id: id, name: name, items: items, createdDate: createdDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(items, forKey: .items)
        try container.encode(createdDate, forKey: .createdDate)
    }
    
    func addItem(_ item: CartItem) {
        items.append(item)
    }
    
    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func total() -> Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
    }
}

class ShoppingCart: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var items: [CartItem]
    
    init(id: UUID = UUID(), items: [CartItem] = []) {
        self.id = id
        self.items = items
    }
    
    enum CodingKeys: String, CodingKey {
        case id, items
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let items = try container.decode([CartItem].self, forKey: .items)
        self.init(id: id, items: items)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(items, forKey: .items)
    }
    
    func total() -> Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
    }
    
    func addItem(_ item: CartItem) {
        items.append(item)
    }
    
    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

struct IngredientResult: Identifiable, Codable {
    var id: String { foodId }
    let foodId: String
    let label: String
    let category: String?
}
