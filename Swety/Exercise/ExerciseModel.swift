//
//  ExerciseModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI
import Combine

struct DefaultExercisePlan: Codable {
    var name: String
    var notes: String?
    var isRepBased: Bool
    var equipment: Equipment
    var muscleGroups: [MuscleGroup]
    
    func toExercisePlan() -> ExercisePlan {
        return ExercisePlan(
            name: name,
            notes: notes,
            isRepBased: isRepBased,
            equipment: equipment,
            muscleGroups: muscleGroups
        )
    }
}

class ExercisePlan: Codable, Equatable, Identifiable, ObservableObject {
    static func == (lhs: ExercisePlan, rhs: ExercisePlan) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var id: String
    @Published var name: String
    @Published var image: String?
    @Published var notes: String?
    @Published var duration: Int?
    @Published var restTime: Int
    @Published var isRepBased: Bool
    @Published var index: Int
    @Published var equipment: Equipment
    @Published var muscleGroups: [MuscleGroup]
    @Published var workoutPlanId: String?
    @Published var setPlans: [ExerciseSetPlan]
    @Published var history: [Exercise]

    @Published var workoutPlan: WorkoutPlan?
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        image: String? = nil,
        notes: String? = nil,
        duration: Int? = nil,
        restTime: Int = 90,
        isRepBased: Bool,
        index: Int = 0,
        equipment: Equipment,
        muscleGroups: [MuscleGroup],
        workoutPlanId: String? = nil,
        setPlans: [ExerciseSetPlan] = [],
        history: [Exercise] = [],
        workoutPlan: WorkoutPlan? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.notes = notes
        self.duration = duration
        self.restTime = restTime
        self.isRepBased = isRepBased
        self.index = index
        self.equipment = equipment
        self.muscleGroups = muscleGroups
        self.workoutPlanId = workoutPlanId
        self.setPlans = setPlans
        self.history = history
        self.workoutPlan = workoutPlan
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case notes
        case duration
        case restTime
        case isRepBased
        case index
        case equipment
        case muscleGroups
        case workoutPlanId
        case setPlans
        case history
        case workoutPlan
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        restTime = try container.decode(Int.self, forKey: .restTime)
        isRepBased = try container.decode(Bool.self, forKey: .isRepBased)
        index = try container.decode(Int.self, forKey: .index)
        equipment = try container.decode(Equipment.self, forKey: .equipment)
        muscleGroups = try container.decode([MuscleGroup].self, forKey: .muscleGroups)
        workoutPlanId = try container.decodeIfPresent(String.self, forKey: .workoutPlanId)
        setPlans = try container.decodeIfPresent([ExerciseSetPlan].self, forKey: .setPlans) ?? []
        history = try container.decodeIfPresent([Exercise].self, forKey: .history) ?? []
        workoutPlan = try container.decodeIfPresent(WorkoutPlan.self, forKey: .workoutPlan)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(notes, forKey: .notes)
        try container.encode(duration, forKey: .duration)
        try container.encode(restTime, forKey: .restTime)
        try container.encode(isRepBased, forKey: .isRepBased)
        try container.encode(index, forKey: .index)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(muscleGroups, forKey: .muscleGroups)
        try container.encode(workoutPlanId, forKey: .workoutPlanId)
        try container.encode(setPlans, forKey: .setPlans)
        try container.encode(history, forKey: .history)
        try container.encode(workoutPlan, forKey: .workoutPlan)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "CHEST"
    case back = "BACK"
    case legs = "LEGS"
    case shoulders = "SHOULDERS"
    case arms = "ARMS"
    case core = "CORE"
    
    var id: Self { self }
}

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case barbell = "BARBELL"
    case dumbbell = "DUMBBELL"
    case machine = "MACHINE"
    case flexible = "FLEXIBLE"
    case ball = "BALL"
    case other = "OTHER"
    case none = "NONE"
    
    var id: Self { self }
}

