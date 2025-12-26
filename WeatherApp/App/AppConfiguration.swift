//
//  AppConfiguration.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

enum AppConfiguration {
    static var apiKey: String {
        return value(for: "API_KEY")
    }
    
    static var apiBaseURL: String {
        return "https://" + value(for: "API_BASE_URL")
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
