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

    @Published var isRepBased: Bool {
        didSet {
            debouncedExerciseEdited()
            onToggleIsRepBased?(isRepBased)
        }
    }
    @Published var sets: [SetDetails] {
        didSet {
            debouncedExerciseEdited()
            onSetsChanged?(sets)
        }
    }
    
    let isPlan: Bool
    
    @Published var listHeight = 0.0
    let rowHeight = 40.0
    let rowInsets = 20.0
    
    private var autoSave: Bool
    private var updateTimer: Timer?
    
    var onToggleIsRepBased: ((Bool) -> Void)?
    var onSetsChanged: (([SetDetails]) -> Void)?
    var onDebounceTriggered: (() -> Void)?
    
    init(
        sets: [SetDetails],
        isPlan: Bool,
        isRepBased: Bool,
        autoSave: Bool,
        onToggleIsRepBased: ((Bool) -> Void)? = nil,
        onSetsChanged: (([SetDetails]) -> Void)? = nil,
        onDebounceTriggered: (() -> Void)? = nil
    ) {
        self.sets = sets
        self.isPlan = isPlan
        self.isRepBased = isRepBased
        self.autoSave = autoSave
        
        self.onToggleIsRepBased = onToggleIsRepBased
        self.onSetsChanged = onSetsChanged
        self.onDebounceTriggered = onDebounceTriggered
        
        self.listHeight = Double(sets.count) * (rowHeight + rowInsets)
    }
    
    private func debouncedExerciseEdited() {
        print("Exercise edited")
        print("-> all sets: \(sets.map { $0.reps })")
        
        updateTimer?.invalidate() // Invalidate any existing timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.saveUpdatedExercise()
        }
    }
    
    private func saveUpdatedExercise() {
        print("saveUpdatedExercise")
        guard autoSave else { return }

        // TODO: update the exercise on the server
        print("TODO: save -> all sets: \(sets)")
    }
    
    func toggleSetCompletion(index: Int) {
        if sets[index].completedAt == nil {
            sets[index].completedAt = Date()
        } else {
            sets[index].completedAt = nil
        }
        debouncedExerciseEdited()
        onSetsChanged?(sets)
    }
    
    
    func addSet() {
        sets.append(SetDetails(
            reps: 0,
            weight: 0,
            duration: 0,
            intensity: .medium,
            completedAt: nil
        ))
        debouncedExerciseEdited()
    }
    
    func updateSet(index: Int, set: SetDetails) {
        sets[index] = set
        debouncedExerciseEdited()
    }
    
    func deleteSet(index: Int) {
        sets.remove(at: index)
        debouncedExerciseEdited()
    }
    
//    private func saveUpdatedSet(set: ExerciseSet) {
//        guard let index = exercise.sets.firstIndex(where: { $0.id == set.id }) else { return }
//        let updatedSet = exercise.sets[index]
//
//        // Now call your async function to update the set on the server
//        Task { await requestUpdateSet(at: index, with: updatedSet) }
//    }
    
//    private func saveSet(_ set: ExerciseSet) async {
//        guard autoSave else { return }
//        var newSet = set
//        newSet.exerciseId = exercise.id
//
//        let response: HTTPResponse<ExerciseSet> = await sendRequest(endpoint: "/sets", body: newSet, method: .POST)
//        handleResponse(response)
//
//        // Update the model with the backend response
//        switch response {
//        case .success(let backendSet):
//            if let index = exercise.sets.firstIndex(where: { $0.id == set.id }) {
//                exercise.sets[index] = backendSet
//            }
//        case .failure(let error):
//            print("Failed to decode set: \(error)")
//        }
//    }
    
//    private func requestUpdateSet(at index: Int, with set: ExerciseSet) async {
//        guard autoSave else { return }
//        let response: HTTPResponse<ExerciseSet> = await sendRequest(endpoint: "/sets/\(set.id)", body: set, method: .PUT)
//        handleResponse(response)
//
//        // Update the model with the backend response
//        switch response {
//        case .success(let backendSet):
//            exercise.sets[index] = backendSet
//        case .failure(let error):
//            print("Failed to decode set: \(error)")
//        }
//    }
    
//    private func requestDeleteSet(_ id: String) async {
//        guard autoSave else { return }
//        let response: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "/sets/\(id)", method: .DELETE)
//        handleResponse(response)
//    }
    
//    private func handleResponse<T>(_ response: HTTPResponse<T>) {
//        DispatchQueue.main.async {
//            switch response {
//            case .success:
//                self.state = .success
//            case .failure(let error):
//                self.state = .failure(error)
//            }
//        }
//    }
    
}


struct SetDetails {
    var reps: Int
    var weight: Int
    var duration: Int
    var intensity: Intensity
    var completedAt: Date?
    
    init(reps: Int, weight: Int, duration: Int, intensity: Intensity, completedAt: Date?) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.intensity = intensity
        self.completedAt = completedAt
    }
    
    init(exerciseSet: ExerciseSet) {
        reps = exerciseSet.reps
        weight = exerciseSet.weight
        duration = exerciseSet.duration
        intensity = exerciseSet.intensity
        completedAt = exerciseSet.completedAt
    }
    
    init(exerciseSetPlan: ExerciseSetPlan) {
        reps = exerciseSetPlan.reps
        weight = exerciseSetPlan.weight
        duration = exerciseSetPlan.duration
        intensity = exerciseSetPlan.intensity
        completedAt = nil
    }
    
    func toSet(index: Int) -> ExerciseSet {
        ExerciseSet(
            reps: reps,
            weight: weight,
            duration: duration,
            intensity: intensity,
            index: index,
            completedAt: completedAt
        )
    }
    
    func toSetPlan(index: Int) -> ExerciseSetPlan {
        ExerciseSetPlan(
            reps: reps,
            weight: weight,
            duration: duration,
            intensity: intensity,
            index: index
        )
    }
}
