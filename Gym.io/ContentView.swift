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
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            WorkoutsView(workouts: _previewWorkouts)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }
            
            ChallengesView()
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text("Challenges")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    ContentView()
}
