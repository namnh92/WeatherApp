//
//  MockQueryAdapter.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import Foundation
@testable import WeatherApp

final class MockQueryAdapter: IQueryAdapter {
    func getCities(_ query: String) -> URLRequest {
        return URLRequest(url: URL(string: "http://unit-test.com")!)
    }
    
    func getWeather(latitude: Double, longitude: Double) -> URLRequest {
        return URLRequest(url: URL(string: "http://unit-test.com")!)
    }
}
