//
//  ProfileModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation
import Combine

class User: Codable, Equatable, Identifiable, ObservableObject {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    @Published var id: String
    @Published var username: String
    @Published var email: String?
    @Published var name: String
    @Published var workouts: [Workout]
    @Published var challenges: [Challenge]
    
    init(
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        id: String = UUID().uuidString,
        username: String,
        email: String? = nil,
        name: String,
        workouts: [Workout] = [],
        challenges: [Challenge] = []
    ) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.workouts = workouts
        self.challenges = challenges
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case updatedAt
        case id
        case username
        case email
        case name
        case workouts
        case challenges
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        workouts = try container.decodeIfPresent([Workout].self, forKey: .workouts) ?? []
        challenges = try container.decodeIfPresent([Challenge].self, forKey: .challenges) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(workouts, forKey: .workouts)
        try container.encode(challenges, forKey: .challenges)
    }
}
