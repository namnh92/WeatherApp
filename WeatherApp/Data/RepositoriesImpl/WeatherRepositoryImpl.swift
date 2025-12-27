//
//  WeatherRepositoryImpl.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

struct WeatherRepositoryImpl {
    private let client: HTTPClient
    private let queryAdapter: QueryAdapter
    private let responseAdapter: ResponseAdapter
    
    init(client: HTTPClient, queryAdapter: QueryAdapter, responseAdapter: ResponseAdapter) {
        self.client = client
        self.queryAdapter = queryAdapter
        self.responseAdapter = responseAdapter
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
    func getWeather(latitude: Double, longitude: Double) async throws -> Weather {
        let request = queryAdapter.getWeather(latitude: latitude, longitude: longitude)
        let (data, http) = try await client.data(for: request)
        
        guard (200..<300).contains(http.statusCode) else {
            throw ServerError.httpStatus(http.statusCode)
        }
        
        let weather = try responseAdapter.getWeather(data)
        return weather
    }
}
