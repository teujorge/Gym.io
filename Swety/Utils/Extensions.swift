//
//  Extensions.swift
//  Swety
//
//  Created by Matheus Jorge on 7/17/24.
//

import SwiftUI

// App language
enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case portuguese = "pt"

    var id: String { self.rawValue }
    
    func toLocale() -> Locale {
        return Locale(identifier: self.rawValue)
    }
}

@Observable
class AppSettings {
    var language: Language {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: .appLanguage)
        }
    }
    
    init() {
        if let language = UserDefaults.standard.string(forKey: .appLanguage) {
            self.language = Language(rawValue: language) ?? .english
        } else {
            self.language = .english
        }
    }
    
}

// ===== View =====

enum Padding: CGFloat {
    case xSmall = 4
    case small = 8
    case medium = 12
    case large = 16
    case xLarge = 20
}

enum CornerRadius: CGFloat {
    case small = 8
    case medium = 16
    case large = 24
}

enum ShadowRadius: CGFloat {
    case small = 5
    case medium = 8
    case large = 10
}

extension View {
    func padding(_ padding: Padding) -> some View {
        self.padding(padding.rawValue)
    }
    
    func padding(_ edges: Edge.Set = .all, _ length: Padding) -> some View {
        self.padding(edges, length.rawValue)
    }
    
    func cornerRadius(_ radius: CornerRadius) -> some View {
        self.cornerRadius(radius.rawValue)
    }

    func shadow(radius: ShadowRadius) -> some View {
        self.shadow(radius: radius.rawValue)
    }
}

extension RoundedRectangle {
    init(cornerRadius: CornerRadius) {
        self.init(cornerRadius: cornerRadius.rawValue)
    }
}

// ===== UserDefaults =====

enum UserDefaultsKeys: String {
    case userId
    case appLanguage
    case userAccessToken
    case userRefreshToken
    case defaultExercises
    case defaultExercisesLastFetch
}

extension UserDefaults {
    func set(_ value: Any?, forKey key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
    }
    
    func data(forKey key: UserDefaultsKeys) -> Data? {
        return data(forKey: key.rawValue)
    }
    
    func string(forKey key: UserDefaultsKeys) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func object(forKey key: UserDefaultsKeys) -> Any? {
        return object(forKey: key.rawValue)
    }
    
    func removeObject(forKey key: UserDefaultsKeys) {
        removeObject(forKey: key.rawValue)
    }
    
    func setCodable<T: Codable>(_ value: T, forKey key: UserDefaultsKeys) {
        if let data = try? JSONEncoder().encode(value) {
            self.set(data, forKey: key)
            print("Successfully saved data for key: \(key)")
        } else {
            print("Failed to encode and save data for key: \(key)")
        }
    }
    
    func codable<T: Codable>(forKey key: UserDefaultsKeys) -> T? {
        if let data = self.data(forKey: key) {
            if let value = try? JSONDecoder().decode(T.self, from: data) {
                print("Successfully decoded data for key: \(key)")
                return value
            } else {
                print("Failed to decode data for key: \(key)")
            }
        } else {
            print("No data found for key: \(key)")
        }
        return nil
    }
}

// ===== Environment =====

// Popping views
struct DismissAllKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var dismissAll: () -> Void {
        get { self[DismissAllKey.self] }
        set { self[DismissAllKey.self] = newValue }
    }
}
