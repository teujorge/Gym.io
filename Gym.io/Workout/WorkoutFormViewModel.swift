//
//  WorkoutsViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI


class WorkoutFormViewModel: ObservableObject {
    @Published var workout: Workout
    let onSave: (Workout) -> Void
    let onDelete: ((Workout) -> Void)?
    
    @Published var isPresentingExerciseForm = false
    @Published var selectedExercise: Exercise?
    
    let isEditing: Bool
    
    init(workout: Workout?, onSave: @escaping (Workout) -> Void, onDelete: ((Workout) -> Void)?) {
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let workout = workout {
            self.isEditing = true
            self.workout = workout
        } else {
            self.isEditing = false
            self.workout = Workout(ownerId: UserDefaults.standard.string(forKey: .userId) ?? "" ,title: "", notes: "", exercises: [])
        }
    }
    
    func addExercise() {
        selectedExercise = Exercise(index: 1, name: "", sets: [], isRepBased: true)
        isPresentingExerciseForm = true
    }
    
    func moveExercise(from source: IndexSet, to destination: Int) {
        workout.exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteExercise(at offsets: IndexSet) {
        workout.exercises.remove(atOffsets: offsets)
    }
    
    func editExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        isPresentingExerciseForm = true
    }
    
    func handleSaveExercise(_ updatedExercise: Exercise) {
        if let selectedExercise = selectedExercise {
            if let index = workout.exercises.firstIndex(where: { $0.id == selectedExercise.id }) {
                workout.exercises[index] = updatedExercise
            } else {
                workout.exercises.append(updatedExercise)
            }
        } else {
            workout.exercises.append(updatedExercise)
        }
        isPresentingExerciseForm = false
    }
    
    func handleDeleteExercise(_ exercise: Exercise) {
        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
            workout.exercises.remove(at: index)
        }
        isPresentingExerciseForm = false
    }
    
}
