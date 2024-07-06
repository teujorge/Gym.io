//
//  WorkoutsView.swift
//  Gym.io
//
//  Created by Davi Guimell on 05/07/24.
//

import SwiftUI

struct WorkoutsView: View {
    
    let workouts: [Workout]
    @State var searchText = ""
    @State var isPresentingWorkoutForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                    
                    Button(action: { isPresentingWorkoutForm.toggle() }) {
                        Text("New Exercise")
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(20)
                    
                    ForEach(workouts) { workout in
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
                                
                                if let description = workout.description {
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
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Workouts")
            .sheet(isPresented: $isPresentingWorkoutForm) {
                WorkoutFormView(onSave: { workout in
                    isPresentingWorkoutForm = false
                })
            }
        }
    }
}

#Preview {
    NavigationView {
        WorkoutsView(workouts: _previewWorkouts)
    }
}

let _previewWorkouts = [
    Workout(
        title: "Davi's workout",
        description: "A challenging workout to test your limits.",
        exercises: _previewExercises
    ),
    Workout(
        title: "Ricardo's workout",
        description: "pussy shit",
        exercises: [
            ExerciseTimeBased(name: "sit on 8=D", duration: 9999999999)
        ]
    ),
]
