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
    let onDelete: ((Exercise) -> Void)?
    
    @State private var name = ""
    @State private var imageName = ""
    @State private var notes = ""
    @State private var sets: [ExerciseSet] = []
    @State private var isRepBased = true
    
    // Initializer with save functionality only
    init(onSave: @escaping (Exercise) -> Void) {
        self.exercise = nil
        self.onSave = onSave
        self.onDelete = nil
    }
    
    // Initializer with save and delete functionality
    init(exercise: Exercise, onSave: @escaping (Exercise) -> Void, onDelete: @escaping (Exercise) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    // Leading navigation bar item
    private var leadingNavigationBarItem: some View {
        Group {
            if let exercise = exercise, let onDelete = onDelete {
                Button("Delete") {
                    onDelete(exercise)
                }
                .foregroundColor(.red)
            } else {
                EmptyView()
            }
        }
    }
    
    // Trailing navigation bar item
    private var trailingNavigationBarItem: some View {
        Button("Save") {
            handleSaveExercise()
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // Exercise details section
                Section(header: Text("Exercise Details")) {
                    TextField("Name", text: $name)
                    TextField("Image Name", text: $imageName)
                    TextField("notes", text: $notes)
                    
                    Picker("Type", selection: $isRepBased.animation()) {
                        Text("Rep Based").tag(true)
                        Text("Time Based").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                ForEach(Array(sets.enumerated()), id: \.element.id) { (i, set) in
                    Section(header: Text("Set \(i + 1)")) {
                        SetDetailsView(isRepBased: isRepBased, set: $sets[i])
                    }
                }
                
                
                // Add set button
                Button("Add Set") {
                    let newIndex = sets.count
                    sets.append(ExerciseSet(index: newIndex))
                }
                
            }
            .onAppear(perform: loadInitialExerciseDetails)
            .navigationTitle(exercise == nil ? "New Exercise" : "Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingNavigationBarItem
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavigationBarItem
                }
            }
        }
    }
    
    // MARK: - Helper functions
    
    // Load initial exercise details
    private func loadInitialExerciseDetails() {
        if let exercise = exercise {
            name = exercise.name
            imageName = exercise.imageName ?? ""
            notes = exercise.notes ?? ""
            sets = exercise.sets
        }
    }
    
    // Save exercise details
    private func handleSaveExercise() {
        let exercise = Exercise(index: exercise?.index ?? 1, name: name, imageName: imageName, notes: notes, sets: sets)
        onSave(exercise)
    }
    
}

struct SetDetailsView: View {
    let isRepBased: Bool
    @Binding var set: ExerciseSet

    var body: some View {
        // Rep-based details section
        if isRepBased {
            Section(header: Text("Details")) {
                Stepper(value: Binding(get: {
                    set.reps ?? 0
                }, set: {
                    set.reps = $0
                }), in: 0...100) {
                    Text("Reps: \(set.reps ?? 0)")
                }
                Stepper(value: Binding(get: {
                    set.weight ?? 0
                }, set: {
                    set.weight = $0
                }), in: 0...1000) {
                    Text("Weight: \(set.weight ?? 0) kg")
                }
            }
        } else {
            // Time-based details section
            Section(header: Text("Details")) {
                Stepper(value: Binding(get: {
                    set.duration ?? 0
                }, set: {
                    set.duration = $0
                }), in: 0...3600) {
                    Text("Duration: \(set.duration ?? 0) seconds")
                }
                // TODO: Add intensity picker
            }
        }
    }
}


#Preview("New") {
    ExerciseFormView(onSave: { exercise in
        print(exercise)
    })
}

#Preview("Edit") {
    ExerciseFormView(
        exercise: _previewExercises[0],
        onSave: { exercise in print("Save \(exercise)") },
        onDelete: { exercise in print("Delete \(exercise)") }
    )
}
