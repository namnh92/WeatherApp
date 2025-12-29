//
//  GetWeatherUseCaseTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import XCTest
@testable import WeatherApp

final class GetWeatherUseCaseTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var weather: Weather!
    private var city: City!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataHelper = MockDataHelper()
        weather = mockDataHelper.loadWeather()
        city = mockDataHelper.loadCities().first
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockDataHelper = nil
        weather = nil
        city = nil
    }
    
    func test_execute_success_returnsCities_fromRepository() async throws {
        let expected = weather
        let repo = MockWeatherRepository(stubbedResult: .success(expected!))
        let getWeatherUseCase = GetWeatherUseCase(repository: repo)
        
        let result = try await getWeatherUseCase.execute(city: city)
        
        XCTAssertEqual(repo.callCount, 1)
        XCTAssertEqual(result, expected)
    }
    
    func test_execute_failure_propagatesError() async {
        struct DummyError: Error, Equatable {}
        let repo = MockWeatherRepository(stubbedResult: .failure(DummyError()))
        let getWeatherUseCase = GetWeatherUseCase(repository: repo)
        
        do {
            _ = try await getWeatherUseCase.execute(city: city)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DummyError)
            XCTAssertEqual(repo.callCount, 1)
        }
    }
}

private final class MockWeatherRepository: IWeatherRepository {
    private(set) var callCount: Int = 0
    private let stubbedResult: Result<Weather, Error>

    init(stubbedResult: Result<Weather, Error>) {
        self.stubbedResult = stubbedResult
    }

    func getWeather(city: City) async throws -> Weather {
        callCount += 1

        switch stubbedResult {
        case .success(let weather):
            return weather
        case .failure(let error):
            throw error
        }
    }
}
