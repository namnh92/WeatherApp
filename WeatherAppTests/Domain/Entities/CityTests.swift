//
//  CityTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class CityTests: XCTestCase {
    func test_init_generatesExpectedId_withRegion() {
        let city = City(
            name: "Hanoi",
            country: "Vietnam",
            region: "Ha Noi",
            latitude: 12.3,
            longitude: 123.4
        )
        
        let expectedId =
        "Hanoi" +
        "Vietnam" +
        "Ha Noi" +
        12.3.description +
        123.4.description
        
        XCTAssertEqual(city.id, expectedId)
    }
    
    func test_init_generatesExpectedId_withoutRegion() {
        let city = City(
            name: "Hanoi",
            country: "Vietnam",
            region: nil,
            latitude: 12.3,
            longitude: 123.4
        )
        
        let expectedId =
        "Hanoi" +
        "Vietnam" +
        "" +
        12.3.description +
        123.4.description
        
        XCTAssertEqual(city.id, expectedId)
    }
    
    func test_equatable_sameInput_isEqual() {
        let a = City(name: "Hanoi", country: "Vietnam", region: "Ha Noi", latitude: 12.3, longitude: 123.4)
        let b = City(name: "Hanoi", country: "Vietnam", region: "Ha Noi", latitude: 12.3, longitude: 123.4)
        
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.id, b.id)
    }
    
    func test_equatable_differentInput_isNotEqual() {
        let a = City(name: "Hanoi", country: "Vietnam", region: "Ha Noi", latitude: 12.3, longitude: 123.4)
        let b = City(name: "Hanoi", country: "Vietnam", region: "Ha Noi", latitude: 32.1, longitude: 123.4)
        
        XCTAssertNotEqual(a, b)
        XCTAssertNotEqual(a.id, b.id)
    }
}
