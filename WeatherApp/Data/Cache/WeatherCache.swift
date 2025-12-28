//
//  WeatherCache.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import Foundation

final class WeatherCache {

    private let cache = NSCache<NSString, CacheWeatherEntry>()
    private let ttl: TimeInterval = AppConfiguration.cacheExpiredTime

    func get(cityId: String) -> Weather? {
        guard let entry = cache.object(forKey: cityId as NSString) else {
            return nil
        }

        if Date().timeIntervalSince(entry.timestamp) > ttl {
            cache.removeObject(forKey: cityId as NSString)
            return nil
        }

        return entry.weather
    }

    func set(_ weather: Weather, cityId: String) {
        let entry = CacheWeatherEntry(weather: weather, timestamp: Date())
        cache.setObject(entry, forKey: cityId as NSString)
    }
}

final class CacheWeatherEntry {
    let weather: Weather
    let timestamp: Date

    init(weather: Weather, timestamp: Date) {
        self.weather = weather
        self.timestamp = timestamp
    }
}
