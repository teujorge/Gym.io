//
//  SignUpView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authState: AuthState
    @ObservedObject var viewModel: SignUpViewModel
    
    var isDisabled: Bool {
        viewModel.state == .creatingAccount || viewModel.state == .accountCreated
    }
    
    var body: some View {
        ScrollView {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accent)
                .padding(.top)
            
            TextFieldView(
                label: "Full name:",
                placeholder: "Enter your full Name",
                text: $viewModel.newName,
                isDisabled: isDisabled
            )
            
            TextFieldView(
                label: "Username:",
                placeholder: "Enter a username",
                text: $viewModel.newUsername,
                onChange: { _ in viewModel.checkUsernameAvailability() },
                isDisabled: isDisabled,
                keyboardType: .namePhonePad
            )
            
            HStack {
                Text("Units:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Picker("Units", selection: $viewModel.selectedUnit) {
                    ForEach(Units.allCases, id: \.self) { unit in
                        Text(unit.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            HStack {
                Text("Birthday:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    viewModel.isPresentingBirthdayPicker.toggle()
                } label: {
                    Text(viewModel.birthday.formatted(.dateTime.year().month().day()))
                        .foregroundColor(.accent)
                }
            }
            .padding(.horizontal)
            
            LoadingButtonView(
                title: "Sign Up",
                state: viewModel.loaderState,
                disabled: isDisabled,
                showErrorMessage: true,
                action: {
                    Task {
                        if let newUser = await viewModel.signUp()  {
                            authState.currentUser = newUser
                        }
                    }
                }
            )
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(.large)
        .shadow(radius: .medium)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: viewModel.state)
        .sheet(isPresented: $viewModel.isPresentingBirthdayPicker) {
            VStack {
                Text("Select your birthday")
                    .font(.headline)
                    .fontWeight(.medium)
                    .padding()
                DatePicker("Birthday", selection: $viewModel.birthday, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .presentationDetents([.height(275)])
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SignUpView(viewModel: SignUpViewModel(authState: _previewAuthCreateAccountState))
    }
}

