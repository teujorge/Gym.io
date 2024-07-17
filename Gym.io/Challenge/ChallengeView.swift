//
//  ChallengeView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengeView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser: User
    
    @State var challenge: Challenge
    @State var isPresentingWorkoutForm = false
    @State var userPoints: [String: Int] = [:]
    
    var challengeProgress: Double {
        // calculate progress based on start date current date and end date
        // return a value between 0 and 1
        // 0 = not started
        // 1 = completed
        let currentDate = Date()
        if currentDate < challenge.startAt {
            return 0
        } else if currentDate > challenge.endAt {
            return 1
        }
        let totalDuration = challenge.endAt.timeIntervalSince(challenge.startAt)
        let currentDuration = currentDate.timeIntervalSince(challenge.startAt)
        return currentDuration / totalDuration
    }
    
//    init(challenge: Challenge) {
//         sort all participants by points
//        self.challenge = challenge
//        self.challenge.participants.sort { user1, user2 in
//            calculatePoints(for: user1) > calculatePoints(for: user2)
//        }
//    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Progress Bar
                ProgressView(value: challengeProgress)
                    .progressViewStyle(.linear)
                
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
                
                if !challenge.notes.isEmpty {
                    Text(challenge.notes)
                        .font(.body)
                }
                
                ParticipantRankingsView(challenge: challenge, userPoints: userPoints)
                ChallengePointsView(challenge: challenge)
            }
            .padding()
        }
        .navigationTitle(challenge.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isPresentingWorkoutForm.toggle() }) {
                    Text("Edit")
                    Image(systemName: "pencil")
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.accent.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .sheet(isPresented: $isPresentingWorkoutForm) {
            ChallengeFormView(viewModel: ChallengeFormViewModel(
                challenge: challenge,
                onSave: { newChallenge in
                    DispatchQueue.main.async {
                        challenge = newChallenge
                        isPresentingWorkoutForm = false
                    }
                },
                onDelete: { challenge in
                    DispatchQueue.main.async {
                        self.isPresentingWorkoutForm = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            ))
        }
    }
    
    private func updateChallenge(oldChallenge: Challenge, newChallenge: Challenge) {
        if let index = currentUser.challenges.firstIndex(where: { $0.id == oldChallenge.id }) {
            currentUser.challenges[index] = newChallenge
        }
    }
    
    private func deleteChallenge(_ challenge: Challenge) {
        currentUser.challenges.removeAll { $0.id == challenge.id }
    }
    
    private func calculatePoints(for user: User) -> Int {
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
                .padding(.bottom)
            
            ForEach(Array(challenge.participants.enumerated()), id: \.element.id) { index, user in
                HStack(spacing: 14) {
                    Text("\(index + 1)")
                        .font(.title)
                        .fontWeight(.bold)
                    ZStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                        
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
                                            .foregroundColor(.accent),
                                        alignment: .center
                                    )
                                    .overlay(
                                        Circle().stroke(.accent, lineWidth: 1)
                                    )
                            }
                            .offset(x: 15, y: 15)
                        }
                    }
                    .frame(width: 42, height: 42)
                    
                    HStack(spacing: 8) {
                        Text(user.username)
                            .font(.body)
                        
                        if user.id == challenge.ownerId {
                            Text("Owner")
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
            Text("Point System")
                .font(.headline)
                .padding(.bottom)
            
            HStack(spacing: 20) {
                PointCard(icon: "scalemass", title: "per kg", points: challenge.pointsPerKg)
                PointCard(icon: "arrow.up.and.down.circle", title: "per rep", points: challenge.pointsPerRep)
                PointCard(icon: "clock", title: "per hr", points: challenge.pointsPerHour)
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
                .foregroundColor(.accent)
            Text(title)
                .foregroundColor(.secondary)
            Text("\(points)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text("pts")
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
    ownerId: _previewParticipants[0].id,
    startAt: Date().addingTimeInterval(-60 * 60 * 24 * 10),
    endAt: Date().addingTimeInterval(60 * 60 * 24 * 30),
    pointsPerHour: 100,
    pointsPerRep: 5,
    pointsPerKg: 10,
    name: "30-Day Fitness",
    notes: "Join us in this 30-day fitness challenge!",
    participants: _previewParticipants
)

let _previewParticipants = [
    User(id: currentUserId, username: "teujorge", name:"Matheus Jorge"),
    User(username: "alice", name: "Alice"),
    User(username: "bobby", name: "Bob"),
    User(username: "ccc", name: "Charlie")
]
