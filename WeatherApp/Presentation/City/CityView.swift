//
//  CityView.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import SwiftUI

struct CityView: View {

    @StateObject private var viewModel: CityViewModel
    private let city: City

    init(city: City, viewModel: CityViewModel) {
        self.city = city
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("\(city.name), \(city.country)")
                    .font(.title2).bold()

                if viewModel.state.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.state.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                } else if let weather = viewModel.state.weather {
                    weatherCard(weather)
                } else {
                    Text("No data")
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .navigationTitle("City")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.onAppear() }
    }

    @ViewBuilder
    private func weatherCard(_ weather: Weather) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            // Weather image
            if let url = weather.iconURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().scaledToFit()
                            .frame(width: 64, height: 64)
                    case .failure:
                        Image(systemName: "cloud")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // Humidity
            HStack {
                Image(systemName: "drop.fill")
                Text("Humidity: \(weather.humidity ?? 0)%")
            }

            // Weather text
            HStack {
                Image(systemName: "text.bubble")
                Text(weather.description ?? "-")
            }

            // Temperature
            HStack {
                Image(systemName: "thermometer")
                Text("\(weather.temperatureC ?? 0)°C")
                    .font(.title3).bold()
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
