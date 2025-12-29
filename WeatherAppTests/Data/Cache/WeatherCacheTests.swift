//
//  WeatherCacheTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import XCTest
@testable import WeatherApp

final class WeatherCacheTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var weather: Weather!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        weather = mockDataHelper.loadWeather()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        weather = nil
    }
    
    func test_init_withDefaultNow_canStoreAndRead() {
        let cache = WeatherCache(ttl: 60)

        cache.set(weather, cityId: "1")

        XCTAssertEqual(cache.get(cityId: "1"), weather)
    }

    func test_cache_returnsValue_beforeTTLExpires() {
        var time = Date(timeIntervalSince1970: 0)
        let cache = WeatherCache(ttl: 60.0, now: { time })

        cache.set(weather, cityId: "1")

        time = Date(timeIntervalSince1970: 59)
        XCTAssertEqual(cache.get(cityId: "1"), weather)
    }

    func test_cache_expires_afterTTL() {
        var time = Date(timeIntervalSince1970: 0)
        let cache = WeatherCache(ttl: 60.0, now: { time })

        cache.set(weather, cityId: "1")

        time = Date(timeIntervalSince1970: 61)
        XCTAssertNil(cache.get(cityId: "1"))
    }
}
