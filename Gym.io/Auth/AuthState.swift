//
//  AuthState.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

class AuthState: ObservableObject {
    @Published var currentUser: User?
    
    init(currentUser: User? = nil) {
        self.currentUser = currentUser
    }
    
    var isSignedIn: Bool {
        return currentUser != nil
    }
}

let _previewAuthSignedOutState: AuthState = {
    let state = AuthState()
    state.currentUser = nil
    return state
}()

let _previewAuthCreateAccountState: AuthState = {
    let state = AuthState()
    state.currentUser = nil
    // Simulate the state where user needs to create an account
    return state
}()

let _previewAuthSignedInState: AuthState = {
    let state = AuthState()
    state.currentUser = _previewParticipants[0]
    return state
}()
