//
//  UserDefaultsRecentCityStoreTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class UserDefaultsRecentCityStoreTests: XCTestCase {
    private let suiteName = "UserDefaultsRecentCityStoreTests-\(UUID().uuidString)"
    private var mockDataHelper: MockDataHelper!
    private var cities: [City] = []
    private var defaults: UserDefaults!
    private var store: UserDefaultsRecentCityStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        cities = mockDataHelper.loadCities()
        defaults = mockDataHelper.makeIsolatedUserDefaults(suiteName: suiteName)
        store = UserDefaultsRecentCityStore(defaults: defaults)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        store = nil
    }

    func test_load_whenEmpty_returnsEmptyArray() {
        let result = store.load(10)
        XCTAssertTrue(result.isEmpty)
    }

    func test_save_thenLoad_returnsSavedCity() {
        let city = cities.first!

        store.save(city)
        let result = store.load(10)

        XCTAssertEqual(result, [city])
    }

    func test_save_sameCityTwice_keepsSingle_andMovesToTop() {
        let city1 = cities.first!
        let city2 = cities.last!

        store.save(city1)
        store.save(city2)
        store.save(city1)

        let result = store.load(10)

        XCTAssertEqual(result, [city1, city2])
    }

    func test_save_moreThan10_keepsLatest10() {
        let city = cities.first!
        
        let moreThan10Cities = (1...15).map { i in
            City(name: city.name + "\(i)",
                 country: city.country,
                 region: city.region,
                 latitude: city.latitude,
                 longitude: city.longitude)
        }

        moreThan10Cities.forEach { store.save($0) }

        let result = store.load(10)

        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result.first?.id, moreThan10Cities.last?.id)
        XCTAssertEqual(result.last?.id, moreThan10Cities[(15-10)].id)
    }

    func test_persists_acrossStoreInstances() {
        let city = cities.first!

        store.save(city)

        let newStore = UserDefaultsRecentCityStore(defaults: defaults)
        let result = newStore.load(10)

        XCTAssertEqual(result, [city])
    }
}
