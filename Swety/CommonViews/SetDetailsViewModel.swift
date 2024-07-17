//
//  SetDetailsViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/11/24.
//

import SwiftUI
import Combine

class SetDetailsViewModel: ObservableObject {
    @Published var state: LoaderState = .idle
    @Published var exercise: Exercise {
        didSet { onExerciseEdited() }
    }
    
    @Published var listHeight = 0.0
    let rowHeight = 40.0
    let rowInsets = 20.0
    
    private var autoSave: Bool
    private var updateTimer: Timer?
    var onSetComplete: ((ExerciseSet) -> Void)?
    
    init(exercise: Exercise, autoSave: Bool, onSetComplete: ((ExerciseSet) -> Void)?) {
        self.exercise = exercise
        self.autoSave = autoSave
        self.onSetComplete = onSetComplete
        self.listHeight = Double(exercise.sets.count) * (rowHeight + rowInsets)
    }
    
    private func onExerciseEdited() {
        print("Exercise edited")
        print("-> all sets: \(exercise.sets.map { $0.reps })")
        
        updateTimer?.invalidate() // Invalidate any existing timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.saveUpdatedExercise()
        }
    }
    
    private func saveUpdatedExercise() {
        print("Saving updated exercise!!!!! :)")
        guard autoSave else { return }
        print("auto save is on")
        Task {
            let response: HTTPResponse<Exercise> = await sendRequest(endpoint: "exercises/\(exercise.id)", body: exercise, method: .PUT)
            handleResponse(response)
        }
    }
    func toggleSetCompletion(_ id: String) {
        guard let index = exercise.sets.firstIndex(where: { $0.id == id }) else { return }
        
        if exercise.sets[index].completedAt == nil {
            exercise.sets[index].completedAt = Date()
            
        }else{
            exercise.sets[index].completedAt = nil
        }
        onExerciseEdited()
        onSetComplete?(exercise.sets[index])
    }
    
    
    func addSet() {
        // Create a new set with a temporary id
        let tempSet = ExerciseSet(index: exercise.sets.count + 1)
        exercise.sets.append(tempSet)
        
        // Save the set to the backend
        Task { await saveSet(tempSet) }
    }
    
    func updateSet(for id: String, with set: ExerciseSet) {
        exercise.sets = exercise.sets.map { $0.id == set.id ? set : $0 }
    }
    
    func deleteSet(_ id: String) {
        let index = exercise.sets.firstIndex(where: { $0.id == id })
        guard let index = index else { return }
        
        print("Deleting set at index \(index)")
        
        exercise.sets.remove(at: index)
        for i in 0..<exercise.sets.count {
            exercise.sets[i].index = i + 1
        }
        
        // Remove the set from the backend
        Task { await requestDeleteSet(id) }
    }
    
    private func saveUpdatedSet(set: ExerciseSet) {
        guard let index = exercise.sets.firstIndex(where: { $0.id == set.id }) else { return }
        let updatedSet = exercise.sets[index]
        
        // Now call your async function to update the set on the server
        Task { await requestUpdateSet(at: index, with: updatedSet) }
    }
    
    private func saveSet(_ set: ExerciseSet) async {
        guard autoSave else { return }
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
        guard autoSave else { return }
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
    
    private func requestDeleteSet(_ id: String) async {
        guard autoSave else { return }
        let response: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "sets/\(id)", method: .DELETE)
        handleResponse(response)
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
