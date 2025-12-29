//
//  WeatherCache.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import Foundation

class WeatherCache {
    private class Entry {
        let weather: Weather
        let timestamp: Date

        init(weather: Weather, timestamp: Date) {
            self.weather = weather
            self.timestamp = timestamp
        }
    }

    private let cache = NSCache<NSString, Entry>()
    private let now: () -> Date
    private let ttl: TimeInterval

    init(ttl: TimeInterval, now: @escaping () -> Date = Date.init) {
        self.ttl = ttl
        self.now = now
    }
    
    func get(cityId: String) -> Weather? {
        guard let entry = cache.object(forKey: cityId as NSString) else {
            return nil
        }

        if now().timeIntervalSince(entry.timestamp) > ttl {
            cache.removeObject(forKey: cityId as NSString)
            return nil
        }

        return entry.weather
    }

    func set(_ weather: Weather, cityId: String) {
        let entry = Entry(weather: weather, timestamp: now())
        cache.setObject(entry, forKey: cityId as NSString)
    }
}
