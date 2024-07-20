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
    
    @Published var workoutPlan: WorkoutPlan
    @Published var isPresentingExerciseForm = false
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
    }
    
    func addExercise() {
        selectedExercise = nil
        isPresentingExerciseForm = true
    }
    
    func moveExercise(from source: IndexSet, to destination: Int) {
        workoutPlan.exercisePlans.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteExercise(at offsets: IndexSet) {
        workoutPlan.exercisePlans.remove(atOffsets: offsets)
    }
    
    func editExercise(_ exercise: ExercisePlan) {
        selectedExercise = exercise
        isPresentingExerciseForm = true
    }
    
    func handleSaveExercise(_ updatedExercise: ExercisePlan) {
        if let selectedExercise = selectedExercise {
            if let index = workoutPlan.exercisePlans.firstIndex(where: { $0.id == selectedExercise.id }) {
                workoutPlan.exercisePlans[index] = updatedExercise
            } else {
                workoutPlan.exercisePlans.append(updatedExercise)
            }
        } else {
            workoutPlan.exercisePlans.append(updatedExercise)
        }
        isPresentingExerciseForm = false
    }
    
    func handleDeleteExercise(_ exercise: ExercisePlan) {
        if let index = workoutPlan.exercisePlans.firstIndex(where: { $0.id == exercise.id }) {
            workoutPlan.exercisePlans.remove(at: index)
        }
        isPresentingExerciseForm = false
    }
    
    func save() {
        Task {
            if isEditing {
                if let newWorkout = await updateWorkout() {
                    onSave(newWorkout)
                } else {
                    print("Failed to update workout")
                }
            } else {
                if let newWorkout = await createWorkout() {
                    onSave(newWorkout)
                } else {
                    print("Failed to create workout")
                }
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
    
    func delete() {
        Task {
            let success = await handleDeleteWorkout()
            if success {
                onDelete(workoutPlan)
            }
            else {
                print("Failed to delete workout")
            }
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
