//
//  DependencyResolverTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
import UIKit
import SwiftUI
@testable import WeatherApp

final class DependencyResolverTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var cities: [City] = []
    private var dependencyResolver: DependencyResolver!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        cities = mockDataHelper.loadCities()
        dependencyResolver = DependencyResolver()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        cities = []
        dependencyResolver = nil
    }

    func test_makeHomeViewController_onCitySelected_pushesUIHostingController() {
        let nav = NavigationControllerSpy()

        let homeViewController = dependencyResolver.makeHomeViewController(navigation: nav)
        homeViewController.loadViewIfNeeded()

        let city = cities.first!

        homeViewController.onCitySelected?(city)
        
        XCTAssertEqual(nav.pushCallCount, 1)
        XCTAssertNotNil(nav.pushedViewController)

        XCTAssertTrue(nav.pushedViewController is UIHostingController<CityView>)
        XCTAssertTrue(nav.lastAnimatedValue ?? false)
    }
}

private final class NavigationControllerSpy: UINavigationController {
    private(set) var pushCallCount = 0
    private(set) var pushedViewController: UIViewController?
    private(set) var lastAnimatedValue: Bool?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushCallCount += 1
        pushedViewController = viewController
        lastAnimatedValue = animated
    }
}
