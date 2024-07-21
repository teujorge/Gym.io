//
//  CustomExercisePlanFormViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

class CustomExercisePlanFormViewModel: ObservableObject {
    @Published var exercisePlan: ExercisePlan
    @Published var state: LoaderState = .idle
    
    @Published var notes = "" {
        didSet {
            exercisePlan.notes = notes
        }
    }
    
    let onSave: (ExercisePlan) -> Void
    let onDelete: ((ExercisePlan) -> Void)?
    
    let isEditing: Bool
    
    init(exercisePlan: ExercisePlan?, onSave: @escaping (ExercisePlan) -> Void, onDelete: ((ExercisePlan) -> Void)?) {
        self.onSave = onSave
        self.onDelete = onDelete
        
        if let exercisePlan = exercisePlan {
            self.isEditing = true
            self.exercisePlan = exercisePlan
        } else {
            self.isEditing = false
            self.exercisePlan = ExercisePlan(
                name: "",
                notes: "",
                isRepBased: true,
                equipment: .none,
                muscleGroups: [],
                setPlans: []
            )
        }
    }
    
    func addSet() {
        let newIndex = exercisePlan.setPlans.count
        exercisePlan.setPlans.append(ExerciseSetPlan(index: newIndex))
    }
    
    func handleSave() {
        if isEditing {
            Task {
                if let newExercise = await self.requestSave(exercisePlan.id) {
                    self.onSave(newExercise)
                }
            }
        } else {
            self.onSave(exercisePlan)
        }
    }
    
    func handleDelete() {
        Task {
            if await self.requestDelete(exercisePlan.id) {
                self.onDelete?(exercisePlan)
            }
        }
    }
    
    private func requestSave(_ id: String) async -> ExercisePlan? {
        guard isEditing else { return nil }
        
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<ExercisePlan> = await sendRequest(endpoint: "/exercises/templates/\(id)", body: exercisePlan, method: .PUT)
        
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
        
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "/exercises/templates/\(id)", method: .DELETE)
        
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
