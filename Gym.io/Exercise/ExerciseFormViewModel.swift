//
//  ExerciseFormViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

class ExerciseFormViewModel: ObservableObject {
    @Published var exercise: Exercise
    @Published var state: LoaderState = .idle
    
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
    
    func handleSave() {
        if isEditing {
            Task {
                if let newExercise = await self.requestSave(exercise.id) {
                    self.onSave(newExercise)
                }
            }
        } else {
            self.onSave(exercise)
        }
    }
    
    func handleDelete() {
        Task {
            if await self.requestDelete(exercise.id) {
                self.onDelete?(exercise)
            }
        }
    }
    
    private func requestSave(_ id: String) async -> Exercise? {
        guard isEditing else { return nil }
        
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<Exercise> = await sendRequest(endpoint: "exercises/\(id)", body: exercise, method: .PUT)
        
        switch result {
        case .success(let exercise):
            DispatchQueue.main.async {
                self.state = .success
            }
            return exercise
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            print(error)
        }
        
        return nil
    }
    
    private func requestDelete(_ id: String) async -> Bool {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "exercises/\(id)", method: .DELETE)
        
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.state = .success
            }
            return true
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            print(error)
        }
        
        return false
    }

}
