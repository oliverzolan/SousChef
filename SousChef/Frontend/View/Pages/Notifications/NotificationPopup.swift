import SwiftUI

struct NotificationPopup: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @StateObject private var notificationController: NotificationController
    @State private var showingClearConfirmation = false
    
    init(ingredientController: AWSUserIngredientsComponent) {
        _notificationController = StateObject(wrappedValue: NotificationController(ingredientController: ingredientController))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if notificationController.isLoading {
                    ProgressView("Loading notifications...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = notificationController.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error loading notifications")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if notificationController.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No notifications")
                            .font(.headline)
                        Text("You don't have any notifications yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(notificationController.notifications) { notification in
                                NotificationRow(
                                    notification: notification,
                                    onTap: {
                                        notificationController.markAsRead(notification)
                                    },
                                    onDelete: {
                                        notificationController.deleteNotification(notification)
                                    }
                                )
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                Divider()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !notificationController.notifications.isEmpty {
                        Button("Clear All") {
                            showingClearConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                notificationController.fetchNotifications()
            }
            .confirmationDialog(
                "Clear all notifications?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    notificationController.clearAllNotifications()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: notification.isRead ? "circle" : "circle.fill")
                .foregroundColor(notification.isRead ? .gray : .blue)
                .font(.system(size: 12))
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? .gray : .primary)
                    
                    Spacer()
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    }
                }
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(notification.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(notification.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct NotificationPopup_Previews: PreviewProvider {
    static var previews: some View {
        let userSession = UserSession()
        NotificationPopup(ingredientController: AWSUserIngredientsComponent(userSession: userSession))
            .environmentObject(userSession)
    }
}

