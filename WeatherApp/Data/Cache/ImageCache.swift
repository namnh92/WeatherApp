//
//  ImageCache.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

import UIKit

protocol ImageCaching: AnyObject {
    func image(for url: URL) -> UIImage?
    func insert(_ image: UIImage, for url: URL)
}

final class ImageCache: ImageCaching {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
