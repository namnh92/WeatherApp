//
//  GetWeatherUseCase.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol IGetWeatherUseCase {
    func execute(city: City) async throws -> Weather
}

struct GetWeatherUseCase: IGetWeatherUseCase {
    private let repository: IWeatherRepository
    
    init(repository: IWeatherRepository) {
        self.repository = repository
    }
    
    func execute(city: City) async throws -> Weather {
        return try await repository.getWeather(city: city)
    }
}
