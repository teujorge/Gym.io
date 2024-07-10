//
//  LabeledTextField.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct LabeledTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String? = nil
    var onChange: ((String) -> Void)? = nil
    var isDisabled: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(error == nil ? .secondary : .red)
            
            TextField(placeholder, text: $text)
                .disabled(isDisabled)
                .keyboardType(keyboardType)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(error == nil ? Color.gray : Color.red, lineWidth: 1)
                )
                .onChange(of: text) { oldValue, newValue in
                    onChange?(newValue)
                }
                .padding(.bottom, 5)
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
        .padding(.horizontal)
    }
}

#Preview {
    LabeledTextField(
        label: "Full name (optional):",
        placeholder: "Enter your full Name",
        text: .constant("write here...")
    )
}
