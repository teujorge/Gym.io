//
//  CustomExercisePlanFormView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct CustomExercisePlanFormView: View {
    @StateObject private var viewModel: CustomExercisePlanFormViewModel
    
    // Initializer with save functionality only
    init(onSave: @escaping (ExercisePlan) -> Void) {
        _viewModel = StateObject(wrappedValue: CustomExercisePlanFormViewModel(exercisePlan: nil, onSave: onSave, onDelete: nil))
    }
    
    // Initializer with save and delete functionality
    init(exercisePlan: ExercisePlan, onSave: @escaping (ExercisePlan) -> Void, onDelete: @escaping (ExercisePlan) -> Void) {
        _viewModel = StateObject(wrappedValue: CustomExercisePlanFormViewModel(exercisePlan: exercisePlan, onSave: onSave, onDelete: onDelete))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Name", text: $viewModel.exercisePlan.name)
                    TextField("Notes", text: $viewModel.notes)
                }
                Section {
                    SetDetailsView(
                        sets: viewModel.exercisePlan.setPlans.map {
                            SetDetails(
                                id: $0.id,
                                reps: $0.reps,
                                weight: $0.weight,
                                duration: $0.duration,
                                intensity: $0.intensity,
                                completedAt: nil
                            )
                        },
                        isEditable: true,
                        isPlan: true,
                        isRepBased: viewModel.exercisePlan.isRepBased,
                        autoSave: false
                    )
                }
                .padding()
            }
            .navigationTitle(viewModel.isEditing ? "Edit Exercise" : "New Exercise")
            .toolbar {
                if viewModel.isEditing {
                    leadingToolbarItem
                }
                trailingToolbarItem
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
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
    CustomExercisePlanFormView(onSave: { exercise in
        print(exercise)
    })
}

#Preview("Edit") {
    CustomExercisePlanFormView(
        exercisePlan: _previewExercisePlans[0],
        onSave: { exercise in print("Save \(exercise)") },
        onDelete: { exercise in print("Delete \(exercise)") }
    )
}
