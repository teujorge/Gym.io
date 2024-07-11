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
                    
                    
                    if currentUser.workouts.isEmpty {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.secondary)
                            .padding(.top, 32)
                        Text("No workouts found")
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    } else {
                        ForEach(currentUser.workouts) { workout in
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
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
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
