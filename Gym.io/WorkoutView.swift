//
//  WorkoutView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct WorkoutView: View {
    
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(workout.description)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom)
                
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
    }
}

struct Workout {
    let title: String
    let description: String
    let exercises: [Exercise]
}


#Preview {
    PreviewWorkoutView
}

var exercises: [Exercise] = [
    ExerciseRepBased(name: "Bench Press", instructions: "Lie on a flat bench with your feet flat on the floor. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the bar to your chest, then press it back up.",sets: 4, reps: 10, weight: 135),
    ExerciseRepBased(name: "Squats", instructions: "Stand with your feet shoulder-width apart. Lower your body as if you were sitting back into a chair. Push through your heels to return to the starting position.", sets: 3, reps: 12, weight: 185),
    ExerciseRepBased(name: "Deadlift", instructions: "Stand with your feet hip-width apart. Bend at the hips and knees to grip the barbell. Keep your back straight as you lift the barbell off the ground.", sets: 3, reps: 8, weight: 225),
    ExerciseRepBased(name: "Pull-ups", sets: 3, reps: 10, weight: 0),
    ExerciseTimeBased(name: "Plank", duration: 30, caloriesPerMinute: 10),
]

let PreviewWorkoutView = WorkoutView(
    workout:
        Workout(
            title: "Full Body Workout",
            description: "A complete workout targeting all major muscle groups.",
            exercises: exercises
        )
)
