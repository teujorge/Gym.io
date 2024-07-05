//
//  Models.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import Foundation


// Define the class for common workout properties
class Workout: Identifiable, ObservableObject {
    let id = UUID()
    @Published var title: String
    @Published var description: String?
    @Published var exercises: [Exercise]
    
    init(title: String, description: String? = nil, exercises: [Exercise]) {
        self.title = title
        self.description = description
        self.exercises = exercises
    }
}

// Define the abstract base class for common exercise properties
class Exercise: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String
    @Published var imageName: String?
    @Published var instructions: String?
    
    init(name: String, imageName: String? = nil, instructions: String? = nil) {
        self.name = name
        self.imageName = imageName
        self.instructions = instructions
    }
}

// Class for rep-based exercises
class ExerciseRepBased: Exercise {
    @Published var sets: Int
    @Published var reps: Int
    @Published var weight: Int
    @Published var caloriesPerRep: Int?
    
    init(name: String, imageName: String? = nil, instructions: String? = nil, sets: Int, reps: Int, weight: Int, caloriesPerRep: Int? = nil) {
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.caloriesPerRep = caloriesPerRep
        super.init(name: name, imageName: imageName, instructions: instructions)
    }
}

// Class for time-based exercises
class ExerciseTimeBased: Exercise {
    @Published var duration: Int // Duration in seconds
    @Published var caloriesPerMinute: Int?
    
    init(name: String, imageName: String? = nil, instructions: String? = nil, duration: Int, caloriesPerMinute: Int? = nil) {
        self.duration = duration
        self.caloriesPerMinute = caloriesPerMinute
        super.init(name: name, imageName: imageName, instructions: instructions)
    }
}
