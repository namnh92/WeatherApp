//
//  CityViewState.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

struct CityViewState: Equatable {
    var isLoading: Bool = false
    var weather: Weather?
    var errorMessage: String?
}
