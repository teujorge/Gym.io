//
//  ChallengesView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengesView: View {
    
    @EnvironmentObject var currentUser: User
    @StateObject private var viewModel = ChallengesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack {
                    ForEach(currentUser.challenges.indices, id: \.self) { index in
                        ChallengeCardView(challenge: currentUser.challenges[index])
                            .transition(
                                .scale(scale: 0.85)
                                .combined(with: .opacity)
                                .combined(with: .move(edge: .bottom))
                            )
                        //                            .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: currentUser.challenges[index].id)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .animation(.easeInOut, value: currentUser.challenges)
                
                if (viewModel.state != .idle) {
                    LoaderView(state: viewModel.state, showErrorMessage: true)
                        .padding()
                }
                
            }
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { viewModel.isPresentingChallengesForm = true }) {
                        HStack {
                            Text("New")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.accent)
                            Image(systemName: "star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .foregroundColor(.accent)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.accent.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentingChallengesForm) {
                ChallengeFormView(viewModel: ChallengeFormViewModel(
                    onSave: { challenge in
                        currentUser.challenges.append(challenge)
                        viewModel.isPresentingChallengesForm = false
                    }
                ))
            }
            .onAppear(perform: loadChallenges)
        }
    }
    
    private func loadChallenges() {
        Task {
            let result = await viewModel.fetchChallenges(currentUser.id)
            if let fetchedChallenges = result {
                DispatchQueue.main.async {
                    self.currentUser.challenges = fetchedChallenges
                }
            }
        }
    }
    
}

struct ChallengeCardView: View {
    let challenge: Challenge
    
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
