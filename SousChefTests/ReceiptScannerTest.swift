import XCTest

@testable import SousChef



class LiveReceiptScannerTests: XCTestCase {

    var scannerVC: LiveReceiptScannerViewController!



    override func setUp() {

        super.setUp()

        scannerVC = LiveReceiptScannerViewController()

    }



    override func tearDown() {

        scannerVC = nil

        super.tearDown()

    }



    func testNormalizeText() {

        XCTAssertEqual(scannerVC.normalizeText("  Apple "), "apple")

        XCTAssertEqual(scannerVC.normalizeText("\nEggs\t"), "eggs")

        XCTAssertEqual(scannerVC.normalizeText(" MILK  "), "milk")

        XCTAssertEqual(scannerVC.normalizeText("Cheese"), "cheese")

    }



    func testRecognizedIngredientFiltering() {

        let testIngredients = ["apple", "banana", "eggs", "sugar", "tofu"]

        for ingredient in testIngredients {

            let normalized = scannerVC.normalizeText(ingredient)

            if scannerVC.commonIngredients.contains(normalized) {

                scannerVC.recognizedItems.append(normalized)

            }

        }


        XCTAssertTrue(scannerVC.recognizedItems.contains("apple"))

        XCTAssertTrue(scannerVC.recognizedItems.contains("banana"))

        XCTAssertTrue(scannerVC.recognizedItems.contains("eggs"))

        XCTAssertTrue(scannerVC.recognizedItems.contains("sugar"))

        XCTAssertTrue(scannerVC.recognizedItems.contains("tofu"))

        XCTAssertFalse(scannerVC.recognizedItems.contains("steak")) // Not in the commonIngredients set

    }

}
