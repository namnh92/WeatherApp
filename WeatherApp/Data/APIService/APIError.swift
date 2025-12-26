//
//  APIError.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

enum APIError: Error, Equatable {
    case server(String)
    case decoding
    case network
    case unknown
}

extension APIError {
    var userMessage: String {
        switch self {
        case .server(let message): return message
        case .network: return "Network error. Please try again."
        case .decoding: return "Invalid server response."
        case .unknown: return "Something went wrong."
        }
    }
}
