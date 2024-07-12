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
    @Published var ownerId: String
    @Published var startAt: Date
    @Published var endAt: Date
    @Published var pointsPerHour: Int
    @Published var pointsPerRep: Int
    @Published var pointsPerKg: Int
    @Published var name: String
    @Published var notes: String
    @Published var participants: [User]
    
    init(
        id: String = UUID().uuidString,
        ownerId: String,
        startAt: Date = Date(),
        endAt: Date = Date(),
        pointsPerHour: Int,
        pointsPerRep: Int,
        pointsPerKg: Int,
        name: String,
        notes: String = "",
        participants: [User] = []
    ) {
        self.id = id
        self.ownerId = ownerId
        self.startAt = startAt
        self.endAt = endAt
        self.pointsPerHour = pointsPerHour
        self.pointsPerRep = pointsPerRep
        self.pointsPerKg = pointsPerKg
        self.name = name
        self.notes = notes
        self.participants = participants
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case startAt
        case endAt
        case pointsPerHour
        case pointsPerRep
        case pointsPerKg
        case name
        case notes
        case participants
        case participantIds
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        startAt = try decodeDate(from: container, forKey: .startAt)
        endAt = try decodeDate(from: container, forKey: .endAt)
        pointsPerHour = try container.decode(Int.self, forKey: .pointsPerHour)
        pointsPerRep = try container.decode(Int.self, forKey: .pointsPerRep)
        pointsPerKg = try container.decode(Int.self, forKey: .pointsPerKg)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        participants = try container.decodeIfPresent([User].self, forKey: .participants) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(startAt, forKey: .startAt)
        try container.encode(endAt, forKey: .endAt)
        try container.encode(pointsPerHour, forKey: .pointsPerHour)
        try container.encode(pointsPerRep, forKey: .pointsPerRep)
        try container.encode(pointsPerKg, forKey: .pointsPerKg)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(participants, forKey: .participants)
        try container.encode(participants.map(\.id), forKey: .participantIds)
    }
}

