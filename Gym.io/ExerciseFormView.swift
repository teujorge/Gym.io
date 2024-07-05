//
//  ExerciseFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct ExerciseFormView: View {
    let exercise: Exercise?
    let onSave: (Exercise) -> Void
    let onDelete: (() -> Void)?
    
    @State private var name = ""
    @State private var imageName = ""
    @State private var instructions = ""
    @State private var isRepBased = true
    @State private var sets = 0
    @State private var reps = 0
    @State private var weight = 0
    @State private var duration = 0
    
    init(exercise: Exercise?, onSave: @escaping (Exercise) -> Void, onDelete: (() -> Void)? = nil) {
        self.exercise = exercise
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    private func loadInitialExerciseDetails() {
        if let exercise = exercise {
            name = exercise.name
            imageName = exercise.imageName ?? ""
            instructions = exercise.instructions ?? ""
            
            if let repBasedExercise = exercise as? ExerciseRepBased {
                isRepBased = true
                sets = repBasedExercise.sets
                reps = repBasedExercise.reps
                weight = repBasedExercise.weight
            }
            else if let timeBasedExercise = exercise as? ExerciseTimeBased {
                isRepBased = false
                duration = timeBasedExercise.duration
            }
        }
    }
    
    private func saveExercise() {
        if isRepBased {
            let exercise = ExerciseRepBased(name: name, imageName: imageName, instructions: instructions, sets: sets, reps: reps, weight: weight)
            onSave(exercise)
        } else {
            let exercise = ExerciseTimeBased(name: name, imageName: imageName, instructions: instructions, duration: duration)
            onSave(exercise)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Name", text: $name)
                    TextField("Image Name", text: $imageName)
                    TextField("Instructions", text: $instructions)
                    
                    Picker("Type", selection: $isRepBased.animation()) {
                        Text("Rep Based").tag(true)
                        Text("Time Based").tag(false)
                    }.pickerStyle(.segmented)
                }
                
                if isRepBased {
                    Section(header: Text("Rep Based Details")) {
                        Stepper(value: $sets, in: 0...100) {
                            Text("Sets: \(sets)")
                        }
                        Stepper(value: $reps, in: 0...100) {
                            Text("Reps: \(reps)")
                        }
                        Stepper(value: $weight, in: 0...1000) {
                            Text("Weight: \(weight) kg")
                        }
                    }
                } else {
                    Section(header: Text("Time Based Details")) {
                        Stepper(value: $duration, in: 0...3600) {
                            Text("Duration: \(duration) seconds")
                        }
                    }
                }
                
            }
            .onAppear(perform: loadInitialExerciseDetails)
            .navigationTitle(exercise == nil ? "New Exercise" : "Edit Exercise")
            .navigationBarItems(
                leading: exercise == nil || onDelete == nil ? nil : Button("Delete", action: onDelete!)
                    .foregroundColor(Color.red),
                trailing: Button("Save", action: saveExercise)
            )
        }
    }
}

#Preview("New") {
    ExerciseFormView(exercise: nil, onSave: { exercise in
        print(exercise)
    })
}

#Preview("Edit") {
    ExerciseFormView(
        exercise: ExerciseRepBased(name: "Bench Press", imageName: "bench_press", instructions: "Lie on a bench and press the bar up", sets: 3, reps: 10, weight: 100),
        onSave: { exercise in print(exercise) }
    )
}
