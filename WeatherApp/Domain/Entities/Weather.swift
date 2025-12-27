//
//  Weather.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

protocol IWeather: Equatable, Hashable {
    var iconURL: URL? { get }
    var humidity: Int? { get }
    var description: String? { get }
    var temperatureC: Int? { get }
}

struct Weather: IWeather {
    let iconURL: URL?
    let humidity: Int?
    let description: String?
    let temperatureC: Int?
}
