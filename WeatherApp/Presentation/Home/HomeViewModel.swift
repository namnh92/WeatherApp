//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol IHomeViewModel {
    var onStateChange: ((HomeViewState) -> Void)? { get set }

    func onViewWillAppear()
    func onSearchTextChanged(_ text: String)
    func cityViewed(_ city: City)
}

class HomeViewModel: IHomeViewModel {
    // MARK: - Variables
    private let getCityUseCase: IGetCityUseCase
    private let getRecentCityUseCase: IGetRecentCityUseCase
    private let debouncer: IAsyncDebouncer
    
    var onStateChange: ((HomeViewState) -> Void)?
    
    private var state = HomeViewState() {
        didSet { onStateChange?(state) }
    }
    
    // MARK: - Initial
    init(getCityUseCase: IGetCityUseCase,
         getRecentCityUseCase: IGetRecentCityUseCase,
         debouncer: IAsyncDebouncer) {
        self.getCityUseCase = getCityUseCase
        self.getRecentCityUseCase = getRecentCityUseCase
        self.debouncer = debouncer
    }
    
    func onSearchTextChanged(_ text: String) {
        state.query = text
        guard !text.isEmpty else {
            state.searchResults = []
            state.errorMessage = nil
            state.isLoading = false
            return
        }
        state.isLoading = true
        
        debouncer.schedule { [weak self] in
            guard let self else { return }
            await self.search(query: text)
        }
    }
    
    func onViewWillAppear() {
        state.recentCities = getRecentCityUseCase.execute(AppConfiguration.Store.maxItem)
    }
    
    func cityViewed(_ city: City) {
        getRecentCityUseCase.save(city)
    }
}

// MARK: - Private function
private extension HomeViewModel {
    func search(query: String) async {
        do {
            let cities = try await getCityUseCase.execute(query)
            
            state.searchResults = cities
            state.errorMessage = nil
            state.isLoading = false
        } catch {
            guard !(error is CancellationError) else { return }
            
            let message: String
            if let apiError = error as? APIError {
                message = apiError.userMessage
            } else {
                message = "Unexpected error."
            }
            
            state.searchResults = []
            state.errorMessage = message
            state.isLoading = false
        }
    }
}
