//
//  GetRecentCityUseCaseTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class GetRecentCityUseCaseTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var cities: [City] = []
    private var store: MockRecentCityStore!
    private var getRecentCityUseCase: GetRecentCityUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        cities = mockDataHelper.loadCities()
        store = MockRecentCityStore(cities: mockDataHelper.loadCities())
        getRecentCityUseCase = GetRecentCityUseCase(store: store)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        cities = []
        store = nil
        getRecentCityUseCase = nil
    }
    
    func test_save() async throws {
        getRecentCityUseCase.save(cities.first!)
        
        XCTAssertEqual(store.callCount, 1)
    }
    
    func test_load() async throws {
        let result = getRecentCityUseCase.execute(AppConfiguration.Store.maxItem)
        
        XCTAssertEqual(store.callCount, 1)
        XCTAssertEqual(result, cities)
    }
}

private final class MockRecentCityStore: IRecentCityStore {
    var cities: [City]
    var callCount = 0
    
    init(cities: [City]) {
        self.cities = cities
    }
    
    func load(_ numberPerPage: Int) -> [City] {
        callCount+=1
        return cities
    }
    
    func save(_ city: City) {
        callCount+=1
    }
}

