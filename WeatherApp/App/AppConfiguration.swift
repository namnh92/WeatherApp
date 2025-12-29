//
//  AppConfiguration.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

enum AppConfigurationError: Error, Equatable {
    case missingOrEmpty(String)
}

enum AppConfiguration {
    enum API {
        static var apiKey: String {
            return try! value(for: "API_KEY")
        }
        
        static var apiBaseURL: String {
            return "https://" + (try! value(for: "API_BASE_URL"))
        }
        
        static var format: String {
            return "json"
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
    
    static var cacheExpiredTime: TimeInterval {
        return 60.0
    }
    
    static func value(for key: String, bundle: Bundle = .main) throws -> String {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            throw AppConfigurationError.missingOrEmpty(key)
        }
        return value
    }
}
