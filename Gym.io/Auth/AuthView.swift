//
//  AuthView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import Combine

struct AuthView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                NavigationLink(destination: SignInView()) {
                    Text("Sign In")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Gym.io")
        }
    }
}


#Preview {
    AuthView()
        .environmentObject(AuthState())
}
