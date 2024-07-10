//
//  ChallengeFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengeFormView: View {
    
    var challenge: Challenge?
    var onSave: (Challenge) -> Void
    var onDelete: ((Challenge) -> Void)?
    
    init(onSave: @escaping (Challenge) -> Void) {
        self.challenge = nil
        self.onSave = onSave
        self.onDelete = nil
    }
    
    init(challenge: Challenge, onSave: @escaping (Challenge) -> Void, onDelete: @escaping (Challenge) -> Void) {
        self.challenge = challenge
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var pointsPerKg = 10
    @State private var pointsPerRep = 10
    @State private var pointsPerHour = 10
    @State private var paricipants: [User] = _previewParticipants
    @State private var startAt = Date()
    @State private var endAt = Date().addingTimeInterval(60 * 60 * 24 * 7)
    
    // Leading navigation bar item
    private var leadingNavigationBarItem: some View {
        Group {
            if let challenge = challenge, let onDelete = onDelete {
                Button("Delete") {
                    onDelete(challenge)
                }
                .foregroundColor(.red)
            } else {
                EmptyView()
            }
        }
    }
    
    private var trailingNavigationBarItem: some View {
        Button("Save") {
            onSave(Challenge(
                startAt: startAt,
                endAt: endAt,
                pointsPerHour: pointsPerHour,
                pointsPerRep: pointsPerRep,
                pointsPerKg: pointsPerKg,
                title: title,
                notes: notes,
                owner: _previewParticipants[0]
            ))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Challenge Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $notes)
                    DatePicker("Start Date", selection: $startAt, displayedComponents: .date)
                    DatePicker("End Date", selection: $endAt, displayedComponents: .date)
                }
                                
                Section(header: Text("Rules")) {
                    Stepper(value: $pointsPerKg, in: 0...100) {
                        HStack {
                            Text(pointsPerKg.description)
                            Text("points per 100 kgs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Stepper(value: $pointsPerRep, in: 0...100) {
                        HStack {
                            Text(pointsPerRep.description)
                            Text("points per 100 reps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Stepper(value: $pointsPerHour, in: 0...100) {
                        HStack {
                            Text(pointsPerHour.description)
                            Text("points per hour")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onAppear(perform: loadInitialChallengeData)
            .navigationTitle(challenge == nil ? "New Challenge" : "Edit Challenge")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leadingNavigationBarItem
                }
                ToolbarItem(placement: .topBarTrailing) {
                    trailingNavigationBarItem
                }
            }
        }
    }
    
    private func loadInitialChallengeData() {
        guard let challenge = challenge else { return }
        
        title = challenge.title
        notes = challenge.notes ?? ""
        pointsPerKg = challenge.pointsPerKg
        pointsPerRep = challenge.pointsPerRep
        pointsPerHour = challenge.pointsPerHour
        startAt = challenge.startAt
        endAt = challenge.endAt
    }
    
}


#Preview("New") {
    ChallengeFormView() { challenge in
        print("Challenge saved: \(challenge)")
    }
}

#Preview("Edit") {
    ChallengeFormView(
        challenge: _previewChallenge,
        onSave: { challenge in
            print("Challenge saved \(challenge)")
        },
        onDelete: { challenge in
            print("Challenge deleted \(challenge)")
        }
    )
}
