//
//  WorkoutView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct WorkoutView: View {
    
    let workout: Workout
    
    @State var isPresentingWorkoutForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let description = workout.description {
                    Text(description)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                // Exercise List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Exercises")
                        .font(.headline)
                    ForEach(workout.exercises, id: \.id) { exercise in
                        NavigationLink(destination: ExerciseView(exercise: exercise)) {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                if let repBasedExercise = exercise as? ExerciseRepBased {
                                    HStack {
                                        Text("\(repBasedExercise.sets) sets")
                                        Text("\(repBasedExercise.reps) reps")
                                        Text("\(repBasedExercise.weight) lbs")
                                    }
                                    .foregroundColor(.secondary)
                                }
                                else if let timeBasedExercise = exercise as? ExerciseTimeBased {
                                    HStack {
                                        Text("Duration: \(timeBasedExercise.duration) seconds")
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                }
            }
            .padding()
            
            // Start Workout Button
            Button(action: {
                // Start workout action
            }) {
                Text("Start Workout")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Progress Tracker (Placeholder)
            VStack {
                Text("Progress")
                    .font(.headline)
                ProgressView(value: 0.5)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(workout.title)
        .navigationBarItems(trailing: Button(action: { isPresentingWorkoutForm.toggle() }) {
            HStack {
                Text("Edit")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(20)
        })
        .sheet(isPresented: $isPresentingWorkoutForm) {
            WorkoutFormView(
                workout: workout,
                onSave: { workout in
                    isPresentingWorkoutForm = false
                },
                onDelete: {
                    isPresentingWorkoutForm = false
                }
            )
        }
    }
}


#Preview {
    WorkoutView(
        workout:
            Workout(
                title: "Full Body Workout",
                description: "A complete workout targeting all major muscle groups.",
                exercises: _previewExercises
            )
    )
}

var _previewExercises: [Exercise] = [
    ExerciseRepBased(name: "Bench Press", instructions: "Lie on a flat bench with your feet flat on the floor. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the bar to your chest, then press it back up.",sets: 4, reps: 10, weight: 135),
    ExerciseRepBased(name: "Squats", instructions: "Stand with your feet shoulder-width apart. Lower your body as if you were sitting back into a chair. Push through your heels to return to the starting position.", sets: 3, reps: 12, weight: 185),
    ExerciseRepBased(name: "Deadlift", instructions: "Stand with your feet hip-width apart. Bend at the hips and knees to grip the barbell. Keep your back straight as you lift the barbell off the ground.", sets: 3, reps: 8, weight: 225),
    ExerciseRepBased(name: "Pull-ups", sets: 3, reps: 10, weight: 0),
    ExerciseTimeBased(name: "Plank", duration: 30, caloriesPerMinute: 10),
]
