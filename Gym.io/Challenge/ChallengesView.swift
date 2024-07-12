//
//  ChallengesView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengesView: View {
    
    @EnvironmentObject var currentUser: User
    @State private var selectedChallenge: Challenge?
    @State private var isPresentingChallengesForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(currentUser.challenges, id: \.id) { challenge in
                        ChallengeCardView(
                            challenge: challenge,
                            onEdit: {
                                selectedChallenge = challenge
                                isPresentingChallengesForm = true
                            },
                            onDelete: {
                                deleteChallenge(challenge)
                            }
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isPresentingChallengesForm = true }) {
                        HStack {
                            Text("New")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Image(systemName: "star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
            }
            .sheet(isPresented: $isPresentingChallengesForm) {
                ChallengeFormView(viewModel: ChallengeFormViewModel(
                    onSave: { challenge in
                        if let selectedChallenge = selectedChallenge {
                            // Update the existing challenge
                            updateChallenge(oldChallenge: selectedChallenge, newChallenge: challenge)
                        } else {
                            // Create a new challenge
                            createNewChallenge(newChallenge: challenge)
                        }
                        isPresentingChallengesForm = false
                    }
                ))
            }
            .onAppear {
                Task {
                    // Load challenges from API
                    let result: HTTPResponse<[Challenge]> = await sendRequest(
                        endpoint: "challenges",
                        queryItems: [
                            URLQueryItem(name: "includeAll", value: "true"),
                            URLQueryItem(name: "findMany", value: "true"),
                            URLQueryItem(name: "ownerId", value: currentUser.id)
                        ],
                        method: .GET
                    )
                    
                    // Set challenges to currentUser.challenges
                    switch result {
                    case .success(let challenges):
                        DispatchQueue.main.async {
                            self.currentUser.challenges = challenges
                        }
                    case .failure(let error):
                        print("Failed to load challenges: \(error)")
                    }
                }
            }
        }
    }
    
//    private func loadInitialChallenges() {
//        challenges = _previewChallenges
//    }
    
    private func createNewChallenge(newChallenge: Challenge) {
        currentUser.challenges.append(newChallenge)
    }
    
    private func updateChallenge(oldChallenge: Challenge, newChallenge: Challenge) {
        if let index = currentUser.challenges.firstIndex(where: { $0.id == oldChallenge.id }) {
            currentUser.challenges[index] = newChallenge
        }
    }
    
    private func deleteChallenge(_ challenge: Challenge) {
        currentUser.challenges.removeAll { $0.id == challenge.id }
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: ChallengeView(challenge: challenge)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(challenge.name)
                    .font(.headline)
                
                if !challenge.notes.isEmpty {
                    Text(challenge.notes)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                 
                    ForEach(Array(challenge.participants.enumerated()), id: \.element.id) { index, user in
                        if index < 4 {
                            Image(systemName: "person.circle.fill")
                        } else if index == 4 {
                            Text("+\(challenge.participants.count - 4)")
                                .foregroundColor(.gray)
                        }
                    }
                        Spacer()
                        
                    Text("End: \(challenge.endAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    _ChallengesPreview()
}

struct _ChallengesPreview: View {
    var body: some View {
        ChallengesView()
            .environmentObject(_previewParticipants[0])
    }
}

let _previewChallenges: [Challenge] = [
    _previewChallenge,
    Challenge(
        ownerId: _previewParticipants[1].id,
        startAt: Date(),
        endAt: Date().addingTimeInterval(60 * 60 * 24 * 7),
        pointsPerHour: 0,
        pointsPerRep: 0,
        pointsPerKg: 0,
        name: "Weekly Running",
        notes: "Run 5 miles every day for a week!"
        //        participants: _previewParticipants
    )
]
