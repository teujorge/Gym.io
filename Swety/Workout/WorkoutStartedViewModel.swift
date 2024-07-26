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
    @Published var currentExercise: Exercise
    @Published var state: LoaderState = .idle
    
    var workoutTimerCancellable: AnyCancellable? = nil
    var restTimerCancellable: AnyCancellable? = nil
    
    init(workoutPlan: WorkoutPlan) {
        let startedWorkout = Workout(workoutPlan: workoutPlan)
        self.workout = startedWorkout
        self.currentExercise = startedWorkout.exercises[0]
        
        Task { await createNewWorkout() }
    }
    
    func startWorkoutTimer() {
        workoutTimerCancellable?.cancel()  // Cancel any existing timer
        workoutCounter = 0  // Reset the counter
        
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
        restCounter = currentExercise.restTime // Reset the rest counter
        
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
    
    func completeSet(exerciseSet: ExerciseSet) {
        print("Completing set for exercise with id: \(exerciseSet.id)")
        
        if let _currentExercise = workout.exercises.first(where: { $0.id == exerciseSet.exerciseId }) {
            currentExercise = _currentExercise
            startRestTimer()
        } else {
            print("Could not find exercise with id: \(exerciseSet.exerciseId)")
        }
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
                
                // find the last exercise and last set where the completedAt is not null, we assume we are now there...
                // remember we have to sort exercises, and sets by index first...
                Task {
                    let exercises = newWorkout.exercises.sorted { $0.index < $1.index }
                    
                    var currentExerciseIndex = 0
                    var currentSetIndex = 0
                    var exerciseId = exercises.first?.id ?? ""

                    for exercise in exercises {
                        let sortedSets = exercise.sets.sorted { $0.index < $1.index }
                        
                        for exerciseSet in sortedSets {
                            if exerciseSet.completedAt != nil {
                                currentExerciseIndex = exercise.index
                                currentSetIndex = exerciseSet.index
                                exerciseId = exercise.id
                            }
                        }
                    }
                    
                    await refreshWorkoutLiveActivity(
                        exerciseId: exerciseId,
                        currentSetIndex: currentSetIndex,
                        totalExercisesCount: currentExerciseIndex
                    )
                }
            }
        }
    }
    
    private func createNewWorkout() async -> Workout? {
        
        DispatchQueue.main.async {
            self.state = .loading
            self.workout.completedAt = nil
        }
        
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "/workouts/history", body: workout, method: .POST)
        
        switch result {
        case .success(let newWorkout):
            print("Workout created: \(newWorkout)")
            DispatchQueue.main.async {
                self.workout = newWorkout
                self.state = .success
            }
            
            Task {
                let exercises = newWorkout.exercises.sorted { $0.index < $1.index }
                if let exerciseId = exercises.first?.id {
                    await startWorkoutLiveActivity(
                        exerciseId: exerciseId,
                        workoutName: newWorkout.name,
                        totalExercisesCount: exercises.count
                    )
                }
                else {
                    print("WILL NOT START LIVE ACTIVITY: Could not find exercise set id")
                }
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


