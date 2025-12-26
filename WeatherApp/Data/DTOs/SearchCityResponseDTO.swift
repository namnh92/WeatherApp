//
//  SearchCityResponseDTO.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

struct SearchCityResponseDTO: Decodable {
    struct SearchAPI: Decodable {
        let result: [CityDTO]
    }
    
    let searchAPI: SearchAPI
    
    private enum CodingKeys: String, CodingKey {
        case searchAPI = "search_api"
    }
}

