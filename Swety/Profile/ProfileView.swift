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
    
    var filteredWorkouts: [Workout] {
        currentUser.workouts
            .filter { $0.completedAt != nil }
            .sorted { $0.completedAt! > $1.completedAt! }
    }
    
    var filteredExerciseNames: [String] {
        viewModel.exercisesHistory
            .keys
            .sorted {
                viewModel.exercisesHistory[$0]?.count ?? 0 > viewModel.exercisesHistory[$1]?.count ?? 0
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                profileInfo
                summary
                pickerView
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
            Picker("Select History", selection: $viewModel.selectedPickerTab) {
                ForEach(HistorySelections.allCases) { selection in
                    Text(selection.displayName).tag(selection)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top)
            .padding(.horizontal)
            
            switch viewModel.selectedPickerTab {
            case .workouts:
                workoutHistory
            case .exercises:
                exerciseHistory
            }
        }
        .padding()
    }
    
    private var workoutHistory: some View {
        VStack(alignment: .leading) {
            
            ForEach(filteredWorkouts) { workout in
                VStack(alignment: .leading) {
                    HStack {
                        NavigationLink(destination: EditWorkoutHistoryView(workout: workout)) {
                            Text(workout.name)
                                .font(.headline)
                        }
                        Spacer()
                        Text(workout.completedAt!, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    if let notes = workout.notes {
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        if let completedAt = workout.completedAt {
                            Text("Time: \(formatTime(completedAt.timeIntervalSince(workout.createdAt)))")
                        } else {
                            Text("Time: --:--")
                        }
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
    
    private var exerciseHistory: some View {
        VStack(alignment: .leading) {
            
            ForEach(filteredExerciseNames, id: \.self) { name in
                if let exerciseList = viewModel.exercisesHistory[name] {
                    VStack(alignment: .leading) {
                        Text(exerciseList.first?.name ?? "no name")
                            .font(.headline)
                        if let notes = exerciseList.first!.notes {
                            Text(notes)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Count: \(exerciseList.count)")
                            Text("Volume: \(calculateVolume(for: exerciseList))")
                        }
                        .foregroundColor(.secondary)
                        Divider()
                    }
                    .padding()
                }
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
        .onAppear(perform: updateUserExerciseHistory)
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
    
    private func updateUserExerciseHistory() {
        Task {
            if let completedExercises = await viewModel.fetchExercises(for: currentUserId) {
                for exercise in completedExercises {
                    if var exercises = viewModel.exercisesHistory[exercise.name] {
                        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
                            // Replace the existing exercise
                            exercises[index] = exercise
                        } else {
                            // Append to the existing array
                            exercises.append(exercise)
                        }
                        viewModel.exercisesHistory[exercise.name] = exercises
                    } else {
                        // Create new array
                        viewModel.exercisesHistory[exercise.name] = [exercise]
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


