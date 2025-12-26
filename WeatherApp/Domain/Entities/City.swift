//
//  City.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol ICity: Equatable, Hashable {
    var name: String { get }
    var country: String { get }
    var region: String? { get }
    var latitude: Double { get }
    var longitude: Double { get }
}

struct City: ICity {
    let name: String
    let country: String
    let region: String?
    let latitude: Double
    let longitude: Double
}
