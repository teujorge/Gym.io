//
//  HomeView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var currentUser: User
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // MARK: Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back,")
                                .font(.headline)
                            Text(currentUser.username)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .padding()
                    
                    // MARK: Workout Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Workout")
                            .font(.headline)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Full Body Workout")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("45 mins")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            NavigationLink(destination: {
                                WorkoutView(workout: _previewWorkouts[0])
                            }) {
                                Text("Start")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // MARK: Quick Actions
                    HStack(spacing: 20) {
                        Button(action: {
                            // Track progress action
                        }) {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                    .font(.largeTitle)
                                Text("Progress")
                            }
                        }
                        Button(action: {
                            // Access workout library action
                        }) {
                            VStack {
                                Image(systemName: "book.fill")
                                    .font(.largeTitle)
                                Text("Library")
                            }
                        }
                        Button(action: {
                            // Access community action
                        }) {
                            VStack {
                                Image(systemName: "person.3.fill")
                                    .font(.largeTitle)
                                Text("Community")
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // MARK: Motivational Quote
                    VStack(alignment: .leading) {
                        Text("Quote of the Day")
                            .font(.headline)
                        Text("\"The only bad workout is the one that didn't happen.\"")
                            .italic()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(_previewParticipants[0])
}
