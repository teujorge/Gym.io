//
//  ExerciseModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation
import Combine

class Exercise: Decodable, Identifiable, ObservableObject {
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var id: String
    @Published var index: Int
    @Published var name: String
    @Published var imageName: String?
    @Published var notes: String?
    @Published var completedAt: Date?
    @Published var sets: [ExerciseSet]
    
    init(
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        id: String = UUID().uuidString,
        index: Int,
        name: String,
        imageName: String? = nil,
        notes: String? = nil,
        completedAt: Date? = nil,
        sets: [ExerciseSet] = []
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
    }
}

class ExerciseSet: Decodable, Identifiable, ObservableObject {
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var id: String
    @Published var index: Int
    @Published var reps: Int?
    @Published var weight: Int?
    @Published var duration: Int?
    @Published var intensity: Intensity?
    @Published var completedAt: Date?
    
    init(
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        id: String = UUID().uuidString,
        index: Int,
        reps: Int? = nil,
        weight: Int? = nil,
        duration: Int? = nil,
        intensity: Intensity? = nil,
        completedAt: Date? = nil
    ) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
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
        index = try container.decode(Int.self, forKey: .index)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        intensity = try container.decodeIfPresent(Intensity.self, forKey: .intensity)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }
}

enum Intensity: String, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
}
