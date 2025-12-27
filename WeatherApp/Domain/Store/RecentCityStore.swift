//
//  RecentCityStore.swift
//  WeatherApp
//
//  Created by Max Nguyen on 27/12/25.
//

protocol IRecentCityStore {
    func load(_ numberPerPage: Int) -> [City]
    func save(_ city: City)
}
