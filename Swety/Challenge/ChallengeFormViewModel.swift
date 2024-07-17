//
//  ChallengeFormViewModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/12/24.
//

import SwiftUI

class ChallengeFormViewModel: ObservableObject {
    
    let isEditing: Bool
    
    @Published var challenge: Challenge
    @Published var state: LoaderState = .idle
    @Published var isShowingActionSheet = false
    
    private var onSave: (Challenge) -> Void
    private var onDelete: ((Challenge) -> Void)?
    
    init(onSave: @escaping (Challenge) -> Void) {
        self.isEditing = false
        self.onSave = onSave
        self.onDelete = nil
        self.challenge = Challenge(
            ownerId: currentUserId,
            startAt: Date(),
            endAt: Date().addingTimeInterval(60 * 60 * 24 * 7),
            pointsPerHour: 10,
            pointsPerRep: 10,
            pointsPerKg: 10,
            name: "",
            notes: "",
            participants: []
        )
    }
    
    init(challenge: Challenge, onSave: @escaping (Challenge) -> Void, onDelete: @escaping (Challenge) -> Void) {
        self.isEditing = true
        self.onSave = onSave
        self.onDelete = onDelete
        self.challenge = challenge
    }
    
    func saveChallenge() {
        Task {
            let newChallenge = await saveRequest()
            
            if let challenge = newChallenge {
                onSave(challenge)
            } else {
                print("Failed to save challenge")
            }
        }
    }
    
    func deleteChallenge() {
        guard let onDelete = onDelete else { return }
        
        Task {
            let success = await deleteRequest()
            
            if success {
                onDelete(challenge)
            } else {
                print("Failed to delete challenge")
            }
        }
    }
    
    private func saveRequest() async -> Challenge? {
        state = .loading
        isShowingActionSheet = true
        
        var result: HTTPResponse<Challenge>
        if isEditing {
            result = await sendRequest(endpoint: "challenges/\(challenge.id)", body: challenge, method: .PUT)
        } else {
            result = await sendRequest(endpoint: "challenges", body: challenge, method: .POST)
        }
        
        isShowingActionSheet = false
        
        switch result {
        case .success(let challenge):
            print("User created: \(challenge)")
            DispatchQueue.main.async {
                if self.isEditing {
                    // self.currentUser.challenges = self.currentUser.challenges.map { $0.id == challenge.id ? challenge : $0 }
                } else {
                    // self.currentUser.challenges.append(challenge)
                }
                self.state = .success
            }
            return challenge
        case .failure(let error):
            print("Failed to create user: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            return nil
        }
    }
    
    private func deleteRequest() async -> Bool {
        state = .loading
        isShowingActionSheet = true
        let result: HTTPResponse<EmptyBody> = await sendRequest(endpoint: "challenges/\(challenge.id)", method: .DELETE)
        isShowingActionSheet = false
        
        switch result {
        case .success:
            print("Challenge deleted")
            DispatchQueue.main.async {
                self.state = .success
            }
            return true
        case .failure(let error):
            print("Failed to delete challenge: \(error)")
            DispatchQueue.main.async {
                self.state = .failure(error)
            }
            return false
        }
    }
}
