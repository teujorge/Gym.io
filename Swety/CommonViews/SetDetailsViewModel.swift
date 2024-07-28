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
    
    @Published var details: SetDetails {
        didSet {
            print("details didSet")
            setupObservers()
            debouncedExerciseEdited()
            onDetailsChanged?(details)
        }
    }
    
    var restTime: Int {
        restTimeMinutes * 60 + restTimeSeconds
    }
    @Published var restTimeMinutes: Int {
        didSet {
            print("restTimeMinutes didSet")
            details.restTime = restTime
            callUpdateFunctions()
        }
    }
    @Published var restTimeSeconds: Int {
        didSet {
            print("restTimeSeconds didSet")
            details.restTime = restTime
            callUpdateFunctions()
        }
    }
    
    let isEditable: Bool
    let isPlan: Bool
    
    @Published var listHeight = 0.0
    let rowHeight = 40.0
    let rowInsets = 4.0
    
    private var autoSave: Bool
    private var updateTimer: Timer?
    
    var onDetailsChanged: ((SetDetails) -> Void)?
    var onDebounceTriggered: (() -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        details: SetDetails,
        isEditable: Bool,
        isPlan: Bool,
        autoSave: Bool,
        onDetailsChanged: ((SetDetails) -> Void)? = nil,
        onDebounceTriggered: (() -> Void)? = nil
    ) {
        self.details = details
        self.isEditable = isEditable
        self.isPlan = isPlan
        self.autoSave = autoSave
        
        self.restTimeMinutes = details.restTime / 60
        self.restTimeSeconds = details.restTime % 60
        
        self.onDetailsChanged = onDetailsChanged
        self.onDebounceTriggered = onDebounceTriggered
        
        self.listHeight = Double(details.sets.count) * (rowHeight + rowInsets)
        setupObservers()
    }
    
    private func setupObservers() {
        cancellables.removeAll()
        details.sets.forEach { set in
            set.objectWillChange.sink { [weak self] _ in
                self?.callUpdateFunctions()
            }.store(in: &cancellables)
        }
    }
    
    private func callUpdateFunctions() {
        print("callUpdateFunctions")
        details = SetDetails(
            exerciseId: details.exerciseId,
            isRepBased: details.isRepBased,
            restTime: details.restTime,
            sets: details.sets
        )
        debouncedExerciseEdited()
        onDetailsChanged?(details)
    }
    
    func formatSeconds(_ seconds: Int) -> String {
        switch seconds {
        case 0:
            return "None"
        default:
            return String(format: "%d:%02d", seconds / 60, seconds % 60)
        }
    }
    
    func debouncedExerciseEdited() {
        print("Exercise edited")
        print("-> all sets: \(details.sets.map { $0.reps })")
        
        updateTimer?.invalidate() // Invalidate any existing timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.saveUpdatedExercise()
        }
    }
    
    private func saveUpdatedExercise() {
        print("saveUpdatedExercise")
        guard autoSave else { return }
        onDebounceTriggered?()
    }
    
    func toggleSetCompletion(index: Int) {
        if details.sets[index].completedAt == nil {
            details.sets[index].completedAt = Date()
        } else {
            details.sets[index].completedAt = nil
        }
        callUpdateFunctions()
    }
    
    func addSet() {
        details.sets.append(SetDetail(
            id: UUID().uuidString,
            reps: 0,
            weight: 0,
            duration: 0,
            intensity: .medium,
            completedAt: nil
        ))
        callUpdateFunctions()
    }
    
    func updateSet(index: Int, set: SetDetail) {
        details.sets[index] = set
        callUpdateFunctions()
    }
    
    func deleteSet(index: Int) {
        details.sets.remove(at: index)
        callUpdateFunctions()
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

class SetDetails: ObservableObject, Equatable {
    static func == (lhs: SetDetails, rhs: SetDetails) -> Bool {
        lhs.exerciseId == rhs.exerciseId &&
        lhs.isRepBased == rhs.isRepBased &&
        lhs.restTime == rhs.restTime &&
        lhs.sets == rhs.sets
    }
    
    @Published var exerciseId: String
    @Published var isRepBased: Bool
    @Published var restTime: Int
    @Published var sets: [SetDetail] {
        didSet {
            objectWillChange.send() // Explicitly notify about the change
            setupObservers()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(exerciseId: String, isRepBased: Bool, restTime: Int, sets: [SetDetail]) {
        self.exerciseId = exerciseId
        self.isRepBased = isRepBased
        self.restTime = restTime
        self.sets = sets
        setupObservers()
    }
    
    init(exercise: Exercise) {
        self.exerciseId = exercise.id
        self.isRepBased = exercise.isRepBased
        self.restTime = exercise.restTime
        self.sets = exercise.sets.map { SetDetail(exerciseSet: $0) }
        setupObservers()
    }
    
    init(exercisePlan: ExercisePlan) {
        self.exerciseId = exercisePlan.id
        self.isRepBased = exercisePlan.isRepBased
        self.restTime = exercisePlan.restTime
        self.sets = exercisePlan.setPlans.map { SetDetail(exerciseSetPlan: $0) }
        setupObservers()
    }
    
    private func setupObservers() {
        cancellables.removeAll()
        sets.forEach { set in
            set.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }
    
    func createExercise(from exercise: Exercise) -> Exercise {
        exercise.isRepBased = isRepBased
        exercise.restTime = restTime
        exercise.sets = sets.enumerated().map { (index, setDetail) in
            setDetail.toSet(index: index)
        }
        return exercise
    }
    
    func createExercisePlan(from exercisePlan: ExercisePlan) -> ExercisePlan {
        exercisePlan.isRepBased = isRepBased
        exercisePlan.restTime = restTime
        exercisePlan.setPlans = sets.enumerated().map { (index, setDetail) in
            setDetail.toSetPlan(index: index)
        }
        return exercisePlan
    }
    
}

class SetDetail: ObservableObject, Equatable, Identifiable {
    static func == (lhs: SetDetail, rhs: SetDetail) -> Bool {
        lhs.id == rhs.id &&
        lhs.reps == rhs.reps &&
        lhs.weight == rhs.weight &&
        lhs.duration == rhs.duration &&
        lhs.intensity == rhs.intensity &&
        lhs.completedAt == rhs.completedAt
    }
    
    @Published var id: String {
        didSet { objectWillChange.send() }
    }
    @Published var reps: Int {
        didSet { objectWillChange.send() }
    }
    @Published var weight: Int {
        didSet { objectWillChange.send() }
    }
    @Published var duration: Int {
        didSet { objectWillChange.send() }
    }
    @Published var intensity: Intensity {
        didSet { objectWillChange.send() }
    }
    @Published var completedAt: Date? {
        didSet { objectWillChange.send() }
    }
    
    init(id: String, reps: Int, weight: Int, duration: Int, intensity: Intensity, completedAt: Date?) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.intensity = intensity
        self.completedAt = completedAt
    }
    
    init(exerciseSet: ExerciseSet) {
        id = exerciseSet.id
        reps = exerciseSet.reps
        weight = exerciseSet.weight
        duration = exerciseSet.duration
        intensity = exerciseSet.intensity
        completedAt = exerciseSet.completedAt
    }
    
    init(exerciseSetPlan: ExerciseSetPlan) {
        id = exerciseSetPlan.id
        reps = exerciseSetPlan.reps
        weight = exerciseSetPlan.weight
        duration = exerciseSetPlan.duration
        intensity = exerciseSetPlan.intensity
        completedAt = nil
    }
    
    func toSet(index: Int) -> ExerciseSet {
        ExerciseSet(
            id: id,
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
            id: id,
            reps: reps,
            weight: weight,
            duration: duration,
            intensity: intensity,
            index: index
        )
    }
}
