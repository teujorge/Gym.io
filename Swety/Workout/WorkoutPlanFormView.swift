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
        NavigationView {
            VStack {
                Form {
                    // Workout details section
                    Section(header: Text("Workout Plan Details")) {
                        TextField("Name", text: $viewModel.nameText)
                        TextField("Description", text: $viewModel.notesText)
                    }
                    
                    // TODO: fix
//                    // Exercises section
//                    Section(header: Text("Exercises")) {
//                        ForEach(viewModel.workout.exercises, id: \.id) { exercise in
//                            HStack{
//                                Text(exercise.name)
//                                Spacer()
//                                Image(systemName: "line.horizontal.3")
//                                    .foregroundColor(.accent)
//                            }
//                            
//                            
//                            .swipeActions {
//                                Button(action: { viewModel.editExercise(exercise) }) {
//                                    Label("Edit", systemImage: "pencil")
//                                }
//                                
//                                Button(role: .destructive, action: {
//                                    if let index = viewModel.workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
//                                        viewModel.workout.exercises.remove(at: index)
//                                    }
//                                }) {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                        }
//                        .onMove(perform: viewModel.moveExercise)
//                        .onDelete(perform: viewModel.deleteExercise)
//                    }
                    
                    // Add exercise button
                    Button(action: viewModel.addExercise) {
                        Text("Add Exercise")
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
            .sheet(isPresented: $viewModel.isPresentingExerciseForm) {
                if let selectedExercise = viewModel.selectedExercise {
                    ExercisePlanFormView(
                        exercisePlan: selectedExercise,
                        onSave: viewModel.handleSaveExercise,
                        onDelete: viewModel.handleDeleteExercise
                    )
                } else {
                    ExercisePlanFormView(
                        onSave: viewModel.handleSaveExercise
                    )
                }
            }
        }
    }
    
}


#Preview("New") {
    WorkoutPlanFormView(onSave: { workout in
        print("save form")
    })
}

#Preview("Edit") {
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
