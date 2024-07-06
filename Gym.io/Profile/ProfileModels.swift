//
//  ProfileModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation

class User: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var workouts: [Workout]
    @Published var challenges: [Challenge]

    init(id: UUID = UUID(), name: String, workouts: [Workout] = [], challenges: [Challenge] = []) {
        self.id = id
        self.name = name
        self.workouts = workouts
        self.challenges = challenges
    }
}
