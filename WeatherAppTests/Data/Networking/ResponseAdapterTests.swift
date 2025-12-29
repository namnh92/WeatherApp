//
//  ResponseAdapterTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class ResponseAdapterTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var responseAdapter: ResponseAdapter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        responseAdapter = ResponseAdapter(decoder: JSONDecoder())
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        responseAdapter = nil
    }
    
    func test_getCities_decodesAndMapsCitiesSuccessfully() throws {
        let json = mockDataHelper.loadJSON("MockCitiesResponse", bundle: Bundle(for: type(of: self)))

        let cities = try responseAdapter.getCities(json)

        XCTAssertEqual(cities.count, 2)
        XCTAssertEqual(cities[0].name, "Hong Kong")
        XCTAssertEqual(cities[0].country, "Hong Kong")
        XCTAssertEqual(cities[1].name, "Hong Kong")
        XCTAssertEqual(cities[1].country, "Mexico")
    }
    
    func test_getWeather_decodesAndMapsWeatherSuccessfully() throws {
        let json = mockDataHelper.loadJSON("MockWeatherResponse", bundle: Bundle(for: type(of: self)))

        let weather = try responseAdapter.getWeather(json)

        XCTAssertEqual(weather.iconURL, URL(string: "https://cdn.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0008_clear_sky_night.png"))
        XCTAssertEqual(weather.humidity, 68)
        XCTAssertEqual(weather.description, "Clear ")
        XCTAssertEqual(weather.temperatureC, 18)
    }
    
    func test_whenInvalidJSON_throwsHandledError() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(try responseAdapter.getCities(invalidJSON)) { error in
            XCTAssertNotNil(error)
        }
    }

    func test_whenAPIResponseError_throwsHandledError() {
        let errorAPIResponseJSON = MockDataHelper().loadJSON("MockErrorAPIResponse", bundle: Bundle(for: type(of: self)))

        XCTAssertThrowsError(try responseAdapter.getWeather(errorAPIResponseJSON)) { error in
            guard let apiError = error as? APIError else {
                return XCTFail("Expected APIError, got \(type(of: error))")
            }
            XCTAssertEqual(apiError, .server("Unable to find any matching weather location to the query submitted!"))
        }
    }
    
    
    func test_getWeather_unknownError_throws() async {
        let json = mockDataHelper.loadJSON("MockWeatherUnknowResponse", bundle: Bundle(for: type(of: self)))
        
        XCTAssertThrowsError(try responseAdapter.getWeather(json)) { error in
            guard let apiError = error as? APIError else {
                return XCTFail("Expected APIError, got \(type(of: error))")
            }
            XCTAssertEqual(apiError, .unknown)
        }
    }
}
