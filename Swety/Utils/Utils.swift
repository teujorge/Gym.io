//
//  Utils.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

/// Hides the keyboard.
func dismissKeyboard() {
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

/// Decodes a nullable date from a string using the ISO8601DateFormatter.
func decodeNullableDate<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Date? {
    guard let dateString = try container.decodeIfPresent(String.self, forKey: key) else {
        return nil
    }
    
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let date = dateFormatter.date(from: dateString) {
        return date
    } else {
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date string does not match format expected by formatter.")
    }
}

/// Gets and Set current user id from UserDefaults
var currentUserId: String {
    get {
        UserDefaults.standard.string(forKey: .userId) ?? "000739.b5fe4b10f0654ffcb1b9c5109c11887c.1710"
    }
    set {
        UserDefaults.standard.set(newValue, forKey: .userId)
    }
}
