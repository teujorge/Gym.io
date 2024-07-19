//
//  ChallengeFormView.swift
//  Swety
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
                Section(header: Text("Challenge Details")) {
                    TextField("Name", text: $viewModel.challenge.name)
                    TextField("Description", text: $viewModel.challenge.notes)
                    DatePicker("Start Date", selection: $viewModel.challenge.startAt, displayedComponents: .date)
                    DatePicker("End Date", selection: $viewModel.challenge.endAt, displayedComponents: .date)
                }
                RulesSectionView(challenge: $viewModel.challenge)
                ParticipantsSectionView(participants: $viewModel.challenge.participants)
                FindUsersView { user in
                    viewModel.challenge.participants.append(user)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Challenge" : "New Challenge")
            .toolbar {
                if viewModel.isEditing {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", action: { viewModel.isShowingActionSheet = true })
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: viewModel.saveChallenge)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
            .sheet(isPresented: $viewModel.isShowingActionSheet) {
                VStack {
                    if viewModel.state == .loading {
                        LoaderView()
                    } else {
                        Text("Are you sure?")
                            .font(.headline)
                            .padding()
                        
                        HStack {
                            Button("Cancel") {
                                viewModel.isShowingActionSheet = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(.accent)
                            .cornerRadius(.medium)
                            
                            Button("Delete") {
                                viewModel.deleteChallenge()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(.red)
                            .cornerRadius(.medium)
                        }
                        .frame(maxHeight: 50)
                    }
                }
                .padding()
                .presentationDetents([.height(150)])
            }
        }
    }
}


private struct ParticipantsSectionView: View {
    @Binding var participants: [User]
    
    var body: some View {
        Section(header: Text("Participants")) {
            List {
                ForEach(participants, id: \.id) { participant in
                    ParticipantRow(participant: participant, participants: $participants)
                }
            }
        }
    }
}

private struct ParticipantRow: View {
    var participant: User
    @Binding var participants: [User]
    
    var body: some View {
        HStack {
            Text(participant.name)
            Spacer()
            Button(action: {
                participants.removeAll { $0.id == participant.id }
            }) {
                Image(systemName: "trash").foregroundColor(.red)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
                participants.removeAll { $0.id == participant.id }
            }) {
                Image(systemName: "trash").foregroundColor(.red)
            }
        }
    }
}

private struct RulesSectionView: View {
    @Binding var challenge: Challenge
    
    var body: some View {
        Section(header: Text("Rules")) {
            Stepper(value: $challenge.pointsPerKg, in: 0...100) {
                Text("\(challenge.pointsPerKg) points per kgs")
            }
            Stepper(value: $challenge.pointsPerRep, in: 0...100) {
                Text("\(challenge.pointsPerRep) points per reps")
            }
            Stepper(value: $challenge.pointsPerHour, in: 0...100) {
                Text("\(challenge.pointsPerHour) points per hour")
            }
        }
    }
}


private struct FindUsersView: View {
    
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
                endpoint: "/users",
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
