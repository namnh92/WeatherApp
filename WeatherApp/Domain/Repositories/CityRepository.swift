//
//  CityRepository.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol ICityRepository {
    func getCities(_ query: String) async throws -> [City]
}
