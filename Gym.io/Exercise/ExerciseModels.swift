//
//  ExerciseModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation

class Exercise: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var imageName: String?
    @Published var instructions: String?

    init(id: UUID = UUID(), name: String, imageName: String? = nil, instructions: String? = nil) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.instructions = instructions
    }
}

class ExerciseRepBased: Exercise {
    @Published var sets: Int
    @Published var reps: Int
    @Published var weight: Int
    @Published var caloriesPerRep: Int?

    init(id: UUID = UUID(), name: String, imageName: String? = nil, instructions: String? = nil, sets: Int, reps: Int, weight: Int, caloriesPerRep: Int? = nil) {
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.caloriesPerRep = caloriesPerRep
        super.init(id: id, name: name, imageName: imageName, instructions: instructions)
    }
}

class ExerciseTimeBased: Exercise {
    @Published var duration: Int // Duration in seconds
    @Published var caloriesPerMinute: Int?

    init(id: UUID = UUID(), name: String, imageName: String? = nil, instructions: String? = nil, duration: Int, caloriesPerMinute: Int? = nil) {
        self.duration = duration
        self.caloriesPerMinute = caloriesPerMinute
        super.init(id: id, name: name, imageName: imageName, instructions: instructions)
    }
}
