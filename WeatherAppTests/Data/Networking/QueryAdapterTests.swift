//
//  QueryAdapterTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class QueryAdapterTests: XCTestCase {
    private var queryAdapter: QueryAdapter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        queryAdapter = try! QueryAdapter(apiConfig: APIConfig(apiKey: AppConfiguration.API.apiKey, apiBaseURL: URL(string: AppConfiguration.API.apiBaseURL), format: AppConfiguration.API.format))
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        queryAdapter = nil
    }
    
    func test_init_whenBaseURLNil_throwsMissingBaseURL() {
        let config = APIConfig(apiKey: AppConfiguration.API.apiKey, apiBaseURL: nil, format: AppConfiguration.API.format)

        XCTAssertThrowsError(try QueryAdapter(apiConfig: config)) { error in
            XCTAssertEqual(error as? QueryAdapterError, .missingBaseURL)
        }
    }

    func test_getCities_buildsCorrectGETRequest() throws {
        let request = queryAdapter.getCities("H")

        XCTAssertEqual(request.httpMethod, "GET")
        let url = try XCTUnwrap(request.url)

        XCTAssertEqual(url.path, "/premium/v1/\(Endpoint.city.rawValue)")

        let items = try queryItems(url)

        XCTAssertEqual(items["format"], "json")
        XCTAssertEqual(items["key"], AppConfiguration.API.apiKey)
        XCTAssertEqual(items["query"], "H")
        XCTAssertEqual(items["num_of_results"], "10")
    }

    func test_getWeather_buildsCorrectGETRequest() throws {
        let request = queryAdapter.getWeather(latitude: 12.3, longitude: 123.4)

        XCTAssertEqual(request.httpMethod, "GET")
        let url = try XCTUnwrap(request.url)

        XCTAssertEqual(url.path, "/premium/v1/\(Endpoint.weather.rawValue)")

        let items = try queryItems(url)

        XCTAssertEqual(items["format"], "json")
        XCTAssertEqual(items["key"], AppConfiguration.API.apiKey)
        XCTAssertEqual(items["query"], "12.3,123.4")
        XCTAssertEqual(items["num_of_days"], "1")
    }
}

// MARK: - Private function
private extension QueryAdapterTests {
    func queryItems(_ url: URL) throws -> [String: String] {
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = components.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }
}
