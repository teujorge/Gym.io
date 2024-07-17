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
                        ForEach(filteredWorkouts) { workout in
                            VStack(alignment: .leading) {
                                HStack {
                                    Spacer()
                                    Text(workout.completedAt!, style: .date)
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                                Text(workout.title)
                                    .font(.headline)
                                if let notes = workout.notes {
                                    Text(notes)
                                        .foregroundColor(.secondary)
                                }
                                HStack {
                                    Text("Time: \(viewModel.formatTime(workout.updatedAt.timeIntervalSince(workout.createdAt)))")
                                    Text("Volume: \(viewModel.calculateVolume(for: workout))")
                                }
                                .foregroundColor(.secondary)
                                Divider()
                            }
                            .padding()
                        }
                        
                        if viewModel.workoutsCursor != nil {
                            HStack(alignment: .center) {
                                Spacer()
                                if viewModel.state == .loading {
                                    LoaderView(size: 50)
                                } else {
                                    Button(action: updateUserWorkoutHistory) {
                                        if case let .failure(error) = viewModel.state {
                                            Text(error)
                                        } else {
                                            Text("Load More")
                                        }
                                    }
                                    .padding()
                                    .background(Color.accent)
                                    .foregroundColor(Color.white)
                                    .frame(height: 50)
                                    .cornerRadius(10)
                                }
                                Spacer()
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut, value: viewModel.state)
                    .transition(
                        .scale(scale: 0.85)
                        .combined(with: .opacity)
                        .combined(with: .move(edge: .bottom))
                    )
                    .onAppear(perform: updateUserWorkoutHistory)
                    
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
                .animation(.easeInOut, value: currentUser.workouts.count)
            }
            .navigationTitle(currentUser.username)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { }) {
                        Text("Edit")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.accent)
                        Image(systemName: "pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                            .foregroundColor(.accent)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(20)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.accent)
                            .padding(.horizontal, 4)
                    }
                    Button(action: { }) {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.accent)
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
    
    private func updateUserWorkoutHistory() {
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
    
}


#Preview {
    ProfileView()
        .environmentObject(_previewAuthSignedInState)
        .environmentObject(_previewParticipants[0])
}
