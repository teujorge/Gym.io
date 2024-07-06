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
                    Text("Point System:")
                        .font(.headline)
                    Text("Points per 100 kg -> \(challenge.rules.pointsPerHundredKgs)")
                        .font(.subheadline)
                    Text("Points per 100 reps -> \(challenge.rules.pointsPerHundredReps)")
                        .font(.subheadline)
                    Text("Points per hour -> \(challenge.rules.pointsPerHour)")
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
    rules: Rules(pointsPerHundredKgs: 50, pointsPerHundredReps: 5, pointsPerHour: 120),
    startDate: Date().addingTimeInterval(-60 * 60 * 24 * 10),
    endDate: Date().addingTimeInterval(60 * 60 * 24 * 30),
    participants: [
        User(name: "Alice", completedWorkouts: _previewWorkoutsCompleted),
        User(name: "Bob"),
        User(name: "Charlie")
    ]
)

// map through _previewWorkouts and create a WorkoutCompleted with random date
let _previewWorkoutsCompleted = _previewWorkouts.map { workout in
    WorkoutCompleted(
        date: Date().addingTimeInterval(-Double.random(in: 0...(60 * 60 * 24 * 10))),
        workout: workout
    )
}
