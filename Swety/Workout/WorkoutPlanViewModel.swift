//
//  WorkoutPlanViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/20/24.
//

import Foundation

class WorkoutPlanViewModel: ObservableObject {
    
    @Published var workoutPlan: WorkoutPlan
    @Published var isPresentingWorkoutForm = false
    
    init(workoutPlan: WorkoutPlan) {
        self.workoutPlan = workoutPlan
    }
    
}
