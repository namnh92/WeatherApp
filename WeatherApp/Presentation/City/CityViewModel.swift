//
//  CityViewModel.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import Foundation


class CityViewModel: ObservableObject {

    @Published private(set) var state = CityViewState()

    private let city: City
    private let useCase: IGetWeatherUseCase

    init(city: City, useCase: IGetWeatherUseCase) {
        self.city = city
        self.useCase = useCase
    }

    @MainActor
    func onAppear() {
        if state.weather != nil || state.isLoading { return }

        state.isLoading = true
        state.errorMessage = nil

        Task { @MainActor in
            do {
                let weather = try await useCase.execute(city: city)
                state.weather = weather
                state.isLoading = false
            } catch is CancellationError {
                state.isLoading = false
                return
            } catch let apiError as APIError {
                state.errorMessage = apiError.userMessage
                state.isLoading = false
            } catch {
                state.errorMessage = "Something went wrong."
                state.isLoading = false
            }
        }
    }
}

#if DEBUG
extension CityViewModel {
    @MainActor
    func _test_setWeather(_ weather: Weather?) {
        state.weather = weather
    }

    @MainActor
    func _test_setLoading(_ isLoading: Bool) {
        state.isLoading = isLoading
    }
}
#endif
