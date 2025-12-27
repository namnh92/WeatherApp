//
//  AppConfiguration.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

enum AppConfiguration {
    enum API {
        static var apiKey: String {
            return value(for: "API_KEY")
        }
        
        static var apiBaseURL: String {
            return "https://" + value(for: "API_BASE_URL")
        }
    }
    
    enum Store {
        static var recentCities: String {
            return "recentCities"
        }
        
        static var maxItem: Int {
            return 10
        }
    }
    
    static var debounceTime: TimeInterval {
        return 1.0
    }
    
    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Missing or empty \(key) in Info.plist / xcconfig")
        }
        return value
    }
}
