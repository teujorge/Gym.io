//
//  WorkoutsViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

enum WorkoutFormViewState {
    case idle
    case operating
    case finished
    case error(String)
}

class WorkoutFormViewModel: ObservableObject {
    
    let isEditing: Bool
    var onSave: (Workout) -> Void
    var onDelete: (Workout) -> Void
    
    @Published var workout: Workout
    @Published var isPresentingExerciseForm = false
    @Published var selectedExercise: Exercise?
    @Published var state: WorkoutFormViewState = .idle
    
    @Published var titleText = "" {
        didSet {
            workout.title = titleText
        }
    }
    @Published var notesText = "" {
        didSet {
            workout.notes = notesText
        }
    }
    
    init(workout: Workout?, onSave: @escaping (Workout) -> Void, onDelete: @escaping (Workout) -> Void) {
        if let workout = workout {
            self.isEditing = true
            self.workout = workout
            self.titleText = workout.title
            self.notesText = workout.notes ?? ""
        } else {
            self.isEditing = false
            self.workout = Workout(ownerId: currentUserId ,title: "", notes: "", exercises: [])
        }
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    func addExercise() {
        selectedExercise = nil
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
    
    private func createWorkout() async -> Workout? {
        guard !workout.title.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide a title for your workout")
                self.state = .error("Please provide a title for your workout")
            }
            return nil
        }
        
        guard !workout.ownerId.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide an owner ID for your workout")
                self.state = .error("Please provide an owner ID for your workout")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .operating
        }
        
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "workouts", body: workout, method: .POST)
        
        
        switch result {
        case .success(let createdWorkout):
            DispatchQueue.main.async {
                print("Workout created: \(createdWorkout)")
                self.state = .finished
            }
            return createdWorkout
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to create workout: \(error)")
                self.state = .error(error)
            }
            return nil
            
        }
    }
    
    private func updateWorkout() async -> Workout? {
        guard !workout.title.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide a title for your workout")
                self.state = .error("Please provide a title for your workout")
            }
            return nil
        }
        
        guard !workout.ownerId.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide an owner ID for your workout")
                self.state = .error("Please provide an owner ID for your workout")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .operating
        }
        
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "workouts/\(workout.id)", body: workout, method: .PUT)
        
        switch result {
        case .success(let updatedWorkout):
            DispatchQueue.main.async {
                print("Workout updated: \(updatedWorkout)")
                self.state = .finished
            }
            return updatedWorkout
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to update workout: \(error)")
                self.state = .error(error)
            }
            return nil
        }
    }
    
    func delete() {
        Task {
            let success = await handleDeleteWorkout()
            if success {
                onDelete(workout)
            }
            else {
                print("Failed to delete workout")
            }
        }
    }
    
    private func handleDeleteWorkout() async -> Bool {
        DispatchQueue.main.async {
            self.state = .operating
        }
        
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "workouts/\(workout.id)", body: nil, method: .DELETE)
        
        switch result {
        case .success:
            DispatchQueue.main.async {
                print("Workout successfully deleted")
                self.state = .finished
            }
            return true
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to delete workout: \(error)")
                self.state = .error(error)
            }
            return false
        }
    }
    
}
