//
//  ChallengeModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import Foundation
import Combine

class Challenge: Decodable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var startAt: Date
    @Published var endAt: Date
    @Published var pointsPerHour: Int
    @Published var pointsPerRep: Int
    @Published var pointsPerKg: Int
    @Published var title: String
    @Published var notes: String?
    @Published var owner: User
    @Published var participants: [User]
    
    init(
        id: String = UUID().uuidString,
        startAt: Date = Date(),
        endAt: Date = Date(),
        pointsPerHour: Int,
        pointsPerRep: Int,
        pointsPerKg: Int,
        title: String,
        notes: String? = nil,
        owner: User,
        participants: [User] = []
    ) {
        self.id = id
        self.startAt = startAt
        self.endAt = endAt
        self.pointsPerHour = pointsPerHour
        self.pointsPerRep = pointsPerRep
        self.pointsPerKg = pointsPerKg
        self.title = title
        self.notes = notes
        self.owner = owner
        self.participants = participants
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case startAt
        case endAt
        case pointsPerHour
        case pointsPerRep
        case pointsPerKg
        case title
        case notes
        case owner
        case participants
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        startAt = try decodeDate(from: container, forKey: .startAt)
        endAt = try decodeDate(from: container, forKey: .endAt)
        pointsPerHour = try container.decode(Int.self, forKey: .pointsPerHour)
        pointsPerRep = try container.decode(Int.self, forKey: .pointsPerRep)
        pointsPerKg = try container.decode(Int.self, forKey: .pointsPerKg)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        owner = try container.decode(User.self, forKey: .owner)
        participants = try container.decodeIfPresent([User].self, forKey: .participants) ?? []
    }
}

//class Rules: Identifiable, ObservableObject {
//    let id: UUID
//    @Published var pointsPerHundredKgs: Int
//    @Published var pointsPerHundredReps: Int
//    @Published var pointsPerHour: Int
//
//    init(id: UUID = UUID(), pointsPerHundredKgs: Int, pointsPerHundredReps: Int, pointsPerHour: Int) {
//        self.id = id
//        self.pointsPerHundredKgs = pointsPerHundredKgs
//        self.pointsPerHundredReps = pointsPerHundredReps
//        self.pointsPerHour = pointsPerHour
//    }
//}
//
//class Challenge: Identifiable, ObservableObject {
//    let id: UUID
//    @Published var title: String
//    @Published var description: String
//    @Published var rules: Rules
//    @Published var participants: [User]
//    @Published var startDate: Date
//    @Published var endDate: Date
//
//    var ranking: [User] {
//        participants.sorted(by: { calculatePoints(for: $0) > calculatePoints(for: $1) })
//    }
//
//    init(id: UUID = UUID(), title: String, description: String, rules: Rules, startDate: Date, endDate: Date, participants: [User] = []) {
//        self.id = id
//        self.title = title
//        self.description = description
//        self.rules = rules
//        self.startDate = startDate
//        self.endDate = endDate
//        self.participants = participants
//    }
//
//    func calculatePoints(for user: User) -> Int {
//        print()
//        print("Calculating points for \(user.name)")
//        let workoutsInRange = user.completedWorkouts.filter { completed in
//            return completed.date >= startDate && completed.date <= endDate
//        }
//
//        let totalWeight = workoutsInRange.reduce(0) { total, completed in
//            total + completed.workout.exercises.compactMap { exercise in
//                exercise.weight
//            }.reduce(0, +)
//        }
//        let weightPoints = totalWeight / rules.pointsPerHundredKgs
//        print("Weight points: \(weightPoints)")
//
//        let totalReps = workoutsInRange.reduce(0) { total, completed in
//            total + completed.workout.exercises.compactMap { exercise in
//                exercise.reps
//            }.reduce(0, +)
//        }
//        let repsPoints = totalReps / rules.pointsPerHundredReps
//        print("Reps points: \(repsPoints)")
//
//        let totalDuration = workoutsInRange.reduce(0) { total, completed in
//            total + completed.workout.exercises.compactMap { exercise in
//                exercise.duration
//            }.reduce(0, +)
//        }
//        let durationPoints = (totalDuration / (60 * 60)) / rules.pointsPerHour
//        print("Duration points: \(durationPoints)")
//
//        let totalPoints = weightPoints + repsPoints + durationPoints
//        print("Total points: \(totalPoints)")
//        print()
//        return Int(totalPoints)
//    }
//}
