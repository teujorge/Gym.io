//
//  Extensions.swift
//  Swety
//
//  Created by Matheus Jorge on 7/17/24.
//

import SwiftUI

// ===== View =====

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
    func cornerRadius(_ radius: CornerRadius) -> some View {
        self.cornerRadius(radius.rawValue)
    }

    func shadow(radius: ShadowRadius) -> some View {
        self.shadow(radius: radius.rawValue)
    }
}

// ===== UserDefaults =====

enum UserDefaultsKeys: String {
    case userId
}

extension UserDefaults {
    func set(_ value: Any?, forKey key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
    }
    
    func string(forKey key: UserDefaultsKeys) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func removeObject(forKey key: UserDefaultsKeys) {
        removeObject(forKey: key.rawValue)
    }
}
