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
        ScrollView {
            VStack {
                TextFieldView(label: "Name", placeholder: "Name", text: $viewModel.exercisePlan.name)
                    .padding(.top)
                    .padding(.horizontal)
                TextFieldView(label: "Instructions", placeholder: "Instructions", text: $viewModel.notes, lines: 3)
                    .padding()
            }
            .padding(.vertical)
            
            SetDetailsView(
                details: SetDetails(exercisePlan: viewModel.exercisePlan),
                isEditable: true,
                isPlan: true,
                autoSave: false,
                onDetailsChanged: { setDetails in
                    viewModel.exercisePlan = setDetails.createExercisePlan(from: viewModel.exercisePlan)
                }
            )
            .padding()
        }
        .navigationTitle(viewModel.isEditing ? "Edit Exercise Plan" : "New Exercise Plan")
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
    NavigationView {
        CustomExercisePlanFormView(onSave: { exercise in
            print(exercise)
        })
    }
}

#Preview("Edit") {
    NavigationView {
        CustomExercisePlanFormView(
            exercisePlan: _previewExercisePlans[0],
            onSave: { exercise in print("Save \(exercise)") },
            onDelete: { exercise in print("Delete \(exercise)") }
        )
    }
}
