//
//  WeatherResponseDTO.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation

struct WeatherResponseDTO: Decodable {
    let data: WeatherDTO
}

struct WeatherDTO: Decodable {
    let currentCondition: [CurrentConditionDTO]
    
    private enum CodingKeys: String, CodingKey {
        case currentCondition = "current_condition"
    }
}

struct CurrentConditionDTO: Decodable {
    let iconURL: [ValueDTO]
    let description: [ValueDTO]
    let temperatureC: String
    let humidity: String
    
    private enum CodingKeys: String, CodingKey {
        case iconURL = "weatherIconUrl"
        case description = "weatherDesc"
        case temperatureC = "temp_C"
        case humidity = "humidity"
    }
}

extension CurrentConditionDTO {
    func toWeather() -> Weather? {
        return Weather(iconURL: URL(string: self.iconURL.first?.value ?? ""),
                       humidity: Int(self.humidity),
                       description: self.description.first?.value,
                       temperatureC: Int(self.temperatureC))
    }
}
