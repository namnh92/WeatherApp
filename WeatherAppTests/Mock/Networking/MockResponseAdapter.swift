//
//  MockResponseAdapter.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import Foundation
@testable import WeatherApp

final class MockResponseAdapter: IResponseAdapter {
    private var cities: [City] = []
    private let weather: Weather?

    init(cities: [City] = [], weather: Weather?) {
        self.cities = cities
        self.weather = weather
    }
    
    func getWeather(_ data: Data) throws -> Weather {
        return weather!
    }
    
    func getCities(_ data: Data) throws -> [WeatherApp.City] {
        return cities
    }
}
