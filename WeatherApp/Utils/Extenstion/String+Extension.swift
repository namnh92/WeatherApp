//
//  String+Extension.swift
//  WeatherApp
//
//  Created by Max Nguyen on 29/12/25.
//

extension String {
    func normalizedSpaces() -> String {
        let components = self
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return components.joined(separator: " ")
    }
}
