//
//  WorkoutsView.swift
//  Gym.io
//
//  Created by Davi Guimell on 05/07/24.
//

import SwiftUI

struct WorkoutsView: View {
    
    @EnvironmentObject var currentUser: User
    @StateObject private var viewModel = WorkoutsViewModel()
    
    var filteredWorkouts: [Workout] {
        if viewModel.searchText.isEmpty {
            return currentUser.workouts
        } else {
            return currentUser.workouts.filter { $0.title.localizedCaseInsensitiveContains(viewModel.searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    HStack {
                        TextField("Search", text: $viewModel.searchText)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(20)
                        
                        Button(action: { viewModel.isPresentingWorkoutForm.toggle() }) {
                            Text("New Workout")
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                    
                    ForEach(filteredWorkouts.indices, id: \.self) { index in
                        WorkoutCardView(workout: currentUser.workouts[index])
                            .transition(.slide)
                    }
                    
                    if (viewModel.state != .idle) {
                        LoaderView(state: viewModel.state, showErrorMessage: true)
                            .padding()
                    }
                    
                }
                .padding()
                .animation(.easeInOut, value: viewModel.state)
            }
            .animation(.easeInOut, value: viewModel.state)
            .background(Color(.systemBackground))
            .navigationTitle("Workouts")
            .sheet(isPresented: $viewModel.isPresentingWorkoutForm) {
                WorkoutFormView(onSave: { DispatchQueue.main.async {
                    viewModel.isPresentingWorkoutForm = false
                }})
            }
        }
        .onAppear { Task {
            let workouts = await viewModel.fetchWorkouts(for: currentUser.id)
            if let workouts = workouts {
                currentUser.workouts = workouts
            }
        }}
    }
    
}

struct WorkoutCardView: View {
    
    var workout: Workout
    
    var body: some View {
        NavigationLink(destination: WorkoutView(workout: workout)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(workout.title)
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.blue)
                    
                    Text("Exercises: \(workout.exercises.count)")
                        .foregroundColor(.secondary)
                }
                
                if let description = workout.notes {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                NavigationLink(destination:WorkoutStartedView(workout: workout)) {
                    Text("Start Workout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
}


#Preview {
    WorkoutsView()
        .environmentObject(
            User(
                id: "000739.b5fe4b10f0654ffcb1b9c5109c11887c.1710",
                username: "teujorge",
                name: "matheus",
                workouts: []
            )
        )
}

let _previewWorkouts = [
    Workout(
        ownerId: "1",
        title: "Davi's workout",
        notes: "A challenging workout to test your limits.",
        exercises: _previewExercises
    ),
    Workout(
        ownerId: "1",
        title: "Ricardo's workout",
        notes: "pussy shit",
        exercises: [
            Exercise(
                index: 1,
                name: "sit on 8=D",
                sets: [
                    ExerciseSet(index: 1, reps: 6, weight: 35),
                    ExerciseSet(index: 1, reps: 5, weight: 30),
                    ExerciseSet(index: 1, reps: 4, weight: 25)
                ],
                isRepBased: true
            )
        ]
    )
]
