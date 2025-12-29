//
//  JSONHelper.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import Foundation
@testable import WeatherApp

class MockDataHelper {
    func loadWeather() -> Weather? {
        let data = loadJSON("MockWeatherResponse", bundle: Bundle(for: type(of: self)))
        return try! JSONDecoder().decode(WeatherResponseDTO.self, from: data).data.currentCondition.first?.toWeather()
    }
    
    func loadCities() -> [City] {
        let data = loadJSON("MockCitiesResponse", bundle: Bundle(for: type(of: self)))
        return try! JSONDecoder().decode(SearchCityResponseDTO.self, from: data).searchAPI.result.compactMap { $0.toCity() }
    }
    
    func loadJSON(_ name: String, bundle: Bundle) -> Data {
        let url = bundle.url(forResource: name, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    func makeUnitTestURL() -> URL {
        return URL(string: "http://unit-test.com")!
    }
    
    func makeIsolatedUserDefaults(suiteName: String) -> UserDefaults {
        let suiteName = suiteName
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
