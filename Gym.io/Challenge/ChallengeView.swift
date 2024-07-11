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
            VStack(alignment: .leading, spacing: 25) {
                
                ProgressView(value:0.01).progressViewStyle(.linear)
                
                // Dates
                HStack {
                    VStack(alignment: .leading , spacing:8 ){
                        Text("Start Date:")
                            .font(.headline)
                        Text(challenge.startAt, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    VStack(alignment: .leading , spacing:8 ){
                        Text("End Date:")
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
                
                // Participants/Ranking
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants")
                        .font(.headline)
                    
                    ForEach($challenge.participants, id: \.id) { $user in
                        HStack {
                            Text("1").font(.title)
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width:50,height:50)
                                
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
                .padding()
                .background(.gray.opacity(0.2))
                .cornerRadius(15)
                
                
                
                ChallengePointsView(challenge: challenge)
                // Point System
                
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Point System:")
//                        .font(.headline)
//                    Text("Points per kg -> \(challenge.pointsPerKg)")
//                        .font(.subheadline)
//                    Text("Points per rep -> \(challenge.pointsPerRep)")
//                        .font(.subheadline)
//                    Text("Points per hour -> \(challenge.pointsPerHour)")
//                        .font(.subheadline)
//                }
//                .padding()
//                .frame(maxWidth:.infinity)
//                .background(.gray.opacity(0.2))
//                .cornerRadius(15)
                
                
                
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

struct ChallengePointsView: View {
    var challenge: Challenge  // Assuming Challenge has pointsPerKg, pointsPerRep, pointsPerHour

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
            Text("\(points, specifier: "%.1f") pts")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(width: 100, height: 120)
        .background(.gray.opacity(0.2))
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
