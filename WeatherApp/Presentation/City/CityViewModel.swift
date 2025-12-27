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

        Task {
            do {
                let weather = try await useCase.execute(lattitude: city.latitude, longitude: city.longitude)
                state.weather = weather
                state.isLoading = false
            } catch is CancellationError {
                state.isLoading = false
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
