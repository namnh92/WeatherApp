//
//  City.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol ICity: Codable, Equatable, Hashable {
    var id: String { get }
    var name: String { get }
    var country: String { get }
    var region: String? { get }
    var latitude: Double { get }
    var longitude: Double { get }
}

struct City: ICity {
    let id: String
    let name: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
    
    init(name: String, country: String, region: String?, latitude: Double, longitude: Double) {
        self.id = name + country + (region ?? "") + latitude.description + longitude.description
        self.name = name
        self.country = country
        self.region = region
        self.latitude = latitude
        self.longitude = longitude
    }
}
