//
//  ErrorResponseDTO.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

struct ErrorResponseDTO: Decodable {
    let data: ErrorDataDTO
}

struct ErrorDataDTO: Decodable {
    let error: [ErrorItemDTO]
}

struct ErrorItemDTO: Decodable {
    let msg: String
}

extension ErrorResponseDTO {
    var firstMessage: String? {
        data.error.first?.msg
    }
}
