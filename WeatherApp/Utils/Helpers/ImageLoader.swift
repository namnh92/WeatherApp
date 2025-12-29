//
//  ImageLoader.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import UIKit

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL
    private let cache: ImageCaching
    private let client: HTTPClient
    private let errorImage: UIImage?
    private var task: Task<Void, Never>?

    init(
        url: URL,
        cache: ImageCaching = ImageCache.shared,
        client: HTTPClient = URLSessionHTTPClient(),
        errorImage: UIImage? = UIImage(systemName: "exclamationmark.triangle")
    ) {
        self.url = url
        self.cache = cache
        self.client = client
        self.errorImage = errorImage
    }

    func load() {
        if let cached = cache.image(for: url) {
            image = cached
            return
        }

        task?.cancel()
        task = Task { [url, cache, client, errorImage] in
            do {
                let (data, _) = try await client.data(for: URLRequest(url: url))
                
                if Task.isCancelled { return }

                guard let uiImage = UIImage(data: data) else {
                    await MainActor.run { self.image = errorImage }
                    return
                }

                cache.insert(uiImage, for: url)
                await MainActor.run { self.image = uiImage }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run { self.image = errorImage }
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit { task?.cancel() }
}
