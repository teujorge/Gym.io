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
    let onDelete: ((Workout) -> Void)?
    
    @State private var title = ""
    @State private var description = ""
    @State private var exercises = [Exercise]()
    
    @State private var isPresentingExerciseForm = false
    @State private var selectedExercise: Exercise?
    
    // Initializer with save functionality only
    init(onSave: @escaping (Workout) -> Void) {
        self.workout = nil
        self.onSave = onSave
        self.onDelete = nil
    }
    
    // Initializer with workout and delete functionality
    init(workout: Workout?, onSave: @escaping (Workout) -> Void, onDelete: @escaping (Workout) -> Void) {
        self.workout = workout
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    // Navigation bar leading item
    private var leadingNavigationBarItem: some View {
        Group {
            if let workout = workout, let onDelete = onDelete {
                Button("Delete") { onDelete(workout) }
                    .foregroundColor(.red)
            } else {
                EmptyView()
            }
        }
    }
    
    // Navigation bar trailing item
    private var trailingNavigationBarItem: some View {
        Button("Save") {
            let newWorkout = Workout(
                title: title,
                description: description.isEmpty ? nil : description,
                exercises: exercises
            )
            onSave(newWorkout)
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Workout details section
                    Section(header: Text("Workout Details")) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                    }
                    
                    // Exercises section
                    Section(header: Text("Exercises")) {
                        ForEach(exercises, id: \.id) { exercise in
                            HStack{
                                Text(exercise.name)
                                Spacer()
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.blue)
                            }
                            
                        
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
                        .onMove(perform: moveExercise)
                        .onDelete(perform: deleteExercise)
                    }
                    
                    // Add exercise button
                    Button(action: addExercise) {
                        Text("Add Exercise")
                    }
                }
                .onAppear(perform: loadInitialWorkoutData)
            }
            .navigationTitle(workout == nil ? "New Workout" : "Edit Workout")
            .navigationBarItems(
                leading: leadingNavigationBarItem,
                trailing: trailingNavigationBarItem
            )
            .sheet(isPresented: $isPresentingExerciseForm) {
                if let selectedExercise = selectedExercise {
                    ExerciseFormView(
                        exercise: selectedExercise,
                        onSave: handleSaveExercise,
                        onDelete: handleDeleteExercise
                    )
                } else {
                    ExerciseFormView(
                        onSave: handleSaveExercise
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
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
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
            exercises.move(fromOffsets: source, toOffset: destination)
        }
    
    private func deleteExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    private func editExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        isPresentingExerciseForm = true
    }
    
    private func handleSaveExercise(_ updatedExercise: Exercise) {
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
    
    private func handleDeleteExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises.remove(at: index)
        }
        isPresentingExerciseForm = false
    }
}


// MARK: Preview

#Preview("New") {
    WorkoutFormView(onSave: { workout in
        print(workout)
    })
}

#Preview("Edit") {
    WorkoutFormView(
        workout: _previewWorkouts[0],
        onSave: { workout in
            print(workout)
        },
        onDelete: { workout in
            print("Deleted workout: \(workout)")
        }
    )
}
