//
//  LoginViewControllerTests.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 3/3/25.
//

import XCTest
@testable import SousChef

class LoginViewControllerTests: XCTestCase {

    var loginViewModel: LoginViewController!

    override func setUp() {
        super.setUp()
        loginViewModel = LoginViewController()
    }

    override func tearDown() {
        loginViewModel = nil
        super.tearDown()
    }

    func testLoginWithEmptyEmailAndPassword() {
        loginViewModel.email = ""
        loginViewModel.password = ""

        loginViewModel.logIn()

        XCTAssertEqual(loginViewModel.errorMessage, "Email and password cannot be empty.")
        XCTAssertFalse(loginViewModel.navigateToHome)
    }

    func testLoginWithEmptyEmail() {
        loginViewModel.email = ""
        loginViewModel.password = "somepassword"

        loginViewModel.logIn()

        XCTAssertEqual(loginViewModel.errorMessage, "Email and password cannot be empty.")
        XCTAssertFalse(loginViewModel.navigateToHome)
    }

    func testLoginWithEmptyPassword() {
        loginViewModel.email = "test@example.com"
        loginViewModel.password = ""

        loginViewModel.logIn()

        XCTAssertEqual(loginViewModel.errorMessage, "Email and password cannot be empty.")
        XCTAssertFalse(loginViewModel.navigateToHome)
    }
}
