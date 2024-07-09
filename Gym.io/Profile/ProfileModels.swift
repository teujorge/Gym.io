//
//  ProfileModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation

class User: Identifiable, Decodable, ObservableObject {
    let id: String
    @Published var name: String
    @Published var username: String
    @Published var workouts: [Workout]
    @Published var completedWorkouts: [WorkoutCompleted]
    @Published var challenges: [Challenge]

    init(id: String = UUID().uuidString, name: String, username: String, workouts: [Workout] = [], completedWorkouts: [WorkoutCompleted] = [], challenges: [Challenge] = []) {
        self.id = id
        self.name = name
        self.username = username
        self.workouts = workouts
        self.completedWorkouts = completedWorkouts
        self.challenges = challenges
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, username
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        workouts = []
        completedWorkouts = []
        challenges = []
    }
}
