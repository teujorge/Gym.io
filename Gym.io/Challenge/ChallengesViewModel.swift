//
//  ChallengesViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/13/24.
//

import Foundation
import Combine

class ChallengesViewModel: ObservableObject {
    
    @Published var state: LoaderState = .idle {
        didSet {
            debounceStateChange()
        }
    }
    @Published var isPresentingChallengesForm = false
    
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
    
    func fetchChallenges(_ userId: String) async -> [Challenge]? {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let result: HTTPResponse<[Challenge]> = await sendRequest(
            endpoint: "challenges",
            queryItems: [
                URLQueryItem(name: "includeAll", value: "true"),
                URLQueryItem(name: "findMany", value: "true"),
                URLQueryItem(name: "ownerId", value: userId)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let challenges):
            DispatchQueue.main.async {
                self.state = .success
            }
            return challenges
        case .failure(let error):
            print("Failed to load challenges: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
        }
        
        return nil
    }
    
}
