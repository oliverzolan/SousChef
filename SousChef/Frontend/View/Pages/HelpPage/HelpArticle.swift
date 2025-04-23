import SwiftUI

struct HelpArticle: Identifiable {
    let id: String
    let title: String
    let summary: String
    let content: String

    static let all: [HelpArticle] = [
        .init(
            id: "scanner",
            title: "How to Use the Scanner",
            summary: "Quickly add items to your pantry using barcode, OCR or receipt scanning.",
            content: """
            # How to Use the Scanner

            Opening the Scanner

            1. Tap the **Scanner** icon in the bottom tab bar.
            2. You’ll see four options:

            ## 1. Scan Barcode

            - **What it does:** Reads the UPC/barcode on packaged goods.
            - **How to use:**
              1. Align the barcode inside the rectangle.
              2. Hold steady until recognized.
              3. Tap **Add to Pantry**.

            ## 2. Scan Ingredient

            - **What it does:** OCRs a single ingredient line (e.g. “2 cups flour”).
            - **How to use:**
              1. Frame only the ingredient text.
              2. Correct any mistakes.
              3. Tap **Add**.

            ## 3. Scan Receipt

            - **What it does:** Batch-imports items from your grocery receipt.
            - **How to use:**
              1. Lay the receipt flat.
              2. Slide camera top→bottom.
              3. Uncheck any unwanted lines.
              4. Tap **Add All**.

            ## 4. Choose from Gallery

            - **What it does:** Processes an existing photo of a barcode, ingredient list, or receipt.
            - **How to use:**
              1. Tap **Choose from Gallery**.
              2. Pick your photo.
              3. The app scans it just like live capture.

            Once recognized, each item is normalized into your pantry and stored locally.
            """
        ),
        .init(
            id: "search",
            title: "Searching for Recipes",
            summary: "Learn how to filter and find exactly what you want.",
            content: """
            # Searching for Recipes

            1. Tap the **Search** tab.
            2. Enter keywords (e.g. “chicken curry”).
            3. Use the **Filters** button to narrow by diet, cuisine, prep time, etc.
            4. Tap **Search** and browse your results.

            You can also sort by popularity or newest creation date.
            """
        )
    ]
}
