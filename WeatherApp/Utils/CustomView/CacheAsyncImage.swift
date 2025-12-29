//
//  CacheAsyncImage.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @StateObject private var loader: ImageLoader

    init(
        url: URL,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .onAppear { loader.load() }
        .onDisappear { loader.cancel() }
    }
}
