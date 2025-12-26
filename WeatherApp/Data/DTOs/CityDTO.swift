//
//  CityDTO.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

struct CityDTO: Decodable {
    let areaName: [ValueDTO]
    let country: [ValueDTO]
    let region: [ValueDTO]
    let latitude: String
    let longitude: String
}

extension CityDTO {
    func toCity() -> City? {
        guard let name = self.areaName.first?.value,
              let country = self.country.first?.value,
              let latitude = Double(self.latitude),
              let longitude = Double(self.longitude) else { return nil }
        
        return City(name: name,
                    country: country,
                    region: self.region.first?.value,
                    latitude: latitude,
                    longitude: longitude)
    }
}
