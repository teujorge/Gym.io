//
//  WorkoutPlanFormViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

class WorkoutPlanFormViewModel: ObservableObject {
    
    let isEditing: Bool
    var onSave: (WorkoutPlan) -> Void
    var onDelete: (WorkoutPlan) -> Void
    let allInitialExerciseIds: [String]
    
    @Published var workoutPlan: WorkoutPlan
    @Published var selectedExercise: ExercisePlan?
    @Published var state: LoaderState = .idle
    
    @Published var nameText = "" {
        didSet {
            workoutPlan.name = nameText
        }
    }
    @Published var notesText = "" {
        didSet {
            workoutPlan.notes = notesText
        }
    }
    
    var enumeratedExercisePlans: EnumeratedSequence<[ExercisePlan]> {
//        print("exercisePlans count: \(workoutPlan.exercisePlans.count)")
        return workoutPlan.exercisePlans.enumerated()
    }
    
    init(workoutPlan: WorkoutPlan?, onSave: @escaping (WorkoutPlan) -> Void, onDelete: @escaping (WorkoutPlan) -> Void) {
        if let workoutPlan = workoutPlan {
            self.isEditing = true
            self.workoutPlan = workoutPlan
            self.nameText = workoutPlan.name
            self.notesText = workoutPlan.notes ?? ""
        } else {
            self.isEditing = false
            self.workoutPlan = WorkoutPlan(name: "", notes: "", ownerId: currentUserId, exercisePlans: [])
        }
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Used to delete exercises that were removed
        self.allInitialExerciseIds = workoutPlan?.exercisePlans.map { $0.id } ?? []
        self.updateIndexes()
    }
    
    func deleteExercise(index: Int) {
        guard index >= 0 && index < workoutPlan.exercisePlans.count else {
            print("Attempted to delete exercise at invalid index: \(index)")
            return
        }
        workoutPlan.exercisePlans.remove(at: index)
        updateIndexes()
    }
    
    func moveExerciseUp(index: Int) {
        guard index > 0 else { return }
        workoutPlan.exercisePlans.swapAt(index, index - 1)
        updateIndexes()
    }
    
    func moveExerciseDown(index: Int) {
        guard index < workoutPlan.exercisePlans.count - 1 else { return }
        workoutPlan.exercisePlans.swapAt(index, index + 1)
        updateIndexes()
    }
    
    func handleSetChange(index: Int, setDetails: SetDetails) {
        if index >= 0 && index < workoutPlan.exercisePlans.count {
            workoutPlan.exercisePlans[index] = setDetails.createExercisePlan(from: workoutPlan.exercisePlans[index])
        } else {
            print("Attempted to update exercise plan at invalid index: \(index)")
        }
    }
    
    func updateExerciseSets(exerciseId: String, sets: [SetDetail]) {
        if let index = workoutPlan.exercisePlans.firstIndex(where: { $0.id == exerciseId }) {
            workoutPlan.exercisePlans[index].setPlans = sets.enumerated().map { index, set in
                set.toSetPlan(index: index)
            }
            updateIndexes()
        }
    }
    
    private func updateIndexes() {
        for (index, exercisePlan) in workoutPlan.exercisePlans.enumerated() {
            exercisePlan.index = index
        }
        print("Updated indices: \(workoutPlan.exercisePlans.map { $0.index })")
    }
    
    func save(onSuccess: @escaping () -> Void) {
        Task {
            if isEditing {
                if let newWorkout = await updateWorkout() {
                    DispatchQueue.main.async {
                        onSuccess()
                        self.onSave(newWorkout)
                    }
                } else {
                    print("Failed to update workout")
                }
            } else {
                if let newWorkout = await createWorkout() {
                    DispatchQueue.main.async {
                        onSuccess()
                        self.onSave(newWorkout)
                    }
                } else {
                    print("Failed to create workout")
                }
            }
        }
    }
    
    func delete(onSuccess: @escaping () -> Void) {
        Task {
            if await handleDeleteWorkout() {
                DispatchQueue.main.async {
                    onSuccess()
                    self.onDelete(self.workoutPlan)
                }
            }
            else {
                print("Failed to delete workout")
            }
        }
    }
    
    private func createWorkout() async -> WorkoutPlan? {
        guard !workoutPlan.name.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide a title for your workout")
                self.state = .failure("Please provide a title for your workout")
            }
            return nil
        }
        
        guard !workoutPlan.ownerId.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide an owner ID for your workout")
                self.state = .failure("Please provide an owner ID for your workout")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<WorkoutPlan> = await sendRequest(endpoint: "/workouts/templates", body: workoutPlan, method: .POST)
        
        
        switch result {
        case .success(let createdWorkout):
            DispatchQueue.main.async {
                print("Workout created: \(createdWorkout)")
                self.state = .success
            }
            return createdWorkout
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to create workout: \(error)")
                self.state = .failure(error)
            }
            return nil
            
        }
    }
    
    private func updateWorkout() async -> WorkoutPlan? {
        guard !workoutPlan.name.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide a title for your workout")
                self.state = .failure("Please provide a title for your workout")
            }
            return nil
        }
        
        guard !workoutPlan.ownerId.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide an owner ID for your workout")
                self.state = .failure("Please provide an owner ID for your workout")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let removedExerciseIds = allInitialExerciseIds.filter { id in
            !workoutPlan.exercisePlans.contains { $0.id == id }
        }
        
        if !removedExerciseIds.isEmpty {
            let exerciseDeletionResult: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "/exercises/templates", body: removedExerciseIds, method: .DELETE)
            print("Exercise deletion result: \(exerciseDeletionResult)")
        }
        
        let result: HTTPResponse<WorkoutPlan> = await sendRequest(endpoint: "/workouts/templates/\(workoutPlan.id)", body: workoutPlan, method: .PUT)
        
        switch result {
        case .success(let updatedWorkout):
            DispatchQueue.main.async {
                print("Workout updated: \(updatedWorkout)")
                self.state = .success
            }
            return updatedWorkout
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to update workout: \(error)")
                self.state = .failure(error)
            }
            return nil
        }
    }
    
    private func handleDeleteWorkout() async -> Bool {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "/workouts/templates/\(workoutPlan.id)", body: nil, method: .DELETE)
        
        switch result {
        case .success:
            DispatchQueue.main.async {
                print("Workout successfully deleted")
                self.state = .success
            }
            return true
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to delete workout: \(error)")
                self.state = .failure(error)
            }
            return false
        }
    }
    
}
