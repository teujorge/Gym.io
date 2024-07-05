//
//  ContentView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Home
            MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Workouts
            WorkoutsView(workouts: [])
                .tabItem {
                    Image(systemName: "list.bullet")
                }
            
            // Profile
            EmptyView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
