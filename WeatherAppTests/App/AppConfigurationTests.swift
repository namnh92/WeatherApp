//
//  AppConfigurationTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class AppConfigurationTests: XCTestCase {
    func test_cacheExpiredTime_is60Seconds() {
        XCTAssertEqual(AppConfiguration.cacheExpiredTime, 60.0)
    }
    
    func test_value_whenKeyExists_returnsNonEmptyString() throws {
        let value = try AppConfiguration.value(for: "API_BASE_URL", bundle: .main)

        XCTAssertEqual(value, "api.worldweatheronline.com/premium/v1/")
    }

    func test_value_whenKeyMissing_throwsMissingOrEmpty() {
        XCTAssertThrowsError(try AppConfiguration.value(for: "a", bundle: .main)) { error in
            XCTAssertEqual(error as? AppConfigurationError, .missingOrEmpty("a"))
        }
    }
}
