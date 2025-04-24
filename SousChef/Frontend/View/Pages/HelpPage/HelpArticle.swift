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
        ),
        .init(
            id: "shoppingLists",
            title: "Managing Shopping Lists",
            summary: "Learn how to create, add items to, and delete shopping lists.",
            content: """
            # Managing Shopping Lists

            ## Creating a New List

            1. Tap the **Shopping** tab.
            2. Press **Create Shopping List**.
            3. Enter a name and tap **Add**.

            ## Adding Items to a List

            1. Open your shopping list.
            2. Tap the **+** button in the top-right corner.
            3. Search or type an ingredient name.
            4. Set the quantity and tap **Add**.

            ## Deleting Items or Lists

            - **Delete an item:**
              1. Swipe left on the item.
              2. Tap **Delete**.
            - **Delete a list:**
              1. From the **Shopping** tab, swipe left on the list.
              2. Tap **Delete**.
            """
        ),
        .init(
            id: "pantryCategories",
            title: "Organizing Your Pantry",
            summary: "Explore organizing your pantry by categories for easy navigation.",
            content: """
            # Organizing Your Pantry

            ## Viewing by Category

            1. Tap the **Pantry** tab.
            2. Use the **Category** dropdown at the top.
            3. Select a category to filter ingredients (e.g. Baking, Spices, Dairy).

            ## Adding or Editing Categories

            1. In **Pantry**, tap **Edit Categories**.
            2. Tap **+** to add a new category.
            3. Enter a name and choose an icon.
            4. Tap **Save**.

            ## Assigning an Item to a Category

            1. In your pantry list, swipe left on an item.
            2. Tap **Edit**.
            3. Choose a **Category** from the dropdown.
            4. Tap **Save**.
            """
        ),
        .init(
            id: "addFromRecipe",
            title: "Adding Recipe Ingredients to Your Shopping List",
            summary: "Quickly move missing recipe ingredients into your shopping list.",
            content: """
            # Adding Recipe Ingredients to Your Shopping List

            1. Go to the **Recipes** tab.
            2. Select the recipe you want to make.
            3. Tap **Missing Ingredients** at the bottom.
            4. Review the list of items you don’t have.
            5. Tap **Add All** to move missing items into your shopping list.

            - **Tip:** You can uncheck any ingredients you already have before adding.
            """
        )
    ]
}
