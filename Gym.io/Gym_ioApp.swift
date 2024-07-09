//
//  Gym_ioApp.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

import SwiftUI

@main
struct Gym_ioApp: App {
    @StateObject private var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authState)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authState: AuthState

    var body: some View {
        ZStack {
            if authState.isSignedIn {
                ContentView()
                    .transition(.move(edge: .top))
            } else {
                AuthView()
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authState.isSignedIn)
    }
}

class AuthState: ObservableObject {
    @Published var currentUser: User?
    
    var isSignedIn: Bool {
        return currentUser != nil
    }
}

#Preview {
    RootView().environmentObject(AuthState())
}

