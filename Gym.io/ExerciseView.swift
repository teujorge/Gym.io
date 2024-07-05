//
//  ExerciseView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExerciseView: View {
    @StateObject var exercise: Exercise
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: Header
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
                        IncrementableDetailView(
                            prefix: "Sets: ",
                            affix: nil,
                            isEditing: isEditing,
                            count: Binding(
                                get: { repBasedExercise.sets },
                                set: { repBasedExercise.sets = $0 }
                            )
                        )
                        IncrementableDetailView(
                            prefix: "Reps: ",
                            affix: nil,
                            isEditing: isEditing,
                            count: Binding(
                                get: { repBasedExercise.reps },
                                set: { repBasedExercise.reps = $0 }
                            )
                        )
                        IncrementableDetailView(
                            prefix: "Weight: ",
                            affix: "kg",
                            isEditing: isEditing,
                            count: Binding(
                                get: { repBasedExercise.weight },
                                set: { repBasedExercise.weight = $0 }
                            )
                        )
                    }
                    .padding()
                }
                // Duration
                else if let timeBasedExercise = exercise as? ExerciseTimeBased {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Duration")
                            .font(.headline)
                        IncrementableDetailView(
                            prefix: "Duration: ",
                            affix: "seconds",
                            isEditing: isEditing,
                            count: Binding(
                                get: { timeBasedExercise.duration },
                                set: { timeBasedExercise.duration = $0 }
                            )
                        )
                    }
                    .padding()
                }
                
                
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
    }
    
    // MARK: Increment Button View
    struct IncrementableDetailView: View {
        let prefix: String?
        let affix: String?
        let isEditing: Bool
        
        @Binding var count: Int
        
        var body: some View {
            HStack {
                if let text = prefix {
                    Text(text)
                }
                
                if isEditing {
                    Button(action: { count -= 1 }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(count.description)
                
                if isEditing {
                    Button(action: { count += 1 }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
                
                if let text = affix {
                    Text(text)
                }
            }
            .animation(.default, value: isEditing)
        }
        
    }
    
}

// MARK: Exercise classes

// Define the abstract base class for common exercise properties
class Exercise: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String
    @Published var imageName: String?
    @Published var instructions: String?
    
    init(name: String, imageName: String? = nil, instructions: String? = nil) {
        self.name = name
        self.imageName = imageName
        self.instructions = instructions
    }
}

// Class for rep-based exercises
class ExerciseRepBased: Exercise {
    @Published var sets: Int
    @Published var reps: Int
    @Published var weight: Int
    @Published var caloriesPerRep: Int?
    
    init(name: String, imageName: String? = nil, instructions: String? = nil, sets: Int, reps: Int, weight: Int, caloriesPerRep: Int? = nil) {
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.caloriesPerRep = caloriesPerRep
        super.init(name: name, imageName: imageName, instructions: instructions)
    }
}

// Class for time-based exercises
class ExerciseTimeBased: Exercise {
    @Published var duration: Int // Duration in seconds
    @Published var caloriesPerMinute: Int?
    
    init(name: String, imageName: String? = nil, instructions: String? = nil, duration: Int, caloriesPerMinute: Int? = nil) {
        self.duration = duration
        self.caloriesPerMinute = caloriesPerMinute
        super.init(name: name, imageName: imageName, instructions: instructions)
    }
}



#Preview {
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
