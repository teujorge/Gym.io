//
//  WorkoutFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct WorkoutFormView: View {
    let workout: Workout?
    let onSave: (Workout) -> Void
    let onDelete: (() -> Void)?
    
    @State private var title = ""
    @State private var description = ""
    @State private var exercises = [Exercise]()
    
    @State private var isPresentingExerciseForm = false
    @State private var selectedExercise: Exercise?
    
    init(workout: Workout?, onSave: @escaping (Workout) -> Void, onDelete: (() -> Void)? = nil
    ) {
        self.workout = workout
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    private func loadInitialWorkoutData() {
        if let workout = workout {
            title = workout.title
            description = workout.description ?? ""
            exercises = workout.exercises
        }
    }
    
    private func addExercise() {
        selectedExercise = Exercise(name: "")
        isPresentingExerciseForm = true
    }
    
    private func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    private func editExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        isPresentingExerciseForm = true
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Workout Details")) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                    }
                    
                    Section(header: Text("Exercises")) {
                        ForEach(exercises, id: \.id) { exercise in
                            Text(exercise.name)
                                .swipeActions {
                                    Button(action: { editExercise(exercise) }) {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
                                            exercises.remove(at: index)
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .onDelete(perform: deleteExercise)
                    }
                    
                    Button(action: addExercise) {
                        Text("Add Exercise")
                    }
                }
                .onAppear(perform: loadInitialWorkoutData)
            }
            .navigationTitle(workout == nil ? "New Workout" : "Edit Workout")
            .navigationBarItems(
                leading: (workout == nil || onDelete == nil) ? nil : Button("Delete", action: onDelete!)
                    .foregroundColor(.red),
                trailing: Button("Save") {
                    let newWorkout = Workout(
                        title: title,
                        description: description.isEmpty ? nil : description,
                        exercises: exercises
                    )
                    onSave(newWorkout)
                }
            )
            .sheet(isPresented: $isPresentingExerciseForm) {
                ExerciseFormView(
                    exercise: selectedExercise,
                    onSave: { updatedExercise in
                        if let selectedExercise = selectedExercise {
                            if let index = exercises.firstIndex(where: { $0.id == selectedExercise.id }) {
                                exercises[index] = updatedExercise
                            } else {
                                exercises.append(updatedExercise)
                            }
                        } else {
                            exercises.append(updatedExercise)
                        }
                        isPresentingExerciseForm = false
                    }
                    ,
                    onDelete: {
                        if let selectedExercise = selectedExercise {
                            if let index = exercises.firstIndex(where: { $0.id == selectedExercise.id }) {
                                exercises.remove(at: index)
                            }
                        }
                        isPresentingExerciseForm = false
                    }
                )
            }
        }
    }
}


#Preview("New") {
    WorkoutFormView(workout: nil, onSave: { workout in
        print(workout)
    })
}

#Preview("Edit") {
    WorkoutFormView(workout: _previewWorkouts[0], onSave: { workout in
        print(workout)
    })
}
