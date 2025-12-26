//
//  HomeViewState.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

struct HomeViewState: Equatable {
    var query: String = ""
    var searchResults: [City] = []
    var recentCities: [City] = []
    var isLoading: Bool = false
    var errorMessage: String?
}
