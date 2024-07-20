//
//  WorkoutModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation
import Combine

class WorkoutPlan: Codable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var name: String
    @Published var notes: String?
    @Published var duration: Int?
    @Published var index: Int
    @Published var ownerId: String
    
    @Published var owner: User?
    @Published var exercisePlans: [ExercisePlan]
    @Published var history: [Workout]
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        notes: String? = nil,
        duration: Int? = nil,
        index: Int = 0,
        ownerId: String = UUID().uuidString,
        owner: User? = nil,
        exercisePlans: [ExercisePlan] = [],
        history: [Workout] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.duration = duration
        self.index = index
        self.ownerId = ownerId
        self.owner = owner
        self.exercisePlans = exercisePlans
        self.history = history
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case notes
        case duration
        case index
        case ownerId
        case owner
        case exercisePlans
        case history
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        index = try container.decode(Int.self, forKey: .index)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        owner = try container.decodeIfPresent(User.self, forKey: .owner)
        exercisePlans = try container.decodeIfPresent([ExercisePlan].self, forKey: .exercisePlans) ?? []
        history = try container.decodeIfPresent([Workout].self, forKey: .history) ?? []
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encode(index, forKey: .index)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(exercisePlans, forKey: .exercisePlans)
        try container.encode(history, forKey: .history)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

class Workout: Codable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var name: String
    @Published var notes: String?
    @Published var index: Int
    @Published var completedAt: Date?
    @Published var planId: String
    @Published var ownerId: String
    
    @Published var owner: User?
    @Published var plan: WorkoutPlan?
    @Published var exercises: [Exercise]
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(workoutPlan: WorkoutPlan) {
        self.id = UUID().uuidString
        self.name = workoutPlan.name
        self.notes = workoutPlan.notes
        self.index = workoutPlan.index
        self.planId = workoutPlan.id
        self.ownerId = workoutPlan.ownerId
        self.owner = workoutPlan.owner
        self.exercises = workoutPlan.exercisePlans.map { Exercise(exercisePlan: $0) }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        notes: String? = nil,
        index: Int = 0,
        completedAt: Date? = nil,
        planId: String = UUID().uuidString,
        ownerId: String = UUID().uuidString,
        owner: User? = nil,
        plan: WorkoutPlan? = nil,
        exercises: [Exercise] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.index = index
        self.completedAt = completedAt
        self.planId = planId
        self.ownerId = ownerId
        self.owner = owner
        self.plan = plan
        self.exercises = exercises
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case notes
        case index
        case completedAt
        case planId
        case ownerId
        case owner
        case plan
        case exercises
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        index = try container.decode(Int.self, forKey: .index)
        completedAt = try decodeNullableDate(from: container, forKey: .completedAt)
        planId = try container.decode(String.self, forKey: .planId)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        owner = try container.decodeIfPresent(User.self, forKey: .owner)
        exercises = try container.decodeIfPresent([Exercise].self, forKey: .exercises) ?? []
        plan = try container.decodeIfPresent(WorkoutPlan.self, forKey: .plan)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(index, forKey: .index)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encode(planId, forKey: .planId)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(owner, forKey: .owner)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
}
