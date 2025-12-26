//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

protocol IHomeViewModel {
    
}

class HomeViewModel: IHomeViewModel {
    // MARK: - Variables
    private let getCityUseCase: IGetCityUseCase
    private let debouncer: AsyncDebouncer
    
    var onStateChange: ((HomeViewState) -> Void)?
    
    private var state = HomeViewState() {
        didSet { onStateChange?(state) }
    }
    
    // MARK: - Initial
    init(getCityUseCase: IGetCityUseCase, debouncer: AsyncDebouncer) {
        self.getCityUseCase = getCityUseCase
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
            Task { await self.search(query: text) }
        }
    }
}

// MARK: - Private function
private extension HomeViewModel {
    private func search(query: String) async {
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
