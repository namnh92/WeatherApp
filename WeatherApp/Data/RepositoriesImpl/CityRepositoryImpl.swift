//
//  CityRepositoryImpl.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

protocol ICityQueryAdapter {
    func getCities(_ query: String) -> URLRequest
}

protocol ICityResponseAdapter {
    func getCities(_ data: Data) throws -> [City]
}

struct CityRepositoryImpl {
    private let client: HTTPClient
    private let queryAdapter: IQueryAdapter
    private let responseAdapter: IResponseAdapter
    
    init(client: HTTPClient, queryAdapter: IQueryAdapter, responseAdapter: IResponseAdapter) {
        self.client = client
        self.queryAdapter = queryAdapter
        self.responseAdapter = responseAdapter
    }
}

// MARK: - QueryAdapter
extension QueryAdapter {
    func getCities(_ query: String) -> URLRequest {
        var request = URLRequest(url: url.appendingPathComponent(Endpoint.city.rawValue))
        request.httpMethod = "GET"
        request.url?.append(queryItems: [
            .init(name: "query", value: query),
            .init(name: "num_of_results", value: "10")
        ])
        return request
    }
}

// MARK: - ResponseAdapter
extension ResponseAdapter {
    func getCities(_ data: Data) throws -> [City] {
        do {
            let response = try decoder.decode(SearchCityResponseDTO.self, from: data)
            return response.searchAPI.result.compactMap { $0.toCity() }
        } catch {
            throw handleDecodingError(error, data: data)
        }
    }
}

// MARK: - ICityRepository
extension CityRepositoryImpl: ICityRepository {
    func getCities(_ query: String) async throws -> [City] {
        let request = queryAdapter.getCities(query)
        let (data, http) = try await client.data(for: request)
        
        guard (200..<300).contains(http.statusCode) else {
            throw ServerError.httpStatus(http.statusCode)
        }
        
        let cities = try responseAdapter.getCities(data)
        return cities
    }
}
