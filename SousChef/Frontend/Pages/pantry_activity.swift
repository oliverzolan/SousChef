import SwiftUI

struct pantry_activity: View {
    @State private var isPopupVisible: Bool = false // State to control popup visibility

    var body: some View {
        VStack {
            Text("Welcome to Pantry Activity")
                .font(.title)
                .padding()
            
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
                .padding()
            }
            
            Spacer()

            // Plus Button
            Button(action: {
                isPopupVisible.toggle() // Toggle the popup visibility
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .overlay(
            // Popup Box
            isPopupVisible ? PopupView(isVisible: $isPopupVisible) : nil
        )
        .animation(.easeInOut, value: isPopupVisible) // Smooth transition
    }
}
