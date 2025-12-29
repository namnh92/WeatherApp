//
//  WeatherRepositoryImplTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import XCTest
@testable import WeatherApp

final class WeatherRepositoryImpTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var weather: Weather!
    private var city: City!
    private var queryAdapter: MockQueryAdapter!
    private var responseAdapter: MockResponseAdapter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        weather = mockDataHelper.loadWeather()
        city = mockDataHelper.loadCities().first
        queryAdapter = MockQueryAdapter()
        responseAdapter = MockResponseAdapter(weather: weather)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        weather = nil
        city = nil
        queryAdapter = nil
        responseAdapter = nil
    }
    
    func test_repository_usesCache_withinTTL() async throws {
        var time = Date(timeIntervalSince1970: 0)
        let cache = WeatherCache(ttl: 60.0, now: { time })
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( Data(), stubbedStatusCode: 200)))
        let weatherRepositoryImpl = WeatherRepositoryImpl(client: client, queryAdapter: queryAdapter, responseAdapter: responseAdapter, cache: cache)
        
        let firstResult = try await weatherRepositoryImpl.getWeather(city: city)
        XCTAssertEqual(client.callCount, 1)
        XCTAssertEqual(firstResult, weather)
        
        time = Date(timeIntervalSince1970: 30)
        let cached = try await weatherRepositoryImpl.getWeather(city: city)
        XCTAssertEqual(client.callCount, 1)
        XCTAssertEqual(cached, weather)
    }
    
    func test_repository_refetches_afterTTL() async throws {
        var time = Date(timeIntervalSince1970: 0)
        let cache = WeatherCache(ttl: 60.0, now: { time })
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( Data(), stubbedStatusCode: 200)))
        let weatherRepositoryImpl = WeatherRepositoryImpl(client: client, queryAdapter: queryAdapter, responseAdapter: responseAdapter, cache: cache)
        
        let firstResult = try await weatherRepositoryImpl.getWeather(city: city)
        XCTAssertEqual(client.callCount, 1)
        XCTAssertEqual(firstResult, weather)
        
        time = Date(timeIntervalSince1970: 61)
        let secondResult = try await weatherRepositoryImpl.getWeather(city: city)
        XCTAssertEqual(client.callCount, 2)
        XCTAssertEqual(secondResult, weather)
    }
    
    func test_getWeather_httpError_throws() async {
        let cache = WeatherCache(ttl: 60.0)
        let client = MockURLSessionHTTPClient(stubbedResult: .success(( Data(), stubbedStatusCode: 500)))
        let weatherRepositoryImpl = WeatherRepositoryImpl(client: client, queryAdapter: queryAdapter, responseAdapter: responseAdapter, cache: cache)

        do {
            _ = try await weatherRepositoryImpl.getWeather(city: city)
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ServerError)
        }
    }
}
