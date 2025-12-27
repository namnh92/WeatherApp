//
//  GetWeatherUseCase.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol IGetWeatherUseCase {
    func execute(lattitude: Double, longitude: Double) async throws -> Weather
}

struct GetWeatherUseCase: IGetWeatherUseCase {
    private let repository: IWeatherRepository
    
    init(repository: IWeatherRepository) {
        self.repository = repository
    }
    
    func execute(lattitude: Double, longitude: Double) async throws -> Weather {
        return try await repository.getWeather(latitude: lattitude, longitude: longitude)
    }
}
