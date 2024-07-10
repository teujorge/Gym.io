//
//  LoadingButton.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct LoadingButton: View {
    let action: () -> Void
    let isLoading: Bool
    let isEnabled: Bool
    let title: String
    
    var body: some View {
        Button(action: { action() }) {
            if isLoading {
                ProgressView()
                    .padding()
                    .transition(.scale)
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isEnabled ? .white : .gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isEnabled ? Color.blue : Color.blue.opacity(0.25))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .transition(.opacity)
        .disabled(!isEnabled)
        .padding()
    }
}

#Preview {
    LoadingButton(
        action: { },
        isLoading: false,
        isEnabled: true,
        title: "Press"
    )
}
