//
//  CityRepositoryImplTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class CityRepositoryImplTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var cities: [City] = []
    private var queryAdapter: MockQueryAdapter!
    private var responseAdapter: MockResponseAdapter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        cities = mockDataHelper.loadCities()
        queryAdapter = MockQueryAdapter()
        responseAdapter = MockResponseAdapter(cities: cities, weather: mockDataHelper.loadWeather()!)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        cities = []
        queryAdapter = nil
        responseAdapter = nil
    }
    
    func test_repository_httpSuccess() async throws {
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( Data(), stubbedStatusCode: 200)))
        let cityRepositoryImpl = CityRepositoryImpl(client: client, queryAdapter: queryAdapter, responseAdapter: responseAdapter)
        
        let result = try await cityRepositoryImpl.getCities("H")
        XCTAssertEqual(result, cities)
    }
    
    func test_getWeather_httpError_throws() async {
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( Data(), stubbedStatusCode: 500)))
        let cityRepositoryImpl = CityRepositoryImpl(client: client, queryAdapter: queryAdapter, responseAdapter: responseAdapter)

        do {
            _ = try await cityRepositoryImpl.getCities("H")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ServerError)
        }
    }
}
