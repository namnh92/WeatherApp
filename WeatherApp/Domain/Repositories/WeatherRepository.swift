//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol IWeatherRepository {
    func getWeather(city: City) async throws -> Weather
}
