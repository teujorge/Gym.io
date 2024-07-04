//
//  ExerciseView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExerciseView: View {
    let exercise: Exercise
    
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Exercise Edit and Image
                VStack(alignment: .trailing) {
                    Button(action: { isEditing.toggle() }) {
                        HStack {
                            Text(isEditing ? "Done" : "Edit")
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
                    }
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

                // Exercise Instructions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Instructions")
                        .font(.headline)
                    if let instructions = exercise.instructions {
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

                // Sets and Reps
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sets and Reps")
                        .font(.headline)
                    Text("Sets: \(exercise.sets)")
                    Text("Reps: \(exercise.reps)")
                    Text("Weight: \(exercise.weight) lbs")
                        .foregroundColor(.secondary)
                }
                .padding()

                // Start Button
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

                Spacer()
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String?
    let instructions: String?
    let sets: Int
    let reps: Int
    let weight: Int
    
    init(name: String, imageName: String? = nil, instructions: String? = nil, sets: Int, reps: Int, weight: Int) {
        self.name = name
        self.imageName = imageName
        self.instructions = instructions
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
    
}


#Preview {
    ExerciseView(exercise: Exercise(
        name: "Bench Press",
        imageName: "dumbbell",
        instructions: "Lie on the bench with your feet flat on the ground. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the barbell to your chest, then push it back up to the starting position.",
        sets: 4,
        reps: 10,
        weight: 135
    ))
}
