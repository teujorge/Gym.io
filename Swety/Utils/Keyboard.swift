//
//  Keyboard.swift
//  Swety
//
//  Created by Matheus Jorge on 7/26/24.
//

import SwiftUI

/// Hides the keyboard.
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
