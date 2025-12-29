//
//  QueryAdapter.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

enum QueryAdapterError: Error, Equatable {
    case missingBaseURL
}

protocol IQueryAdapter: ICityQueryAdapter, IWeatherQueryAdapter {}

class QueryAdapter: IQueryAdapter {
    let apiConfig: APIConfig
    let url: URL
    
    init(apiConfig: APIConfig) throws {
        self.apiConfig = apiConfig
        guard let baseURL = apiConfig.apiBaseURL else {
            throw QueryAdapterError.missingBaseURL
        }
        self.url = baseURL.appending(queryItems: [
            .init(name: "format", value: apiConfig.format),
            .init(name: "key", value: apiConfig.apiKey)
        ])
    }
}
