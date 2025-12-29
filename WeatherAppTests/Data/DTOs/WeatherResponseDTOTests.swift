//
//  WeatherResponseDTOTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class CurrentConditionDTOToWeatherTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
    }

    func test_toWeather_mapsAllFieldsSuccessfully() throws {
        let data = mockDataHelper.loadJSON("MockWeatherResponse", bundle: Bundle(for: type(of: self)))
        let dto = try JSONDecoder().decode(WeatherResponseDTO.self, from: data)
        let current = try XCTUnwrap(dto.data.currentCondition.first)

        let weather = current.toWeather()

        XCTAssertNotNil(weather)
        XCTAssertEqual(weather?.iconURL?.absoluteString, "https://cdn.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0008_clear_sky_night.png")
        XCTAssertEqual(weather?.humidity, 68)
        XCTAssertEqual(weather?.description, "Clear ")
        XCTAssertEqual(weather?.temperatureC, 18)
    }
    
    func test_toWeather_whenIconURLArrayEmpty_iconURLBecomesNil() throws {
        let data = mockDataHelper.loadJSON("MockWeatherEmptyIconURLResponse", bundle: Bundle(for: type(of: self)))
        let dto = try JSONDecoder().decode(WeatherResponseDTO.self, from: data)
        let current = try XCTUnwrap(dto.data.currentCondition.first)

        let weather = current.toWeather()

        XCTAssertNotNil(weather)
        XCTAssertNil(weather?.iconURL)
    }
}
