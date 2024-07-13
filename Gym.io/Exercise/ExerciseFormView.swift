//
//  ExerciseFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct ExerciseFormView: View {
    @StateObject private var viewModel: ExerciseFormViewModel
    
    // Initializer with save functionality only
    init(onSave: @escaping (Exercise) -> Void) {
        _viewModel = StateObject(wrappedValue: ExerciseFormViewModel(exercise: nil, onSave: onSave, onDelete: nil))
    }
    
    // Initializer with save and delete functionality
    init(exercise: Exercise, onSave: @escaping (Exercise) -> Void, onDelete: @escaping (Exercise) -> Void) {
        _viewModel = StateObject(wrappedValue: ExerciseFormViewModel(exercise: exercise, onSave: onSave, onDelete: onDelete))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Name", text: $viewModel.exercise.name)
//                    TextField("Image Name", text: viewModel.exercise.imageName)
//                    TextField("Notes", text: viewModel.exercise.notes)
                    Picker("Type", selection: $viewModel.exercise.isRepBased.animation()) {
                        Text("Rep Based").tag(true)
                        Text("Time Based").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                SetDetailsView(exercise: viewModel.exercise, autoSave: false)
            }
            .navigationTitle(viewModel.isEditing ? "Edit Exercise" : "New Exercise")
            .toolbar {
                if viewModel.isEditing {
                    leadingToolbarItem
                }
                trailingToolbarItem
            }
        }
    }
    
    var leadingToolbarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Delete", action: viewModel.handleDelete)
                .foregroundColor(.red)
        }
    }
    
    var trailingToolbarItem: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save", action: viewModel.handleSave)
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
