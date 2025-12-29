//
//  CityViewModelTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
import Combine
@testable import WeatherApp

final class CityViewModelTests: XCTestCase {
    private var mockDataHelper: MockDataHelper!
    private var weather: Weather!
    private var city: City!
    private var cancellables: Set<AnyCancellable> = []

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
        cancellables.removeAll()
    }

    func test_onAppear_whenWeatherAlreadyLoaded_doesNotCallUseCase() async {
        let useCase = MockGetWeatherUseCase(result: .success(weather))
        let viewModel = CityViewModel(city: city, useCase: useCase)

        await MainActor.run {
            viewModel._test_setWeather(weather)
        }

        await MainActor.run {
            viewModel.onAppear()
        }

        XCTAssertEqual(useCase.callCount, 0)
    }

    func test_onAppear_whenIsLoadingTrue_doesNotCallUseCase() async {
        let useCase = MockGetWeatherUseCase(result: .success(weather))
        let viewModel = CityViewModel(city: city, useCase: useCase)

        await MainActor.run {
            viewModel._test_setLoading(true)
        }

        await MainActor.run {
            viewModel.onAppear()
        }

        XCTAssertEqual(useCase.callCount, 0)
    }

    func test_onAppear_success_setsLoadingThenWeather_andStopsLoading() async throws {
        let useCase = MockGetWeatherUseCase(result: .success(weather))
        let viewModel = CityViewModel(city: city, useCase: useCase)

        // Expect: isLoading becomes true
        let loadingTrue = expectation(description: "isLoading becomes true")
        await MainActor.run {
            viewModel.$state
                .map(\.isLoading)
                .removeDuplicates()
                .dropFirst()
                .sink { isLoading in
                    if isLoading == true { loadingTrue.fulfill() }
                }
                .store(in: &cancellables)
        }

        // Expect: weather becomes non-nil
        let weatherLoaded = expectation(description: "weather loaded")
        await MainActor.run {
            viewModel.$state
                .map(\.weather)
                .removeDuplicates(by: { $0?.temperatureC == $1?.temperatureC && $0?.humidity == $1?.humidity })
                .dropFirst()
                .sink { weather in
                    if weather != nil { weatherLoaded.fulfill() }
                }
                .store(in: &cancellables)
        }

        await MainActor.run { viewModel.onAppear() }

        await fulfillment(of: [loadingTrue, weatherLoaded], timeout: 1.0)

        let finalState = await MainActor.run { viewModel.state }

        XCTAssertEqual(useCase.callCount, 1)
        XCTAssertEqual(finalState.weather, weather)
        XCTAssertFalse(finalState.isLoading)
        XCTAssertNil(finalState.errorMessage)
    }

    func test_onAppear_apiError_setsUserMessage_andStopsLoading() async throws {
        let apiError = APIError.server("No data")
        let useCase = MockGetWeatherUseCase(result: .failure(apiError))
        let viewModel = CityViewModel(city: city, useCase: useCase)

        let errorSet = expectation(description: "error message set")
        await MainActor.run {
            viewModel.$state
                .map(\.errorMessage)
                .removeDuplicates()
                .dropFirst()
                .sink { msg in
                    if msg == apiError.userMessage { errorSet.fulfill() }
                }
                .store(in: &cancellables)
        }

        await MainActor.run { viewModel.onAppear() }
        await fulfillment(of: [errorSet], timeout: 1.0)

        let finalState = await MainActor.run { viewModel.state }

        XCTAssertEqual(useCase.callCount, 1)
        XCTAssertNil(finalState.weather)
        XCTAssertFalse(finalState.isLoading)
        XCTAssertEqual(finalState.errorMessage, apiError.userMessage)
    }

    func test_onAppear_unknownError_setsGenericMessage_andStopsLoading() async throws {
        struct DummyError: Error {}

        let useCase = MockGetWeatherUseCase(result: .failure(DummyError()))
        let viewModel = CityViewModel(city: city, useCase: useCase)

        let errorSet = expectation(description: "generic error message set")
        await MainActor.run {
            viewModel.$state
                .map(\.errorMessage)
                .removeDuplicates()
                .dropFirst()
                .sink { msg in
                    if msg == "Something went wrong." { errorSet.fulfill() }
                }
                .store(in: &cancellables)
        }

        await MainActor.run { viewModel.onAppear() }
        await fulfillment(of: [errorSet], timeout: 1.0)

        let finalState = await MainActor.run { viewModel.state }

        XCTAssertEqual(useCase.callCount, 1)
        XCTAssertNil(finalState.weather)
        XCTAssertFalse(finalState.isLoading)
        XCTAssertEqual(finalState.errorMessage, "Something went wrong.")
    }

    func test_onAppear_cancellationError_doesNotSetErrorMessage_andStopsLoading() async {
        let useCase = MockGetWeatherUseCase(result: .failure(CancellationError()))
        let viewModel = CityViewModel(city: city, useCase: useCase)

        let loadingStopped = expectation(description: "Loading stopped after cancellation")

        viewModel.$state
            .map(\.isLoading)
            .dropFirst()
            .sink { isLoading in
                if isLoading == false {
                    loadingStopped.fulfill()
                }
            }
            .store(in: &cancellables)

        await MainActor.run { viewModel.onAppear() }

        await fulfillment(of: [loadingStopped], timeout: 1)

        XCTAssertEqual(useCase.callCount, 1)
        XCTAssertNil(viewModel.state.weather)
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertNil(viewModel.state.errorMessage)
    }
}

private final class MockGetWeatherUseCase: IGetWeatherUseCase {
    private let result: Result<Weather, Error>
    private(set) var callCount: Int = 0

    init(result: Result<Weather, Error>) {
        self.result = result
    }

    func execute(city: City) async throws -> Weather {
        callCount += 1
        return try result.get()
    }
}
