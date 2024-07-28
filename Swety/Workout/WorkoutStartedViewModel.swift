//
//  WorkoutStartedViewModel.swift
//  Swety
//
//  Created by Davi Guimell on 15/07/24.
//

import SwiftUI
import Combine

class WorkoutStartedViewModel: ObservableObject{
    
    @Published var workout: Workout
    @Published var workoutCounter = 0
    @Published var restCounter = 0
    @Published var isResting = false
    @Published var state: LoaderState = .idle
    
    var workoutTimerCancellable: AnyCancellable? = nil
    var restTimerCancellable: AnyCancellable? = nil
    
    init(workout: Workout) {
        workout.exercises.sort { $0.index < $1.index }
        workout.exercises.forEach { $0.sets.sort { $0.index < $1.index } }
        
        self.workout = workout
        
        Task {
            await observeLiveActivityChanges()
        }
    }
    
    init(workoutPlan: WorkoutPlan) {
        workoutPlan.exercisePlans.sort { $0.index < $1.index }
        workoutPlan.exercisePlans.forEach { $0.setPlans.sort { $0.index < $1.index } }
        
        var startedWorkout = Workout(workoutPlan: workoutPlan)
        startedWorkout.completedAt = nil
        
        self.workout = startedWorkout
        
        Task {
            await createNewWorkout()
            await observeLiveActivityChanges()
        }
    }
    
    func observeLiveActivityChanges() async {
        guard let activity = currentLiveActivity else { return }
        
        Task {
            for await state in activity.activityStateUpdates {
                // Handle state updates
                print("Activity state updated: \(state)")
                if let workout = await self.updateWorkout() {
                    self.workout = workout
                }
            }
        }
        
        Task {
            for await content in activity.contentUpdates {
                // Handle content updates
                print("Activity content updated: \(content)")
                if let workout = await self.updateWorkout() {
                    self.workout = workout
                }
            }
        }
    }
    
    func startWorkoutTimer() {
        workoutTimerCancellable?.cancel()  // Cancel any existing timer
        workoutCounter = Int(workout.createdAt.timeIntervalSinceNow) // Reset the counter
        
        workoutTimerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.workoutCounter += 1
            }
    }
    
    func stopWorkoutTimer() {
        workoutTimerCancellable?.cancel()  // Cancel the timer
        workoutTimerCancellable = nil  // Set the cancellable to nil
    }
    
    func startRestTimer() {
        restTimerCancellable?.cancel()  // Cancel any existing rest timer
        // restCounter = currentExercise.restTime // TODO: Reset the rest counter
        
        restTimerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.restCounter -= 1
                if self.restCounter <= 0 {
                    self.stopRestTimer()
                    self.isResting = false
                    return
                }
            }
    }
    
    func stopRestTimer() {
        restTimerCancellable?.cancel()  // Cancel the rest timer
        restTimerCancellable = nil  // Set the cancellable to nil
    }
    
    func initiateWorkout() {
        startWorkoutTimer()
    }
    
    func isLastExercise(exercise: Exercise) -> Bool {
        return workout.exercises.last?.id == exercise.id
    }
    
    func completeWorkout(onSuccess: @escaping (Workout) -> Void) {
        Task {
            await stopWorkoutLiveActivity()
            if let newWorkout = await updateWorkout() {
                onSuccess(newWorkout)
            }
        }
    }
    
    func debouncedChanges() {
        Task {
            if let newWorkout = await updateWorkout() {
                print("Workout updated: \(newWorkout)")
                
                
                var currentExerciseIndex = 0
                var currentSetIndex = 0
                
                for exercise in newWorkout.exercises {
                    for exerciseSet in exercise.sets {
                        if exerciseSet.completedAt != nil {
                            currentExerciseIndex = exercise.index
                            currentSetIndex = exerciseSet.index
                        }
                    }
                }
                
                await startOrUpdateLiveActivity(with: WorkoutState(
                    workoutName: workout.name,
                    currentExercise: workout.exercises[currentExerciseIndex],
                    currentSetIndex: currentSetIndex,
                    totalExercisesCount: workout.exercises.count,
                    workoutCounter: workoutCounter,
                    restCounter: restCounter
                ))
            }
        }
    }
    
    private func createNewWorkout() async -> Workout? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "/workouts/history", body: workout, method: .POST)
        
        switch result {
        case .success(let newWorkout):
            print("Workout created: \(newWorkout)")
            DispatchQueue.main.async {
                self.workout = newWorkout
                self.state = .success
            }
            
            let exercises = newWorkout.exercises.sorted { $0.index < $1.index }
            if let exerciseId = exercises.first?.id {
                await startOrUpdateLiveActivity(with: WorkoutState(
                    workoutName: workout.name,
                    currentExercise: workout.exercises[0],
                    currentSetIndex: 0,
                    totalExercisesCount: workout.exercises.count,
                    workoutCounter: workoutCounter,
                    restCounter: restCounter
                ))
            }
            else {
                print("WILL NOT START LIVE ACTIVITY: Could not find exercise set id")
            }
            
            return newWorkout
        case .failure(let error):
            print("Failed to create workout: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
        }
        
        return nil
    }
    
    private func updateWorkout() async -> Workout? {
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
    
}


