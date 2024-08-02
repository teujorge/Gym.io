//
//  EditWorkoutHistoryViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 8/2/24.
//

import SwiftUI

class EditWorkoutHistoryViewModel: ObservableObject{
    
    @Published var workout: Workout
    @Published var state: LoaderState = .idle
    
    // TODO: cant change start date... would need to create new one?
    @Published var startDate: Date {
        didSet {
            workout.createdAt = startDate
        }
    }
    @Published var finishDate: Date {
        didSet {
            workout.completedAt = finishDate
        }
    }
    
    init(workout: Workout) {
        workout.exercises.sort { $0.index < $1.index }
        workout.exercises.forEach { $0.sets.sort { $0.index < $1.index } }
        self.workout = workout
        self.startDate = workout.createdAt
        self.finishDate = workout.completedAt ?? Date()
    }
    
    func isLastExercise(exercise: Exercise) -> Bool {
        return workout.exercises.last?.id == exercise.id
    }
    
    func updateWorkout() async -> Workout? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "/workouts/history/\(workout.id)", body: workout, method: .PUT)
        
        switch result {
        case .success(let updatedWorkout):
            print("Workout updated: \(updatedWorkout)")
            DispatchQueue.main.async {
                // self.workout = updatedWorkout // probably best to keep local state and server state separate?
                self.state = .success
            }
            return updatedWorkout
        case .failure(let error):
            print("Failed to update workout: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
        }
        
        return nil
    }
    
    func deleteWorkout() async -> Workout? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "/workouts/history/\(workout.id)", method: .DELETE)
        
        switch result {
        case .success(let deletedWorkout):
            print("Workout deleted: \(deletedWorkout)")
            DispatchQueue.main.async {
                self.state = .success
            }
            return deletedWorkout
        case .failure(let error):
            print("Failed to delete workout: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
        }
        
        return nil
    }
    
}
