//
//  WorkoutModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation
import Combine

class Workout: Codable, Identifiable, ObservableObject {
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var id: String
    @Published var ownerId: String
    @Published var title: String
    @Published var notes: String?
    @Published var completedAt: Date?
    @Published var owner: User?
    @Published var exercises: [Exercise]
    
    init(
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        id: String = UUID().uuidString,
        ownerId: String,
        title: String,
        notes: String?,
        completedAt: Date? = nil,
        owner: User? = nil,
        exercises: [Exercise] = []
    ) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
        self.ownerId = ownerId
        self.title = title
        self.notes = notes
        self.completedAt = completedAt
        self.owner = owner
        self.exercises = exercises
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case updatedAt
        case id
        case ownerId
        case title
        case notes
        case completedAt
        case owner
        case exercises
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
        id = try container.decode(String.self, forKey: .id)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        owner = try container.decodeIfPresent(User.self, forKey: .owner)
        exercises = try container.decodeIfPresent([Exercise].self, forKey: .exercises) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encode(exercises, forKey: .exercises)
    }
    
}
