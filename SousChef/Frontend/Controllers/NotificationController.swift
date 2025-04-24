import SwiftUI
import Combine

class NotificationController: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var unreadCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with empty notifications
        updateUnreadCount()
    }
    
    // MARK: - Public Methods
    
    func fetchNotifications() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Replace with actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.notifications = [
                AppNotification(id: "1", title: "New Recipe Available", message: "Check out our new recipe for pasta carbonara!", timestamp: Date(), isRead: false),
                AppNotification(id: "2", title: "Ingredient Expiring", message: "Your milk will expire in 2 days", timestamp: Date().addingTimeInterval(-3600), isRead: true),
                AppNotification(id: "3", title: "Shopping List Updated", message: "Your shopping list has been updated with new items", timestamp: Date().addingTimeInterval(-7200), isRead: false)
            ]
            self.updateUnreadCount()
        }
    }
    
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateUnreadCount()
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
        updateUnreadCount()
    }
    
    func deleteNotification(_ notification: AppNotification) {
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
    }
    
    // MARK: - Private Methods
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
} 