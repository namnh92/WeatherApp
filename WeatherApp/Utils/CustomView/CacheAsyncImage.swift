//
//  CacheAsyncImage.swift
//  WeatherApp
//
//  Created by Max Nguyen on 28/12/25.
//

import SwiftUI
import UIKit

// MARK: - Cached Image (NSCache)
private final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

private final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private var task: Task<Void, Never>?
    private let errorImage = UIImage(systemName: "exclamationmark.triangle")

    init(url: URL) { self.url = url }

    func load() {
        if let cached = ImageCache.shared.image(for: url) {
            image = cached
            return
        }

        task?.cancel()
        task = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if Task.isCancelled { return }
                guard let uiImage = UIImage(data: data) else {
                    await MainActor.run { self.image = self.errorImage }
                    return
                }

                ImageCache.shared.insert(uiImage, for: url)
                await MainActor.run { self.image = uiImage }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run { self.image = self.errorImage }
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit { task?.cancel() }
}

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
