//
//  ChallengeModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import Foundation
import Combine

class Challenge: Codable, Equatable, Identifiable, ObservableObject {
    static func == (lhs: Challenge, rhs: Challenge) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var id: String
    @Published var name: String
    @Published var notes: String
    @Published var pointsPerHour: Int
    @Published var pointsPerRep: Int
    @Published var pointsPerKg: Int
    @Published var ownerId: String
    
    @Published var participants: [User]
    
    @Published var startAt: Date
    @Published var endAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        notes: String = "",
        pointsPerHour: Int,
        pointsPerRep: Int,
        pointsPerKg: Int,
        ownerId: String = UUID().uuidString,
        participants: [User] = [],
        startAt: Date = Date(),
        endAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.pointsPerHour = pointsPerHour
        self.pointsPerRep = pointsPerRep
        self.pointsPerKg = pointsPerKg
        self.ownerId = ownerId
        self.participants = participants
        self.startAt = startAt
        self.endAt = endAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case notes
        case pointsPerHour
        case pointsPerRep
        case pointsPerKg
        case ownerId
        case participants
        case startAt
        case endAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        pointsPerHour = try container.decode(Int.self, forKey: .pointsPerHour)
        pointsPerRep = try container.decode(Int.self, forKey: .pointsPerRep)
        pointsPerKg = try container.decode(Int.self, forKey: .pointsPerKg)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        participants = (try? container.decodeIfPresent([User].self, forKey: .participants)) ?? []
        startAt = try decodeDate(from: container, forKey: .startAt)
        endAt = try decodeDate(from: container, forKey: .endAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(pointsPerHour, forKey: .pointsPerHour)
        try container.encode(pointsPerRep, forKey: .pointsPerRep)
        try container.encode(pointsPerKg, forKey: .pointsPerKg)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(participants, forKey: .participants)
        try container.encode(startAt, forKey: .startAt)
        try container.encode(endAt, forKey: .endAt)
    }
}

