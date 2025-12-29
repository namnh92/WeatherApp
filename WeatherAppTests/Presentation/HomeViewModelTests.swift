//
//  HomeViewModelTests.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import XCTest
@testable import WeatherApp

final class HomeViewModelTests: XCTestCase {
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
    
    func test_onSearchTextChanged_whenEmpty_clearsState_andDoesNotScheduleDebounceOrCallUseCase() {
        let cityUseCase = MockGetCityUseCase()
        let recentUseCase = MockGetRecentCityUseCase()
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let sut = HomeViewModel(
            getCityUseCase: cityUseCase,
            getRecentCityUseCase: recentUseCase,
            debouncer: debouncer
        )
        
        var lastState: HomeViewState?
        sut.onStateChange = { lastState = $0 }
        
        sut.onSearchTextChanged("")
        
        XCTAssertEqual(lastState?.query, "")
        XCTAssertEqual(lastState?.searchResults ?? [], [])
        XCTAssertNil(lastState?.errorMessage)
        XCTAssertEqual(lastState?.isLoading, false)
        
        XCTAssertEqual(debouncer.scheduleCallCount, 0)
        XCTAssertEqual(cityUseCase.executeCallCount, 0)
    }
    
    func test_onSearchTextChanged_whenNonEmpty_setsLoadingTrue_andSchedulesDebounce() {
        let getCityUseCase = MockGetCityUseCase()
        let getRecentCityUseCase = MockGetRecentCityUseCase()
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let viewModel = HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: debouncer)
        
        var lastState: HomeViewState?
        viewModel.onStateChange = { lastState = $0 }
        
        viewModel.onSearchTextChanged("H")
        
        XCTAssertEqual(lastState?.query, "H")
        XCTAssertEqual(lastState?.isLoading, true)
        XCTAssertEqual(debouncer.scheduleCallCount, 1)
    }
    
    func test_search_success_updatesResultsAndStopsLoading() async {
        let getCityUseCase = MockGetCityUseCase()
        getCityUseCase.stubbedResult = .success([city])
        
        let getRecentCityUseCase = MockGetRecentCityUseCase()
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let viewModel = HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: debouncer)
        
        var states: [HomeViewState] = []
        viewModel.onStateChange = { states.append($0) }
        
        viewModel.onSearchTextChanged("H")
        
        XCTAssertEqual(debouncer.scheduleCallCount, 1)
        
        await debouncer.runLast()
        
        let final = states.last!
        XCTAssertEqual(getCityUseCase.executeCallCount, 1)
        XCTAssertEqual(getCityUseCase.receivedQueries, ["H"])
        XCTAssertEqual(final.searchResults, [city])
        XCTAssertNil(final.errorMessage)
        XCTAssertFalse(final.isLoading)
    }

    
    func test_search_apiError_setsUserMessage_clearsResults_andStopsLoading() async {
        let getCityUseCase = MockGetCityUseCase()
        getCityUseCase.stubbedResult = .failure(APIError.server("API failed"))
        let getRecentCityUseCase = MockGetRecentCityUseCase()
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let viewModel = HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: debouncer)
        var states: [HomeViewState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.onSearchTextChanged("H")
        await debouncer.runLast()

        let final = states.last!
        XCTAssertEqual(getCityUseCase.executeCallCount, 1)
        XCTAssertEqual(final.searchResults, [])
        XCTAssertEqual(final.errorMessage, "API failed")
        XCTAssertFalse(final.isLoading)
    }

    func test_search_unknownError_setsUnexpectedError_clearsResults_andStopsLoading() async {
        struct DummyError: Error {}
        let getCityUseCase = MockGetCityUseCase()
        getCityUseCase.stubbedResult = .failure(DummyError())
        let getRecentCityUseCase = MockGetRecentCityUseCase()
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let viewModel = HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: debouncer)
        var states: [HomeViewState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.onSearchTextChanged("H")
        await debouncer.runLast()

        let final = states.last!
        XCTAssertEqual(getCityUseCase.executeCallCount, 1)
        XCTAssertEqual(final.searchResults, [])
        XCTAssertEqual(final.errorMessage, "Unexpected error.")
        XCTAssertFalse(final.isLoading)
    }
    
    func test_onViewWillAppear_loadsRecentCities() {
        let getCityUseCase = MockGetCityUseCase()
        let getRecentCityUseCase = MockGetRecentCityUseCase()
        getRecentCityUseCase.stubbedCities = [city]
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let viewModel = HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: debouncer)
        
        var final: HomeViewState?
        viewModel.onStateChange = { final = $0 }
        
        viewModel.onViewWillAppear()
        
        XCTAssertEqual(final?.recentCities.count, 1)
    }
    
    func test_cityViewed_callsSave() {
        let getCityUseCase = MockGetCityUseCase()
        let getRecentCityUseCase = MockGetRecentCityUseCase()
        getRecentCityUseCase.stubbedCities = [city]
        let debouncer = AsyncDebouncerSpy(delay: AppConfiguration.debounceTime)
        
        let viewModel = HomeViewModel(getCityUseCase: getCityUseCase, getRecentCityUseCase: getRecentCityUseCase, debouncer: debouncer)
        
        viewModel.cityViewed(city)
        
        XCTAssertEqual(getRecentCityUseCase.saveCallCount, 1)
    }
}

private final class MockGetCityUseCase: IGetCityUseCase {
    private(set) var executeCallCount = 0
    private(set) var receivedQueries: [String] = []
    var stubbedResult: Result<[City], Error> = .success([])
    
    func execute(_ query: String) async throws -> [City] {
        executeCallCount += 1
        receivedQueries.append(query)
        return try stubbedResult.get()
    }
}

private final class MockGetRecentCityUseCase: IGetRecentCityUseCase {
    private(set) var executeCallCount = 0
    private(set) var saveCallCount = 0
    var stubbedCities: [City] = []
    
    func execute(_ limit: Int) -> [City] {
        executeCallCount += 1
        return stubbedCities
    }
    
    func save(_ city: City) {
        saveCallCount += 1
    }
}

private final class AsyncDebouncerSpy: AsyncDebouncer {
    private(set) var scheduleCallCount = 0
    private var lastAction: (@Sendable () async -> Void)?
    
    override func schedule(_ action: @escaping @Sendable () async -> Void) {
        scheduleCallCount += 1
        lastAction = action
    }
    
    func runLast() async {
        guard let action = lastAction else { return }
        await action()
    }
}
