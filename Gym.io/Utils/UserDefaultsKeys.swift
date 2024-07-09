//
//  UserDefaultsKeys.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import Foundation

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
}
