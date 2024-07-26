//
//  ExerciseEnums.swift
//  Swety
//
//  Created by Matheus Jorge on 7/26/24.
//

import SwiftUI

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "CHEST"
    case back = "BACK"
    case legs = "LEGS"
    case shoulders = "SHOULDERS"
    case arms = "ARMS"
    case core = "CORE"
    
    var id: Self { self }
}

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case barbell = "BARBELL"
    case dumbbell = "DUMBBELL"
    case machine = "MACHINE"
    case flexible = "FLEXIBLE"
    case ball = "BALL"
    case other = "OTHER"
    case none = "NONE"
    
    var id: Self { self }
}

enum Intensity: String, Codable, CaseIterable, Identifiable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    
    var id: Self { self }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
}
