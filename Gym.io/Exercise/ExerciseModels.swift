//
//  ExerciseModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import Foundation


enum ExerciseIntensity {
    case low
    case moderate
    case high
}

class Exercise: Identifiable, ObservableObject {
    let id: UUID
    
    // common exercise fields
    @Published var name: String
    @Published var imageName: String?
    @Published var instructions: String?
    @Published var sets: Int
    
    // rep based
    @Published var reps: Int?
    @Published var weight: Int?
    @Published var caloriesPerRep: Int?
    
    // time based
    @Published var duration: Int? // Duration in seconds
    @Published var intensity: ExerciseIntensity?
    @Published var caloriesPerMinute: Int?

    // rep based init
    init(id: UUID = UUID(), name: String, imageName: String? = nil, instructions: String? = nil, sets: Int, reps: Int, weight: Int) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.instructions = instructions
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.caloriesPerRep = Int(Double(weight) * 0.0005)
    }
    
    // time based init
    init(id: UUID = UUID(), name: String, imageName: String? = nil, instructions: String? = nil, sets: Int, duration: Int, intensity: ExerciseIntensity) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.instructions = instructions
        self.sets = sets
        self.duration = duration
        self.intensity = intensity
        self.caloriesPerMinute = Int(Double(duration) * 0.5 * (intensity == .low ? 0.75 : intensity == .moderate ? 1.00 : 1.25))
    }
}
