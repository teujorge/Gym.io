//
//  WorkoutStartedViewModel.swift
//  Gym.io
//
//  Created by Davi Guimell on 15/07/24.
//

import SwiftUI
import Combine

class WorkoutStartedViewModel:ObservableObject{
    
    @Published var workout: Workout
    @Published var workoutCounter = 0
    @Published var restCounter = 0
    var workoutTimerCancellable: AnyCancellable? = nil
    var restTimerCancellable: AnyCancellable? = nil
    @Published var isResting = false
    @Published var currentExercise: Exercise
    @Published var isPresentingSetCompletedAlert = false
    
    init(workout: Workout) {
        self.workout = workout
        self.currentExercise = workout.exercises[0]
    }
    
    func formattedTime(_ time:Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
        restCounter = currentExercise.restDuration // Reset the rest counter
        
        restTimerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.restCounter -= 1
                if self.restCounter <= 0 {
                    self.stopRestTimer()
                    self.isResting = false
                    self.isPresentingSetCompletedAlert = true
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
    
}


