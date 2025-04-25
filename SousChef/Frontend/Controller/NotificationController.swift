import SwiftUI
import Combine

class NotificationController: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var unreadCount: Int = 0

    private var cancellables = Set<AnyCancellable>()
    private let ingredientController: AWSUserIngredientsComponent

    init(ingredientController: AWSUserIngredientsComponent) {
        self.ingredientController = ingredientController
        updateUnreadCount()
    }

    // MARK: - Public Methods

    func fetchNotifications() {
        isLoading = true
        errorMessage = nil

        ingredientController.getExpiringIngredients { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let ingredients):
                    self.notifications = ingredients.map { ingredient in
                        AppNotification(
                            id: UUID().uuidString,
                            title: "Ingredient Expiring",
                            message: "\(ingredient.name) is expiring in \(ingredient.days_left) day(s)",
                            timestamp: Date(), // or use ingredient.date_added if you prefer
                            isRead: false
                        )
                    }
                    self.updateUnreadCount()

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.notifications = []
                    self.updateUnreadCount()
                }
            }
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
