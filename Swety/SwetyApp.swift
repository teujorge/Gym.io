//
//  SwetyApp.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

@main
struct Gym_ioApp: App {
    @State private var appSettings = AppSettings()
    @StateObject private var authState = AuthState()
    @StateObject private var dialogManager = DialogManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authState)
                .environmentObject(dialogManager)
                .environment(appSettings)
                .environment(\.locale, appSettings.language.toLocale())
        }
    }
}

struct RootView: View {
    @Environment(AppSettings.self) var appSettings
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
        .environment(AppSettings())
        .environmentObject(AuthState())
        .environmentObject(DialogManager())
}

