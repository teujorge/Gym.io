//
//  ChallengeModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import Foundation
import Combine

class Challenge: Codable, Identifiable, ObservableObject {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startAt, forKey: .startAt)
        try container.encode(endAt, forKey: .endAt)
        try container.encode(pointsPerHour, forKey: .pointsPerHour)
        try container.encode(pointsPerRep, forKey: .pointsPerRep)
        try container.encode(pointsPerKg, forKey: .pointsPerKg)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(owner, forKey: .owner)
        try container.encode(participants, forKey: .participants)
    }
}

