//
//  ExerciseModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI
import Combine

class Exercise: Codable, Identifiable, ObservableObject {
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var id: String
    @Published var index: Int
    @Published var name: String
    @Published var imageName: String?
    @Published var notes: String?
    @Published var completedAt: Date?
    @Published var sets: [ExerciseSet]
    @Published var isRepBased: Bool
    @Published var restDuration: Int
    
    init(
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        id: String = UUID().uuidString,
        index: Int,
        name: String,
        imageName: String? = nil,
        notes: String? = nil,
        completedAt: Date? = nil,
        sets: [ExerciseSet] = [],
        isRepBased: Bool,
        restDuration: Int = 90
    ) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
        self.index = index
        self.name = name
        self.imageName = imageName
        self.notes = notes
        self.completedAt = completedAt
        self.sets = sets
        self.isRepBased = isRepBased
        self.restDuration = restDuration
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case updatedAt
        case id
        case index
        case name
        case imageName
        case notes
        case completedAt
        case sets
        case isRepBased
        case restDuration
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
        id = try container.decode(String.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        name = try container.decode(String.self, forKey: .name)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        sets = try container.decodeIfPresent([ExerciseSet].self, forKey: .sets) ?? []
        isRepBased = try container.decode(Bool.self, forKey: .isRepBased)
        restDuration = try container.decode(Int.self, forKey: .restDuration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(notes, forKey: .notes)
        try container.encode(completedAt, forKey: .completedAt)
        try container.encode(sets, forKey: .sets)
        try container.encode(isRepBased, forKey: .isRepBased)
        try container.encode(restDuration, forKey: .restDuration)
    }
}

class ExerciseSet: Codable, Identifiable, ObservableObject {
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var id: String
    @Published var exerciseId: String
    @Published var index: Int
    @Published var reps: Int
    @Published var weight: Int
    @Published var duration: Int
    @Published var intensity: Intensity
    @Published var completedAt: Date?
    
    init(
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        id: String = UUID().uuidString,
        exerciseId: String = UUID().uuidString,
        index: Int,
        reps: Int = 0,
        weight: Int = 0,
        duration: Int = 0,
        intensity: Intensity = .medium,
        completedAt: Date? = nil
    ) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
        self.exerciseId = exerciseId
        self.index = index
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.intensity = intensity
        self.completedAt = completedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case updatedAt
        case id
        case exerciseId
        case index
        case reps
        case weight
        case duration
        case intensity
        case completedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
        id = try container.decode(String.self, forKey: .id)
        exerciseId = try container.decode(String.self, forKey: .exerciseId)
        index = try container.decode(Int.self, forKey: .index)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Int.self, forKey: .weight)
        duration = try container.decode(Int.self, forKey: .duration)
        intensity = try container.decode(Intensity.self, forKey: .intensity)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(id, forKey: .id)
        try container.encode(exerciseId, forKey: .exerciseId)
        try container.encode(index, forKey: .index)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(duration, forKey: .duration)
        try container.encode(intensity, forKey: .intensity)
        try container.encode(completedAt, forKey: .completedAt)
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
