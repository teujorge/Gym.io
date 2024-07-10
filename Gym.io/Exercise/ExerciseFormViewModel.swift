//
//  ExerciseFormViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

class ExerciseFormViewModel: ObservableObject {
    @Published var exercise: Exercise
    
    let onSave: (Exercise) -> Void
    let onDelete: ((Exercise) -> Void)?
    
    let isEditing: Bool
    
    init(exercise: Exercise?, onSave: @escaping (Exercise) -> Void, onDelete: ((Exercise) -> Void)?) {
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let exercise = exercise {
            self.isEditing = true
            self.exercise = exercise
        } else {
            self.isEditing = false
            self.exercise = Exercise(index: 1, name: "", notes: "", sets: [], isRepBased: true)
        }
    }
    
    func addSet() {
        let newIndex = exercise.sets.count
        exercise.sets.append(ExerciseSet(index: newIndex))
    }
    
    func handleSaveExercise() {
        onSave(exercise)
    }
    
    func handleDeleteExercise() {
        // TODO: delete
    }
}
