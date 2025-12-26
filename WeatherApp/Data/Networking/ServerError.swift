//
//  ServerError.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

enum ServerError: Error, Equatable {
    case httpStatus(Int)
}
