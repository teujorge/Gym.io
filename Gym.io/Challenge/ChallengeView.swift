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
    
    // dictionary to store user points
    @State var userPoints: [String: Int] = [:]
    
    init(challenge: Challenge) {
        // sort all participants by points
        self.challenge = challenge
        self.challenge.participants.sort { user1, user2 in
            calculatePoints(for: user1) > calculatePoints(for: user2)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Progress Bar
                ProgressView(value:0.1).progressViewStyle(.linear)
                
                // Dates
                HStack {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                            .font(.headline)
                        Text(challenge.startAt, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("End Date")
                            .font(.headline)
                        Text(challenge.endAt, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let notes = challenge.notes {
                    Text(notes)
                        .font(.body)
                }
                
                ParticipantRankingsView(challenge: challenge, userPoints: userPoints)
                ChallengePointsView(challenge: challenge)
            }
            .padding()
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
    
        func calculatePoints(for user: User) -> Int {
            print()
            print("Calculating points for \(user.name)")
    
            let workoutsInRange = user.workouts.filter { workout in
                guard let completedAt = workout.completedAt else {
                    return false
                }
                return challenge.startAt...challenge.endAt ~= completedAt
            }
    
            let totalWeight = workoutsInRange.reduce(0) { total, completed in
                total + completed.exercises.compactMap { exercise in
                    exercise.sets.compactMap { set in
                        set.weight
                    }.reduce(0, +)
                }.reduce(0, +)
            }
            let weightPoints = totalWeight / challenge.pointsPerKg
            print("Weight points: \(weightPoints)")
    
            let totalReps = workoutsInRange.reduce(0) { total, completed in
                total + completed.exercises.compactMap { exercise in
                    exercise.sets.compactMap { set in
                        set.reps
                    }.reduce(0, +)
                }.reduce(0, +)
            }
            let repsPoints = totalReps / challenge.pointsPerRep
            print("Reps points: \(repsPoints)")
    
            let totalDuration = workoutsInRange.reduce(0) { total, completed in
                total + completed.exercises.compactMap { exercise in
                    exercise.sets.compactMap { set in
                        set.duration
                    }.reduce(0, +)
                }.reduce(0, +)
            }
            let durationPoints = (totalDuration / (60 * 60)) / challenge.pointsPerHour
            print("Duration points: \(durationPoints)")
    
            let totalPoints = Int(weightPoints + repsPoints + durationPoints)
            print("Total points: \(totalPoints)")
            print()
            
            userPoints[user.id] = totalPoints
            return totalPoints
        }
}

struct ParticipantRankingsView: View {
    var challenge: Challenge
    var userPoints: [String: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Participants")
                .font(.headline)
            
            ForEach(Array(challenge.participants.enumerated()), id: \.element.id) { index, user in
                HStack(spacing: 20) {
                    Text("\(index + 1)")
                        .font(.title)
                        .fontWeight(.bold)
                    ZStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)  // Set appropriate sizing
                        
                        if index == 0 {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Image(systemName: "medal.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.blue),
                                        alignment: .center
                                    )
                                    .overlay(
                                        Circle().stroke(.blue, lineWidth: 1)
                                    )
                            }
                            .offset(x: 15, y: 15)
                        }
                    }
                    .frame(width: 38, height: 38)
                    HStack {
                        Text(user.username)
                            .font(.body)
                        if user.id == challenge.owner.id {
                            Text("(Owner)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Text("\(userPoints[user.id] ?? 0)")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding()
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
    }
}

struct ChallengePointsView: View {
    var challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Point System:")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack(spacing: 20) {
                PointCard(icon: "scalemass", title: "Per kg", points: challenge.pointsPerKg)
                PointCard(icon: "arrow.up.and.down.circle", title: "Per rep", points: challenge.pointsPerRep)
                PointCard(icon: "clock", title: "Per hour", points: challenge.pointsPerHour)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PointCard: View {
    var icon: String
    var title: String
    var points: Int
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("\(points)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text("pts")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 100, height: 120)
        .cornerRadius(10)
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
    owner: _previewParticipants[0],
    participants: _previewParticipants
)

let _previewParticipants = [
    User(username: "teujorge", name:"Matheus Jorge"),
    User(username: "alice", name: "Alice"),
    User(username: "bobby", name: "Bob"),
    User(username: "ccc", name: "Charlie")
]
