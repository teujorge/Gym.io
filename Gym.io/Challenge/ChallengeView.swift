//
//  ChallengeView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengeView: View {
    let challenge: Challenge
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Details
                Text(challenge.description)
                    .font(.body)
                
                // Participants/Ranking
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants")
                        .font(.headline)
                    
                    ForEach(challenge.ranking, id: \.id) { user in
                        HStack {
                            Text(user.name)
                                .font(.body)
                            Spacer()
                            Text("\(challenge.calculatePoints(for: user)) pts")
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
                    Text(challenge.startDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("End Date:")
                        .font(.headline)
                    Text(challenge.endDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Point System
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal:")
                        .font(.headline)
                    Text("Weight Per Point: \(challenge.goal.weightPerPoint)")
                        .font(.subheadline)
                    Text("Reps Per Point: \(challenge.goal.repsPerPoint)")
                        .font(.subheadline)
                    Text("Duration Per Point: \(challenge.goal.durationPerPoint) seconds")
                        .font(.subheadline)
                }
                
                
            }
            .padding()
        }
        .navigationTitle(challenge.title)
    }
}


#Preview {
    NavigationView {
        ChallengeView(challenge: _previewChallenge)
    }
}

let _previewChallenge = Challenge(
    title: "30-Day Fitness",
    description: "Join us in this 30-day fitness challenge!",
    goal: Goal(weightPerPoint: 50, repsPerPoint: 5, durationPerPoint: 120),
    startDate: Date(),
    endDate: Date().addingTimeInterval(60 * 60 * 24 * 30),
    participants: [
        User(name: "Alice", workouts: _previewWorkouts),
        User(name: "Bob"),
        User(name: "Charlie")
    ]
)
