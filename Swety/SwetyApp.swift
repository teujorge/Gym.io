//
//  SwetyApp.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

@main
struct Gym_ioApp: App {
    @StateObject private var authState = AuthState()
    @StateObject private var dialogManager = DialogManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authState)
                .environmentObject(dialogManager)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var dialogManager: DialogManager

    var body: some View {
        ZStack {
            if authState.isSignedIn {
                ContentView(currentUser: authState.currentUser!)
                    .transition(.move(edge: .top))
            } else {
                AuthView(authState: authState)
                    .transition(.move(edge: .bottom))
            }
            
            DialogView()
                .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.5), value: authState.isSignedIn)
        .animation(.easeInOut, value: dialogManager.isShowingDialog)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthState())
        .environmentObject(DialogManager())
}

