//
//  ChallengesView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengesView: View {
    
    @State private var challenges = [Challenge]()
    @State private var selectedChallenge: Challenge?
    @State private var isPresentingChallengesForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(challenges, id: \.id) { challenge in
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
                .onAppear(perform: loadInitialChallenges)
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
                ChallengeFormView { challenge in
                    if let selectedChallenge = selectedChallenge {
                        // Update the existing challenge
                        updateChallenge(oldChallenge: selectedChallenge, newChallenge: challenge)
                    } else {
                        // Create a new challenge
                        createNewChallenge(newChallenge: challenge)
                    }
                    isPresentingChallengesForm = false
                }
            }
        }
    }
    
    private func loadInitialChallenges() {
        challenges = _previewChallenges
    }
    
    private func createNewChallenge(newChallenge: Challenge) {
        challenges.append(newChallenge)
    }
    
    private func updateChallenge(oldChallenge: Challenge, newChallenge: Challenge) {
        if let index = challenges.firstIndex(where: { $0.id == oldChallenge.id }) {
            challenges[index] = newChallenge
        }
    }
    
    private func deleteChallenge(_ challenge: Challenge) {
        challenges.removeAll { $0.id == challenge.id }
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: ChallengeView(challenge: challenge)) {
            VStack(alignment: .leading) {
                Text(challenge.title)
                    .font(.headline)
                
                if let notes = challenge.notes {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Start: \(challenge.startAt.formatted(.dateTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("End: \(challenge.endAt.formatted(.dateTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    ChallengesView()
}

let _previewChallenges: [Challenge] = [
    _previewChallenge,
    Challenge(
        startAt: Date(),
        endAt: Date().addingTimeInterval(60 * 60 * 24 * 7),
        pointsPerHour: 0,
        pointsPerRep: 0,
        pointsPerKg: 0,
        title: "Weekly Running",
        notes: "Run 5 miles every day for a week!",
        owner: _previewParticipants[1]
//        participants: _previewParticipants
    )
]
