//
//  ProfileView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var currentUser: User
    @StateObject var viewModel = ProfileViewModel()
    
    var filteredWorkouts: [Workout] {
        return currentUser.workouts.filter { $0.completedAt != nil }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // MARK: Profile Info
                    VStack(alignment: .center) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.bottom, 10)
                        Text(currentUser.name)
                            .font(.title)
                            .fontWeight(.bold)
                        HStack {
                            VStack {
                                Text("78")
                                    .font(.headline)
                                Text("Workouts")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack {
                                Text("6")
                                    .font(.headline)
                                Text("Followers")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack {
                                Text("6")
                                    .font(.headline)
                                Text("Following")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                    
                    // MARK: Weekly Summary
                    VStack{
                        SummaryChartView()
                    }
                    .padding()
                    
                    // MARK: Dashboard
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Dashboard")
                            .font(.headline)
                        HStack {
                            Button(action: {
                                // Statistics action
                            }) {
                                VStack {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.largeTitle)                                        .frame(width: 50, height: 50)
                                    Text("Statistics")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            Button(action: {
                                // Exercises action
                            }) {
                                VStack {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.largeTitle)                                        .frame(width: 50, height: 50)
                                    Text("Exercises")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                        HStack {
                            Button(action: {
                                // Measures action
                            }) {
                                VStack {
                                    Image(systemName: "ruler.fill")
                                        .font(.largeTitle)                                        .frame(width: 50, height: 50)
                                    Text("Measures")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            Button(action: {
                                // Calendar action
                            }) {
                                VStack {
                                    Image(systemName: "calendar")
                                        .font(.largeTitle)                                        .frame(width: 50, height: 50)
                                    Text("Calendar")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    
                    // MARK: Workouts
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Workouts")
                            .font(.headline)
                        ForEach(0..<3) { _ in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("guimell")
                                    Spacer()
                                    Text("Thursday, Jun 20, 2024")
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                                Text("1. Chest Shoulders and Triceps")
                                    .font(.headline)
                                Text("Treino rápido")
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("Time")
                                    Spacer()
                                    Text("Volume")
                                }
                                .foregroundColor(.secondary)
                                Divider()
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutCardView(workout: workout)
                        }
                    }
                    .onAppear {
                        Task {
                            if let completedWorkouts = await viewModel.fetchWorkouts(for: currentUserId) {
                                // match by id and replace the workout, otherwise append
                                for workout in completedWorkouts {
                                    if let index = currentUser.workouts.firstIndex(where: { $0.id == workout.id }) {
                                        currentUser.workouts[index] = workout
                                    } else {
                                        currentUser.workouts.append(workout)
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: .userId)
                            DispatchQueue.main.async {
                                authState.currentUser = nil
                            }
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(10)
                        }
                        Button(action: {
                            Task {
                                let isDeleted = await viewModel.deleteUser()
                                if isDeleted {
                                    UserDefaults.standard.removeObject(forKey: .userId)
                                    DispatchQueue.main.async {
                                        authState.currentUser = nil
                                    }
                                }
                            }
                        }) {
                            Text("Delete Account")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(currentUser.username)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { }) {
                        Text("Edit")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Image(systemName: "pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(20)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 4)
                    }
                    Button(action: { }) {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 4)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(_previewAuthSignedInState)
        .environmentObject(_previewParticipants[0])
}
