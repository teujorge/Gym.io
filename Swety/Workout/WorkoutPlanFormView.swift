//
//  WorkoutPlanFormView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct WorkoutPlanFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.dismissAll) var dismissAll
    @EnvironmentObject private var currentUser: User
    @StateObject private var viewModel: WorkoutPlanFormViewModel
    
    // Initializer with save functionality only
    init(onSave: @escaping (WorkoutPlan) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanFormViewModel(workoutPlan: nil, onSave: onSave, onDelete: {workoutPlan in}))
    }
    
    // Initializer with workout, save and delete functionality
    init(workoutPlan: WorkoutPlan, onSave: @escaping (WorkoutPlan) -> Void, onDelete: @escaping (WorkoutPlan) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanFormViewModel(workoutPlan: workoutPlan, onSave: onSave, onDelete: onDelete))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack {
                    // Workout details section
                    TextFieldView(label: "Name", placeholder: "Name", text: $viewModel.nameText)
                        .padding(.top)
                        .padding(.horizontal)
                    TextFieldView(label: "Description", placeholder: "Description", text: $viewModel.notesText, lines: 3)
                        .padding()
                }
                .padding(.vertical)
                
                // Exercises section
                ForEach(Array(viewModel.workoutPlan.exercisePlans.enumerated()), id: \.offset) { index, exercisePlan in
                    VStack(alignment: .leading) {
                        HStack {
                            // Title
                            Text(exercisePlan.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            // Move and Delete Buttons
                            HStack(spacing: 16) {
                                if index != 0 {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.moveExerciseUp(index: index)
                                        }
                                    }) {
                                        Image(systemName: "arrow.up")
                                            .foregroundColor(.accent)
                                    }
                                }
                                if index != viewModel.workoutPlan.exercisePlans.count - 1 {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.moveExerciseDown(index: index)
                                        }
                                    }) {
                                        Image(systemName: "arrow.down")
                                            .foregroundColor(.accent)
                                    }
                                }
                                Button(action: {
                                    withAnimation {
                                        viewModel.deleteExercise(index: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        
                        SetDetailsView(
                            details: SetDetails(exercisePlan: exercisePlan),
                            isEditable: true,
                            isPlan: true,
                            autoSave: false,
                            onDetailsChanged: { setDetails in
                                let updatedExercisePlan = setDetails.updateExercisePlan(exercisePlan: exercisePlan)
                                viewModel.workoutPlan.exercisePlans[index] = updatedExercisePlan
                                // viewModel.updateExerciseSets(exerciseId: exercisePlan.id, sets: sets) // do we need this?
                                viewModel.workoutPlan.exercisePlans[index].setPlans.map {
                                    $0.print()
                                }
                            }
                        )
                        .id(exercisePlan.id)
                        
                        if index < viewModel.workoutPlan.exercisePlans.count - 1 {
                            Divider()
                                .padding(.top, 32)
                        }
                    }
                    .padding()
                    .transition(.move(edge: .bottom))
                    .swipeActions {
                        Button(action: { viewModel.editExercisePlan(exercisePlan) }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: {
                            if let index = viewModel.workoutPlan.exercisePlans.firstIndex(where: { $0.id == exercisePlan.id }) {
                                viewModel.workoutPlan.exercisePlans.remove(at: index)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .animation(.default, value: viewModel.workoutPlan.exercisePlans)
                
                // Add exercise button
                NavigationLink(
                    destination: ExercisePlansView(selectedExercises: $viewModel.workoutPlan.exercisePlans)
                ) {
                    Text("Add Exercise")
                        .foregroundColor(.accent)
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accent)
                }
                .padding()
                .buttonStyle(.plain)
                .background(.accent.opacity(0.2))
                .cornerRadius(.medium)
                .padding()
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Workout" : "New Workout")
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") { viewModel.delete() { dismissAll() } }
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { viewModel.save() { dismiss() } }
            }
            if viewModel.state != .idle {
                ToolbarItem(placement: .status) {
                    LoaderView(state: viewModel.state)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
}


#Preview("New") {
    NavigationView {
        WorkoutPlanFormView(onSave: { workout in
            print("save form")
        })
    }
}

#Preview("Edit") {
    NavigationView {
        WorkoutPlanFormView(
            workoutPlan: _previewWorkoutPlans[0],
            onSave: { workoutPlan in
                DispatchQueue.main.async {
                    print("save form")
                }
            },
            onDelete: { workoutPlan in
                DispatchQueue.main.async {
                    print("del form")
                }
            }
        )
    }
}
