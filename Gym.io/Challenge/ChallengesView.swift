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
            .navigationBarItems(
                trailing: Button(action: { isPresentingChallengesForm = true }) {
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
            )
            .sheet(isPresented: $isPresentingChallengesForm) {
                ChallengesFormView { title, description in
                    if let selectedChallenge = selectedChallenge {
                        // Update the existing challenge
                        updateChallenge(selectedChallenge, title: title, description: description)
                    } else {
                        // Create a new challenge
                        createNewChallenge(title: title, description: description)
                    }
                    isPresentingChallengesForm = false
                }
            }
        }
    }
    
    private func loadInitialChallenges() {
        challenges = _previewChallenges
    }
    
    private func createNewChallenge(title: String, description: String) {
        let newChallenge = Challenge(title: title, description: description, rules: Rules(pointsPerHundredKgs: 50, pointsPerHundredReps: 5, pointsPerHour: 120), startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7))
        challenges.append(newChallenge)
    }
    
    private func updateChallenge(_ challenge: Challenge, title: String, description: String) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].title = title
            challenges[index].description = description
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
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Start: \(challenge.startDate.formatted(.dateTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("End: \(challenge.endDate.formatted(.dateTime))")
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
    Challenge(title: "Weekly Running", description: "Run 5 miles every day for a week!", rules: Rules(pointsPerHundredKgs: 0, pointsPerHundredReps: 0, pointsPerHour: 0), startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7)),
    Challenge(title: "100 Pushups Everyday", description: "Can you do 100 pushups for a week", rules: Rules(pointsPerHundredKgs: 0, pointsPerHundredReps: 100, pointsPerHour: 0), startDate: Date(), endDate: Date().addingTimeInterval(60 * 60 * 24 * 7))
]
