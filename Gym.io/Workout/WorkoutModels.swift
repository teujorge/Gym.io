//
//  WorkoutModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation

class Workout: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var description: String?
    @Published var exercises: [Exercise]

    init(id: UUID = UUID(), title: String, description: String? = nil, exercises: [Exercise]) {
        self.id = id
        self.title = title
        self.description = description
        self.exercises = exercises
    }
}

class WorkoutCompleted: Identifiable, ObservableObject {
    let id: UUID
    let date: Date
    let workout: Workout
    
    init(id: UUID = UUID(), date: Date, workout: Workout) {
        self.id = id
        self.date = date
        self.workout = workout
    }
}
