//
//  Utils.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

/// Decodes a date from a string or a number using the ISO8601DateFormatter.
func decodeDate<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Date {
    if let dateString = try? container.decode(String.self, forKey: key) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    } else if let timestamp = try? container.decode(Double.self, forKey: key) {
        return Date(timeIntervalSince1970: timestamp)
    } else {
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date is not in a recognized format.")
    }
}

/// Decodes a nullable date from a string or a number using the ISO8601DateFormatter.
func decodeNullableDate<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Date? {
    if let dateString = try? container.decodeIfPresent(String.self, forKey: key) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    } else if let timestamp = try? container.decodeIfPresent(Double.self, forKey: key) {
        return Date(timeIntervalSince1970: timestamp)
    } else {
        return nil
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

/// Gets and Set current user access token from UserDefaults
var currentUserAccessToken: String? {
    get {
        #if DEBUG
        UserDefaults.standard.string(forKey: .userAccessToken) ?? "test"
        #else
        UserDefaults.standard.string(forKey: .userAccessToken)
        #endif
    }
    set {
        UserDefaults.standard.set(newValue, forKey: .userAccessToken)
    }
}

/// Gets and Set current user refresh token from UserDefaults
var currentUserRefreshToken: String? {
    get {
        UserDefaults.standard.string(forKey: .userRefreshToken)
    }
    set {
        UserDefaults.standard.set(newValue, forKey: .userRefreshToken)
    }
}

/// Calculates the total volume of a workout.
func calculateVolume(for workout: Workout) -> Int {
    return workout.exercises.reduce(0) { total, exercise in
        total + (
            exercise.isRepBased
            ? exercise.sets.reduce(0) { setTotal, set in
                setTotal + (set.reps * set.weight)
            }
            : 0
        )
    }
}

/// Formats a time interval as a string in the format "HH:MM".
func formatTime(_ time: TimeInterval) -> String {
    let hours = Int(time) / 3600
    let minutes = (Int(time) % 3600) / 60
    return String(format: "%02d:%02d", hours, minutes)
}

/// Formats time in seconds as a string in the format "MM:SS".
func formatTime(_ time: Int) -> String {
    let minutes = time / 60
    let seconds = time % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
