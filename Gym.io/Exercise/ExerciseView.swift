//
//  ExerciseView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExerciseView: View {
    @StateObject var exercise: Exercise
    @State private var isPresentingExerciseForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: Header
                VStack(alignment: .trailing) {
                    if let imageName = exercise.imageName {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(.all, 24)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .padding()
                
                // MARK: Instructions
                if let instructions = exercise.instructions {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // MARK: Details
                // Sets and Reps
                if let repBasedExercise = exercise as? ExerciseRepBased {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sets and Reps")
                            .font(.headline)
                        Text("Sets: \(repBasedExercise.sets)")
                        Text("Reps: \(repBasedExercise.reps)")
                        Text("Weight: \(repBasedExercise.weight) lbs")
                    }
                    .padding()
                }
                // Duration
                else if let timeBasedExercise = exercise as? ExerciseTimeBased {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Duration")
                            .font(.headline)
                        Text("Duration: \(timeBasedExercise.duration) seconds")
                    }
                    .padding()
                }
                
                // MARK: Footer
                Spacer()
                Button(action: {
                    // Start exercise action
                }) {
                    Text("Start Exercise")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .sheet(isPresented: $isPresentingExerciseForm) {
                ExerciseFormView(
                    exercise: exercise,
                    onSave: { exercise in
                        isPresentingExerciseForm = false
                    },
                    onDelete: { exercise in
                        isPresentingExerciseForm = false
                    }
                )
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarItems(trailing: Button(action: { isPresentingExerciseForm.toggle() }) {
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
    }
    
}


#Preview {
    NavigationView {
        ExerciseView(
            //        exercise: ExerciseRepBased(
            //        name: "Bench Press",
            //        imageName: "dumbbell",
            //        instructions: "Lie on the bench with your feet flat on the ground. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the barbell to your chest, then push it back up to the starting position.",
            //        sets: 4,
            //        reps: 10,
            //        weight: 135,
            //        caloriesPerRep: 5
            //    )
            exercise: ExerciseTimeBased(
                name: "Bench Press",
                imageName: "dumbbell",
                instructions: "Lie on the bench with your feet flat on the ground. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the barbell to your chest, then push it back up to the starting position.",
                duration: 30,
                caloriesPerMinute: 5
            )
        )
    }
}
