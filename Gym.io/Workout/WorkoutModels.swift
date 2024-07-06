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
    @Published var completedDate: Date?

    init(id: UUID = UUID(), title: String, description: String? = nil, exercises: [Exercise], completedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.exercises = exercises
        self.completedDate = completedDate
    }
}
