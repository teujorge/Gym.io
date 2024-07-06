//
//  ChallengeModels.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import Foundation

class Goal: Identifiable, ObservableObject {
    let id: UUID
    @Published var weightPerPoint: Double
    @Published var repsPerPoint: Int
    @Published var durationPerPoint: Int // Duration in seconds

    init(id: UUID = UUID(), weightPerPoint: Double, repsPerPoint: Int, durationPerPoint: Int) {
        self.id = id
        self.weightPerPoint = weightPerPoint
        self.repsPerPoint = repsPerPoint
        self.durationPerPoint = durationPerPoint
    }
}

class Challenge: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var description: String
    @Published var goal: Goal
    @Published var participants: [User]
    @Published var startDate: Date
    @Published var endDate: Date

    var ranking: [User] {
        participants.sorted(by: { calculatePoints(for: $0) > calculatePoints(for: $1) })
    }

    init(id: UUID = UUID(), title: String, description: String, goal: Goal, startDate: Date, endDate: Date, participants: [User] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.participants = participants
    }

    func calculatePoints(for user: User) -> Int {
        let workoutsInRange = user.workouts.filter { workout in
            if let completedDate = workout.completedDate {
                return completedDate >= startDate && completedDate <= endDate
            }
            return false
        }
        
        let totalWeight = workoutsInRange.reduce(0) { total, workout in
            total + workout.exercises.compactMap { exercise in
                (exercise as? ExerciseRepBased)?.weight
            }.reduce(0, +)
        }
        let weightPoints = Double(totalWeight) / goal.weightPerPoint
        
        let totalReps = workoutsInRange.reduce(0) { total, workout in
            total + workout.exercises.compactMap { exercise in
                (exercise as? ExerciseRepBased)?.reps
            }.reduce(0, +)
        }
        let repsPoints = Double(totalReps) / Double(goal.repsPerPoint)
        
        let totalDuration = workoutsInRange.reduce(0) { total, workout in
            total + workout.exercises.compactMap { exercise in
                (exercise as? ExerciseTimeBased)?.duration
            }.reduce(0, +)
        }
        let durationPoints = Double(totalDuration) / Double(goal.durationPerPoint)
        
        return Int(weightPoints + repsPoints + durationPoints)
    }
}