class Exercise: Codable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var name: String
    @Published var image: String?
    @Published var notes: String?
    @Published var index: Int
    @Published var isRepBased: Bool
    @Published var restTime: Int
    @Published var equipment: Equipment
    @Published var muscleGroups: [MuscleGroup]
    @Published var completedAt: Date?
    @Published var workoutId: String
    @Published var planId: String
    
    @Published var sets: [ExerciseSet]
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(exercisePlan: ExercisePlan) {
        self.id = UUID().uuidString
        self.name = exercisePlan.name
        self.image = exercisePlan.image
        self.notes = exercisePlan.notes
        self.index = exercisePlan.index
        self.isRepBased = exercisePlan.isRepBased
        self.restTime = exercisePlan.restTime
        self.equipment = exercisePlan.equipment
        self.muscleGroups = exercisePlan.muscleGroups
        self.workoutId = exercisePlan.workoutPlanId ?? UUID().uuidString
        self.planId = exercisePlan.id
        self.sets = exercisePlan.setPlans.map { ExerciseSet(exerciseSetPlan: $0) }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        image: String? = nil,
        notes: String? = nil,
        index: Int = 0,
        isRepBased: Bool,
        restTime: Int = 90,
        equipment: Equipment = .none,
        muscleGroups: [MuscleGroup] = [],
        completedAt: Date? = nil,
        workoutId: String = UUID().uuidString,
        planId: String = UUID().uuidString,
        sets: [ExerciseSet] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.notes = notes
        self.index = index
        self.isRepBased = isRepBased
        self.restTime = restTime
        self.equipment = equipment
        self.muscleGroups = muscleGroups
        self.completedAt = completedAt
        self.workoutId = workoutId
        self.planId = planId
        self.sets = sets
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case notes
        case index
        case isRepBased
        case restTime
        case equipment
        case muscleGroups
        case completedAt
        case workoutId
        case planId
        case sets
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        index = try container.decode(Int.self, forKey: .index)
        isRepBased = try container.decode(Bool.self, forKey: .isRepBased)
        restTime = try container.decode(Int.self, forKey: .restTime)
        equipment = try container.decode(Equipment.self, forKey: .equipment)
        muscleGroups = try container.decode([MuscleGroup].self, forKey: .muscleGroups)
        completedAt = try decodeNullableDate(from: container, forKey: .completedAt)
        workoutId = try container.decode(String.self, forKey: .workoutId)
        planId = try container.decode(String.self, forKey: .planId)
        sets = try container.decodeIfPresent([ExerciseSet].self, forKey: .sets) ?? []
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(notes, forKey: .notes)
        try container.encode(index, forKey: .index)
        try container.encode(isRepBased, forKey: .isRepBased)
        try container.encode(restTime, forKey: .restTime)
        try container.encode(equipment, forKey: .equipment)
        try container.encode(muscleGroups, forKey: .muscleGroups)
        try container.encode(completedAt, forKey: .completedAt)
        try container.encode(workoutId, forKey: .workoutId)
        try container.encode(planId, forKey: .planId)
        try container.encode(sets, forKey: .sets)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

class ExerciseSetPlan: Codable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var reps: Int
    @Published var weight: Int
    @Published var duration: Int
    @Published var intensity: Intensity
    @Published var index: Int
    @Published var exercisePlanId: String
    
    @Published var exercisePlan: Exercise?
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        reps: Int = 0,
        weight: Int = 0,
        duration: Int = 0,
        intensity: Intensity = .medium,
        index: Int = 0,
        exercisePlanId: String = UUID().uuidString,
        exercisePlan: Exercise? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.intensity = intensity
        self.index = index
        self.exercisePlanId = exercisePlanId
        self.exercisePlan = exercisePlan
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case reps
        case weight
        case duration
        case intensity
        case index
        case exercisePlanId
        case exercisePlan
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Int.self, forKey: .weight)
        duration = try container.decode(Int.self, forKey: .duration)
        intensity = try container.decode(Intensity.self, forKey: .intensity)
        index = try container.decode(Int.self, forKey: .index)
        exercisePlanId = try container.decode(String.self, forKey: .exercisePlanId)
        exercisePlan = try container.decodeIfPresent(Exercise.self, forKey: .exercisePlan)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(duration, forKey: .duration)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(index, forKey: .index)
        try container.encode(exercisePlanId, forKey: .exercisePlanId)
        try container.encodeIfPresent(exercisePlan, forKey: .exercisePlan)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    func print() {
        Swift.print("ExerciseSetPlan: \(reps) - \(weight) - \(duration) - \(intensity) - \(index)")
    }
}

class ExerciseSet: Codable, Identifiable, ObservableObject {
    @Published var id: String
    @Published var reps: Int
    @Published var weight: Int
    @Published var duration: Int
    @Published var intensity: Intensity
    @Published var index: Int
    @Published var completedAt: Date?
    @Published var exerciseId: String
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(exerciseSetPlan: ExerciseSetPlan) {
        self.id = UUID().uuidString
        self.reps = exerciseSetPlan.reps
        self.weight = exerciseSetPlan.weight
        self.duration = exerciseSetPlan.duration
        self.intensity = exerciseSetPlan.intensity
        self.index = exerciseSetPlan.index
        self.exerciseId = UUID().uuidString
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(
        id: String = UUID().uuidString,
        reps: Int = 0,
        weight: Int = 0,
        duration: Int = 0,
        intensity: Intensity = .medium,
        index: Int,
        completedAt: Date? = nil,
        exerciseId: String = UUID().uuidString,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.index = index
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.intensity = intensity
        self.completedAt = completedAt
        self.exerciseId = exerciseId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case index
        case reps
        case weight
        case duration
        case intensity
        case completedAt
        case exerciseId
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Int.self, forKey: .weight)
        duration = try container.decode(Int.self, forKey: .duration)
        intensity = try container.decode(Intensity.self, forKey: .intensity)
        index = try container.decode(Int.self, forKey: .index)
        completedAt = try decodeNullableDate(from: container, forKey: .completedAt)
        exerciseId = try container.decode(String.self, forKey: .exerciseId)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(duration, forKey: .duration)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(index, forKey: .index)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encode(exerciseId, forKey: .exerciseId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    func print() {
        Swift.print("ExerciseSet: \(reps) - \(weight) - \(duration) - \(intensity) - \(index)")
    }
    
}

enum Intensity: String, Codable, CaseIterable, Identifiable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    
    var id: Self { self }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}
