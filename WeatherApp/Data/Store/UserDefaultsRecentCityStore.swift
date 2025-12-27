//
//  UserDefaultsRecentCityStore.swift
//  WeatherApp
//
//  Created by Max Nguyen on 27/12/25.
//

import Foundation

class UserDefaultsRecentCityStore: IRecentCityStore {
    private let userDefaults = UserDefaults.standard
    private let key = AppConfiguration.Store.recentCities
    private let maxItem = AppConfiguration.Store.maxItem
    
    func load(_ numberPerPage: Int) -> [City] {
        guard let data = userDefaults.data(forKey: key),
              let cities = try? JSONDecoder().decode([City].self, from: data)
        else {
            return []
        }
        
        return Array(cities.prefix(numberPerPage))
    }
    
    func save(_ city: City) {
        var cities = loadAll()
        
        cities.removeAll { $0.id == city.id }
        cities.insert(city, at: 0)
        
        if cities.count > maxItem {
            cities = Array(cities.prefix(maxItem))
        }
        
        persist(cities)
    }
}

// MARK: - Private function
extension UserDefaultsRecentCityStore {
    private func loadAll() -> [City] {
        guard let data = userDefaults.data(forKey: key),
              let cities = try? JSONDecoder().decode([City].self, from: data)
        else {
            return []
        }
        return cities
    }

    private func persist(_ cities: [City]) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        userDefaults.set(data, forKey: key)
    }
}
