//
//  WeatherRepositoryImpl.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

protocol IWeatherQueryAdapter {
    func getWeather(latitude: Double, longitude: Double) -> URLRequest
}

protocol IWeatherResponseAdapter {
    func getWeather(_ data: Data) throws -> Weather
}

struct WeatherRepositoryImpl {
    private let client: HTTPClient
    private let queryAdapter: IQueryAdapter
    private let responseAdapter: IResponseAdapter
    private let cache: WeatherCache
    
    init(client: HTTPClient, queryAdapter: IQueryAdapter, responseAdapter: IResponseAdapter, cache: WeatherCache) {
        self.client = client
        self.queryAdapter = queryAdapter
        self.responseAdapter = responseAdapter
        self.cache = cache
    }
}

// MARK: - QueryAdapter
extension QueryAdapter {
    func getWeather(latitude: Double, longitude: Double) -> URLRequest {
        var request = URLRequest(url: url.appendingPathComponent(Endpoint.weather.rawValue))
        request.httpMethod = "GET"
        request.url?.append(queryItems: [
            .init(name: "query", value: "\(latitude),\(longitude)"),
            .init(name: "num_of_days", value: "1")
        ])
        return request
    }
}

// MARK: - ResponseAdapter
extension ResponseAdapter {
    func getWeather(_ data: Data) throws -> Weather {
        do {
            let response = try decoder.decode(WeatherResponseDTO.self, from: data)
            guard let weather = response.data.currentCondition.first?.toWeather() else {
                throw APIError.unknown
            }
            return weather
        } catch {
            throw handleDecodingError(error, data: data)
        }
    }
}

// MARK: - ICityRepository
extension WeatherRepositoryImpl: IWeatherRepository {
    func getWeather(city: City) async throws -> Weather {
        if let cached = cache.get(cityId: city.id) {
            return cached
        }
        
        let request = queryAdapter.getWeather(latitude: city.latitude, longitude: city.longitude)
        let (data, http) = try await client.data(for: request)
        
        guard (200..<300).contains(http.statusCode) else {
            throw ServerError.httpStatus(http.statusCode)
        }
        
        let weather = try responseAdapter.getWeather(data)
        cache.set(weather, cityId: city.id)
        return weather
    }
}
