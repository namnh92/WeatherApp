//
//  GetCityUseCaseTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import XCTest
@testable import WeatherApp

final class GetCityUseCaseTests: XCTestCase {
    private var cities: [City] = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cities = MockDataHelper().loadCities()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        cities = []
    }
    
    func test_execute_trimsQuery_beforeCallingRepository() async throws {
        let repo = MockCityRepository(stubbedResult: .success(cities))
        let getCityUseCase = GetCityUseCase(repository: repo)
        
        _ = try await getCityUseCase.execute("   Hong    Kong   ")
        
        XCTAssertEqual(repo.callCount, 1)
        XCTAssertEqual(repo.receivedQueries, ["Hong Kong"])
    }
    
    func test_execute_success_returnsCities_fromRepository() async throws {
        let expected = cities
        let repo = MockCityRepository(stubbedResult: .success(expected))
        let getCityUseCase = GetCityUseCase(repository: repo)
        
        let result = try await getCityUseCase.execute("H")
        
        XCTAssertEqual(repo.callCount, 1)
        XCTAssertEqual(repo.receivedQueries, ["H"])
        XCTAssertEqual(result, expected)
    }
    
    func test_execute_failure_propagatesError() async {
        struct DummyError: Error, Equatable {}
        let repo = MockCityRepository(stubbedResult: .failure(DummyError()))
        let getCityUseCase = GetCityUseCase(repository: repo)
        
        do {
            _ = try await getCityUseCase.execute("H")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is DummyError)
            XCTAssertEqual(repo.callCount, 1)
            XCTAssertEqual(repo.receivedQueries, ["H"])
        }
    }
}

private final class MockCityRepository: ICityRepository {
    private(set) var receivedQueries: [String] = []
    private(set) var callCount: Int = 0
    private let stubbedResult: Result<[City], Error>

    init(stubbedResult: Result<[City], Error> = .success([])) {
        self.stubbedResult = stubbedResult
    }

    func getCities(_ query: String) async throws -> [City] {
        callCount += 1
        receivedQueries.append(query)

        switch stubbedResult {
        case .success(let cities):
            return cities
        case .failure(let error):
            throw error
        }
    }
}
