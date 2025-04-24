import Foundation

struct AppNotification: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    
    enum NotificationType: String {
        case recipe = "New Recipe"
        case ingredient = "Ingredient"
        case shopping = "Shopping"
        case system = "System"
    }
    
    var type: NotificationType {
        if title.contains("Recipe") {
            return .recipe
        } else if title.contains("Ingredient") {
            return .ingredient
        } else if title.contains("Shopping") {
            return .shopping
        } else {
            return .system
        }
    }
} 