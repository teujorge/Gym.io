//
//  WorkoutPlanFormView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct WorkoutPlanFormView: View {
    @EnvironmentObject private var currentUser: User
    @StateObject private var viewModel: WorkoutPlanFormViewModel
    
    // Initializer with save functionality only
    init(onSave: @escaping (WorkoutPlan) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanFormViewModel(workoutPlan: nil, onSave: onSave, onDelete: {workoutPlan in}))
    }
    
    // Initializer with workout and delete functionality
    init(workoutPlan: WorkoutPlan, onSave: @escaping (WorkoutPlan) -> Void, onDelete: @escaping (WorkoutPlan) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanFormViewModel(workoutPlan: workoutPlan, onSave: onSave, onDelete: onDelete))
    }
    
    var body: some View {
        VStack {
            Form {
                // Workout details section
                Section(header: Text("Workout Plan Details")) {
                    TextField("Name", text: $viewModel.nameText)
                    TextField("Description", text: $viewModel.notesText)
                }
                
                // Exercises section
                Section(header: Text("Exercises")) {
                    ForEach(viewModel.workoutPlan.exercisePlans) { exercise in
                        VStack {
                            Text(exercise.name)
                            SetDetailsView(
                                sets: exercise.setPlans.map { plan in
                                    SetDetails(exerciseSetPlan: plan)
                                },
                                isEditable: true,
                                isPlan: true,
                                isRepBased: exercise.isRepBased,
                                autoSave: false,
                                onToggleIsRepBased: { isRepBased in
                                    exercise.isRepBased = isRepBased
                                },
                                onSetsChanged: { sets in
                                    exercise.setPlans = sets.enumerated().map { index, set in
                                        set.toSetPlan(index: index)
                                    }
                                }
                            )
                        }
                        .swipeActions {
                            Button(action: { viewModel.editExercise(exercise) }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                if let index = viewModel.workoutPlan.exercisePlans.firstIndex(where: { $0.id == exercise.id }) {
                                    viewModel.workoutPlan.exercisePlans.remove(at: index)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onMove(perform: viewModel.moveExercise)
                    .onDelete(perform: viewModel.deleteExercise)
                }
                
                // Add exercise button
                NavigationLink(
                    destination: ExercisePlansView(selectedExercises: $viewModel.workoutPlan.exercisePlans)
                ) {
                    HStack {
                        Text("Add Exercise")
                            .foregroundColor(.accent)
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accent)
                    }
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Workout" : "New Workout")
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") { viewModel.delete() }
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { viewModel.save() }
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
