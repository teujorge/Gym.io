//
//  WorkoutFormView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct WorkoutFormView: View {
    @EnvironmentObject private var currentUser: User
    @StateObject private var viewModel: WorkoutFormViewModel
    
    // Initializer with save functionality only
    init(onSave: @escaping (Workout) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutFormViewModel(workout: nil, onSave: onSave, onDelete: {workout in}))
    }
    
    // Initializer with workout and delete functionality
    init(workout: Workout, onSave: @escaping (Workout) -> Void, onDelete: @escaping (Workout) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutFormViewModel(workout: workout, onSave: onSave, onDelete: onDelete))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Workout details section
                    Section(header: Text("Workout Details")) {
                        TextField("Title", text: $viewModel.titleText)
                        TextField("Description", text: $viewModel.notesText)
                    }
                    
                    // Exercises section
                    Section(header: Text("Exercises")) {
                        ForEach(viewModel.workout.exercises, id: \.id) { exercise in
                            HStack{
                                Text(exercise.name)
                                Spacer()
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.accent)
                            }
                            
                            
                            .swipeActions {
                                Button(action: { viewModel.editExercise(exercise) }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    if let index = viewModel.workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                        viewModel.workout.exercises.remove(at: index)
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
                    ExerciseFormView(
                        exercise: selectedExercise,
                        onSave: viewModel.handleSaveExercise,
                        onDelete: viewModel.handleDeleteExercise
                    )
                } else {
                    ExerciseFormView(
                        onSave: viewModel.handleSaveExercise
                    )
                }
            }
        }
    }
    
}


#Preview("New") {
    WorkoutFormView(onSave: { workout in
        print("save form")
    })
}

#Preview("Edit") {
    WorkoutFormView(
        workout: _previewWorkouts[0],
        onSave: { workout in
            DispatchQueue.main.async {
                print("save form")
            }
        },
        onDelete: { workout in
            DispatchQueue.main.async {
                print("del form")
            }
        }
    )
}