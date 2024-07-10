//
//  ChallengeView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengeView: View {
    @State var challenge: Challenge
    @State var isPresentingWorkoutForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let notes = challenge.notes {
                    Text(notes)
                        .font(.body)
                }
                
                // Participants/Ranking
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants")
                        .font(.headline)
                    
                    ForEach($challenge.participants, id: \.id) { $user in
                        HStack {
                            Text(user.username)
                                .font(.body)
                            Spacer()
                            // Text("\(challenge.calculatePoints(for: user)) pts")
                            Text("calculatePoints")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
                
                // Dates
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date:")
                        .font(.headline)
                    Text(challenge.startAt, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("End Date:")
                        .font(.headline)
                    Text(challenge.endAt, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Point System
                VStack(alignment: .leading, spacing: 8) {
                    Text("Point System:")
                        .font(.headline)
                    Text("Points per kg -> \(challenge.pointsPerKg)")
                        .font(.subheadline)
                    Text("Points per rep -> \(challenge.pointsPerRep)")
                        .font(.subheadline)
                    Text("Points per hour -> \(challenge.pointsPerHour)")
                        .font(.subheadline)
                }
                
                
            }
            .padding()
            .sheet(isPresented: $isPresentingWorkoutForm) {
                ChallengeFormView(
                    challenge: challenge,
                    onSave: { newChallenge in
                        challenge = newChallenge
                        isPresentingWorkoutForm = false
                    },
                    onDelete: { challenge in
                        isPresentingWorkoutForm = false
                    }
                )
            }
        }
        .navigationTitle(challenge.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isPresentingWorkoutForm.toggle() }) {
                    Text("Edit")
                    Image(systemName: "pencil")
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(20)
            }
        }
    }
}


#Preview {
    NavigationView {
        ChallengeView(challenge: _previewChallenge)
    }
}

let _previewChallenge = Challenge(
    startAt: Date().addingTimeInterval(-60 * 60 * 24 * 10),
    endAt: Date().addingTimeInterval(60 * 60 * 24 * 30),
    pointsPerHour: 100,
    pointsPerRep: 5,
    pointsPerKg: 10,
    title: "30-Day Fitness",
    notes: "Join us in this 30-day fitness challenge!",
    owner: _previewParticipants[0]
//    participants: _previewParticipants
)

let _previewParticipants = [
    User(username: "teujorge", name:"Matheus Jorge"),
    User(username: "alice", name: "Alice"),
    User(username: "bobby", name: "Bob"),
    User(username: "ccc", name: "Charlie")
]
