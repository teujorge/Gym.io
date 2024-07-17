//
//  ContentView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var currentUser: User
    
    var body: some View {
        TabView {
//            HomeView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                    Text("Home")
//                }
//                .environmentObject(currentUser)
            
            WorkoutsView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }
                .environmentObject(currentUser)
            
            ChallengesView()
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text("Challenges")
                }
                .environmentObject(currentUser)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .environmentObject(currentUser)
        }
    }
}

#Preview {
    ContentView(currentUser: _previewParticipants[0])
}
