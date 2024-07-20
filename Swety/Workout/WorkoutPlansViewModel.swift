//
//  WorkoutsViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import Foundation
import Combine

class WorkoutPlansViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var state: LoaderState = .idle {
        didSet {
            debounceStateChange()
        }
    }
    @Published var isPresentingWorkoutForm = false
    
    private var debounceTimer: AnyCancellable?
    
    private func debounceStateChange() {
        debounceTimer?.cancel()
        
        debounceTimer = Just(state)
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] newState in
                if newState == .success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.state = .idle
                    }
                }
            }
    }
    
    func fetchWorkouts(for userId: String) async -> [WorkoutPlan]? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<[WorkoutPlan]> = await sendRequest(
            endpoint: "/workouts/templates",
            queryItems: [
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "ownerId", value: userId)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let workouts):
            print("Workout plans fetched: \(workouts)")
            DispatchQueue.main.async {
                self.state = .success
            }
            return workouts
        case .failure(let error):
            print("Failed to fetch workout plans: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            return nil
        }
    }
    
}
