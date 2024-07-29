//
//  ProfileView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppSettings.self) var appSettings
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var currentUser: User
    @StateObject var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    
    var filteredWorkouts: [Workout] {
        let x = currentUser.workouts.filter { $0.completedAt != nil }
        print("here ::: \(x)")
        return x
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                profileInfo
                pickerView
                if selectedTab == 0 {
                   workoutHistory
                } else {
                    
                }

            }
            .animation(.easeInOut, value: currentUser.workouts.count)
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
                    .cornerRadius(.large)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accent)
                    }
                    Button(action: { viewModel.isPresentingSettings = true }) {
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accent)
                    }
                }
                ToolbarItem(placement: .status) {
                    LoaderView(state: viewModel.state)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
            .sheet(isPresented: $viewModel.isPresentingSettings) {
                userSettings
                    .presentationDetents([.medium])
            }
        }
        
    }
    
    private var profileInfo: some View {
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
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var summary: some View {
        SummaryChartView()
            .padding()
    }
    
    private var pickerView: some View {
        VStack {
            Picker(selection: $selectedTab, label: Text("Select View")) {
                Text("Workouts").tag(0)
                Text("Exercises").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
           
        }
        .padding()
    }
    
    private var workoutHistory: some View {
        VStack(alignment: .leading) {
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
                    Text(workout.name)
                        .font(.headline)
                    if let notes = workout.notes {
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Time: \(formatTime(workout.updatedAt.timeIntervalSince(workout.createdAt)))")
                        Text("Volume: \(calculateVolume(for: workout))")
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
                        .cornerRadius(.medium)
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.state)
        .transition(
            .scale(scale: 0.85)
            .combined(with: .opacity)
            .combined(with: .move(edge: .bottom))
        )
        .onAppear(perform: updateUserWorkoutHistory)
    }
    
    private var exercisesHistory: some View {
        VStack(alignment: .leading) {
            Text("Exercises")
                .font(.headline)
            ForEach(filteredWorkouts) { workout in
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(workout.completedAt!, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    Text(workout.name)
                        .font(.headline)
                    if let notes = workout.notes {
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Time: \(formatTime(workout.updatedAt.timeIntervalSince(workout.createdAt)))")
                        Text("Volume: \(calculateVolume(for: workout))")
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
                        .cornerRadius(.medium)
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.state)
        .transition(
            .scale(scale: 0.85)
            .combined(with: .opacity)
            .combined(with: .move(edge: .bottom))
        )
        .onAppear(perform: updateUserWorkoutHistory)
    }

    
    private var userSettings: some View {
        VStack {
            
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Picker("Language", selection: $viewModel.currentLanguage) {
                Text(String("English")).tag(Language.english)
                Text(String("Español")).tag(Language.spanish)
                Text(String("Português")).tag(Language.portuguese)
            }
            .padding()
            .pickerStyle(.segmented)
            .onAppear() {
                viewModel.currentLanguage = appSettings.language
            }
            .onChange(of: viewModel.currentLanguage) { oldLang, newLang in
                appSettings.language = newLang
            }
            
            Button(action: {
                UserDefaults.standard.removeObject(forKey: .userId)
                DispatchQueue.main.async {
                    authState.currentUser = nil
                    currentUserAccessToken = nil
                    currentUserRefreshToken = nil
                }
            }) {
                Text("Sign Out")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(.medium)
            }
            .padding(.top)
            .padding(.horizontal)
            
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
                    .cornerRadius(.medium)
            }
            .padding()
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
        .environment(AppSettings())
        .environmentObject(_previewAuthSignedInState)
        .environmentObject(_previewParticipants[0])
}


