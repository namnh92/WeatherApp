//
//  QueryAdapter.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

class QueryAdapter {
    let apiConfig: APIConfig
    let url: URL
    
    init(apiConfig: APIConfig) {
        self.apiConfig = apiConfig
        guard let baseURL = apiConfig.apiBaseURL else {
            fatalError("API base URL is required")
        }
        self.url = baseURL.appending(queryItems: [
            .init(name: "format", value: apiConfig.format),
            .init(name: "key", value: apiConfig.apiKey)
        ])
    }
}
