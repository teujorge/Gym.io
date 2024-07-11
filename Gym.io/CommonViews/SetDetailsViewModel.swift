//
//  SetDetailsViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/11/24.
//

import SwiftUI

class SetDetailsViewModel: ObservableObject {
    @Published var exercise: Exercise
    @Published var state: LoaderState = .idle
    
    private var updateTimer: Timer?
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    func addSet() {
        // Create a new set with a temporary id
        let tempSet = ExerciseSet(index: exercise.sets.count + 1)
        exercise.sets.append(tempSet)
        state = .idle
        
        // Save the set to the backend
        Task {
            await saveSet(tempSet)
        }
    }
    
    func updateSet(at index: Int, with set: ExerciseSet) {
        guard index < exercise.sets.count else { return }
        exercise.sets[index] = set

        // Debounce the update to prevent multiple rapid server requests
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.saveUpdatedSet(set: set)
        }
    }
    
    private func saveUpdatedSet(set: ExerciseSet) {
        guard let index = exercise.sets.firstIndex(where: { $0.id == set.id }) else { return }
        let updatedSet = exercise.sets[index]
        // Now call your async function to update the set on the server
        Task {
            await requestUpdateSet(at: index, with: updatedSet)
        }
    }
    
    func deleteSet(at index: Int) {
        guard index < exercise.sets.count else { return }
        
        print("""
            Deleting set:
            Index: \(index)
            Set duration: \(exercise.sets[index].duration)
            """)
        
        // Remove the set from the backend
        Task {
            await requestDeleteSet(at: index)
        }
    }
    
    private func saveSet(_ set: ExerciseSet) async {
        var newSet = set
        newSet.exerciseId = exercise.id
        
        let response: HTTPResponse<ExerciseSet> = await sendRequest(endpoint: "sets", body: newSet, method: .POST)
        handleResponse(response)
        
        // Update the model with the backend response
        switch response {
        case .success(let backendSet):
            if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
                exercise.sets[index] = backendSet
            }
        case .failure(let error):
            print("Failed to decode set: \(error)")
        }
    }
    
    private func requestUpdateSet(at index: Int, with set: ExerciseSet) async {
        let response: HTTPResponse<ExerciseSet> = await sendRequest(endpoint: "sets/\(set.id)", body: set, method: .PUT)
        handleResponse(response)

        // Update the model with the backend response
        switch response {
        case .success(let backendSet):
            exercise.sets[index] = backendSet
        case .failure(let error):
            print("Failed to decode set: \(error)")
        }
    }
    
    private func requestDeleteSet(at index: Int) async {
        let response: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "sets/\(exercise.sets[index].id)", method: .DELETE)
        handleResponse(response)
        exercise.sets.remove(at: index)
    }

    private func handleResponse<T>(_ response: HTTPResponse<T>) {
        DispatchQueue.main.async {
            switch response {
            case .success:
                self.state = .success
            case .failure(let error):
                self.state = .failure(error)
            }
        }
    }
}