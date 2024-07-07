//
//  ChallengeModels.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import Foundation

class Rules: Identifiable, ObservableObject {
    let id: UUID
    @Published var pointsPerHundredKgs: Int
    @Published var pointsPerHundredReps: Int
    @Published var pointsPerHour: Int

    init(id: UUID = UUID(), pointsPerHundredKgs: Int, pointsPerHundredReps: Int, pointsPerHour: Int) {
        self.id = id
        self.pointsPerHundredKgs = pointsPerHundredKgs
        self.pointsPerHundredReps = pointsPerHundredReps
        self.pointsPerHour = pointsPerHour
    }
}

class Challenge: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var description: String
    @Published var rules: Rules
    @Published var participants: [User]
    @Published var startDate: Date
    @Published var endDate: Date

    var ranking: [User] {
        participants.sorted(by: { calculatePoints(for: $0) > calculatePoints(for: $1) })
    }

    init(id: UUID = UUID(), title: String, description: String, rules: Rules, startDate: Date, endDate: Date, participants: [User] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.rules = rules
        self.startDate = startDate
        self.endDate = endDate
        self.participants = participants
    }

    func calculatePoints(for user: User) -> Int {
        print()
        print("Calculating points for \(user.name)")
        let workoutsInRange = user.completedWorkouts.filter { completed in
            return completed.date >= startDate && completed.date <= endDate
        }
        
        let totalWeight = workoutsInRange.reduce(0) { total, completed in
            total + completed.workout.exercises.compactMap { exercise in
                (exercise as? ExerciseRepBased)?.weight
            }.reduce(0, +)
        }
        let weightPoints = totalWeight / rules.pointsPerHundredKgs
        print("Weight points: \(weightPoints)")
        
        let totalReps = workoutsInRange.reduce(0) { total, completed in
            total + completed.workout.exercises.compactMap { exercise in
                (exercise as? ExerciseRepBased)?.reps
            }.reduce(0, +)
        }
        let repsPoints = totalReps / rules.pointsPerHundredReps
        print("Reps points: \(repsPoints)")
        
        let totalDuration = workoutsInRange.reduce(0) { total, completed in
            total + completed.workout.exercises.compactMap { exercise in
                (exercise as? ExerciseTimeBased)?.duration
            }.reduce(0, +)
        }
        let durationPoints = (totalDuration / (60 * 60)) / rules.pointsPerHour
        print("Duration points: \(durationPoints)")
        
        let totalPoints = weightPoints + repsPoints + durationPoints
        print("Total points: \(totalPoints)")
        print()
        return Int(totalPoints)
    }
}
