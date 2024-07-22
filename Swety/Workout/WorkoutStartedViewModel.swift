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
            if let newWorkout = await createNewWorkout() {
                onSuccess(newWorkout)
            }
        }
    }
    
    private func createNewWorkout() async -> Workout? {
        state = .loading
        workout.name = "\(workout.name)"
        workout.completedAt = Date()
        let result: HTTPResponse<Workout> = await sendRequest(endpoint: "/workouts/history", body: workout, method: .POST)
        
        switch result {
        case .success(let newWorkout):
            print("Workout created: \(newWorkout)")
            DispatchQueue.main.async {
                self.workout = newWorkout
                self.state = .success
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
    
}


