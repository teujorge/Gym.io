//
//  Utils.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

/// Hides the keyboard.
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

/// Decodes a date from a string using the ISO8601DateFormatter.
func decodeDate<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Date {
    let dateString = try container.decode(String.self, forKey: key)
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let date = dateFormatter.date(from: dateString) {
        return date
    } else {
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date string does not match format expected by formatter.")
    }
}
