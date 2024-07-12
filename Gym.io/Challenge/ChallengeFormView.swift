//
//  ChallengeFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengeFormView: View {
    
    @EnvironmentObject var currentUser: User
    @StateObject var viewModel: ChallengeFormViewModel
    
    var body: some View {
        NavigationView {
            Form {
                
                // Details
                Section(header: Text("Challenge Details")) {
                    TextField("Name", text: $viewModel.challenge.name)
                    TextField("Description", text: $viewModel.challenge.notes)
                    DatePicker("Start Date", selection: $viewModel.challenge.startAt, displayedComponents: .date)
                    DatePicker("End Date", selection: $viewModel.challenge.endAt, displayedComponents: .date)
                }
                
                // Rules
                Section(header: Text("Rules")) {
                    Stepper(value: $viewModel.challenge.pointsPerKg, in: 0...100) {
                        HStack {
                            Text(viewModel.challenge.pointsPerKg.description)
                            Text("points per kgs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Stepper(value: $viewModel.challenge.pointsPerRep, in: 0...100) {
                        HStack {
                            Text(viewModel.challenge.pointsPerRep.description)
                            Text("points per reps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Stepper(value: $viewModel.challenge.pointsPerHour, in: 0...100) {
                        HStack {
                            Text(viewModel.challenge.pointsPerHour.description)
                            Text("points per hour")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Participants
                Section(header: Text("Participants")) {
                    List {
                        ForEach(viewModel.challenge.participants, id: \.id) { participant in
                            HStack {
                                Text(participant.name)
                                Spacer()
                                Button(action: {
                                    viewModel.challenge.participants.removeAll { $0.id == participant.id }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    viewModel.challenge.participants.removeAll { $0.id == participant.id }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                // Find Users
                FindUsersView { user in
                    viewModel.challenge.participants.append(user)
                }
                
            }
            .navigationTitle(viewModel.isEditing ? "Edit Challenge" : "New Challenge")
            .toolbar {
                if viewModel.isEditing {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", action: viewModel.deleteChallenge)
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: viewModel.saveChallenge)
                }
            }
        }
    }
}


struct FindUsersView: View {
    
    @State var users: [User] = []
    @State var searchText: String = ""
    let addParticipant: (User) -> Void
    
    var body: some View {
        Section(header: Text("Find Users")) {
            TextField("Search Users", text: $searchText)
                .padding(.horizontal)
                .onSubmit(fetchUsers)
            List {
                ForEach(users) { user in
                    HStack {
                        Text(user.username)
                        Spacer()
                        Button(action: { addParticipant(user) }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchUsers)
    }
    
    private func fetchUsers() {
        Task {
            let results: HTTPResponse<[User]> = await sendRequest(
                endpoint: "users",
                queryItems: [
                    URLQueryItem(name: "findMany", value: "true"),
                    URLQueryItem(name: "username", value: searchText)
                ],
                method: .GET
            )
            
            switch results {
            case .success(let fetchedUsers):
                DispatchQueue.main.async {
                    users = fetchedUsers
                }
            case .failure(let error):
                print(error)
            }
            
            
        }
    }
    
}


#Preview("New") {
    ChallengeFormView(viewModel: ChallengeFormViewModel(
        onSave: { challenge in
            print("Challenge saved: \(challenge)")
        }
    ))
}

#Preview("Edit") {
    ChallengeFormView(viewModel: ChallengeFormViewModel(
        challenge: _previewChallenge,
        onSave: { challenge in
            print("Challenge saved \(challenge)")
        },
        onDelete: { challenge in
            print("Challenge deleted \(challenge)")
        }
    ))
}
