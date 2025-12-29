//
//  ResponseAdapter.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

protocol IResponseAdapter: ICityResponseAdapter, IWeatherResponseAdapter {}

class ResponseAdapter: IResponseAdapter {
    let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }
}

extension ResponseAdapter {
    func handleDecodingError(_ error: Error, data: Data) -> Error {
        if let apiError = try? decoder.decode(ErrorResponseDTO.self, from: data),
           let message = apiError.firstMessage {
            return APIError.server(message)
        }
        return error
    }
}
