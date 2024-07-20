//
//  ProfileModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation
import Combine

enum Units: String, Codable, Identifiable, CaseIterable {
    case metric = "METRIC"
    case imperial = "IMPERTIAL"
    
    var id: Self { self }
}

class User: Codable, Equatable, Identifiable, ObservableObject {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var id: String
    @Published var username: String
    @Published var email: String?
    @Published var name: String
    @Published var birthday: Date
    @Published var units: Units
    
    @Published var auth:  Auth?
    @Published var workoutPlans: [WorkoutPlan]
    @Published var workouts: [Workout]
    @Published var challenges: [Challenge]

    
    @Published var createdAt: Date
    @Published var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        username: String,
        email: String? = nil,
        name: String,
        birthday: Date = Date(),
        units: Units = .metric,
        auth: Auth? = nil,
        workoutPlans: [WorkoutPlan] = [],
        workouts: [Workout] = [],
        challenges: [Challenge] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.name = name
        self.birthday = birthday
        self.units = units
        self.auth = auth
        self.workoutPlans = workoutPlans
        self.workouts = workouts
        self.challenges = challenges
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case name
        case birthday
        case units
        case auth
        case workoutPlans
        case workouts
        case challenges
        case createdAt
        case updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        birthday = try decodeDate(from: container, forKey: .birthday)
        units = try container.decode(Units.self, forKey: .units)
        auth = try container.decodeIfPresent(Auth.self, forKey: .auth)
        workoutPlans = try container.decodeIfPresent([WorkoutPlan].self, forKey: .workoutPlans) ?? []
        workouts = try container.decodeIfPresent([Workout].self, forKey: .workouts) ?? []
        challenges = try container.decodeIfPresent([Challenge].self, forKey: .challenges) ?? []
        createdAt = try decodeDate(from: container, forKey: .createdAt)
        updatedAt = try decodeDate(from: container, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(birthday, forKey: .birthday)
        try container.encode(units, forKey: .units)
        try container.encode(auth, forKey: .auth)
        try container.encode(workoutPlans, forKey: .workoutPlans)
        try container.encode(workouts, forKey: .workouts)
        try container.encode(challenges, forKey: .challenges)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
