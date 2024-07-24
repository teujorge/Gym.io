//
//  TextFieldView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

struct TextFieldView: View {
    let label: String?
    let placeholder: String?
    @Binding var text: String
    var error: String? = nil
    var onChange: ((String) -> Void)? = nil
    var isDisabled: Bool = false
    var lines: Int = 1
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let label = label {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(error == nil ? .secondary : .red)
            }
            
            if lines > 1 {
                TextEditor(text: $text)
                    .disabled(isDisabled)
                    .keyboardType(keyboardType)
                    .frame(minHeight: CGFloat(lines * 24), alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(error == nil ? Color.gray : Color.red, lineWidth: 1)
                    )
                    .onChange(of: text) { oldValue, newValue in
                        onChange?(newValue)
                    }
                    .padding(.bottom, 5)
            } else {
                TextField(placeholder ?? "", text: $text)
                    .disabled(isDisabled)
                    .keyboardType(keyboardType)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(error == nil ? Color.gray : Color.red, lineWidth: 1)
                    )
                    .onChange(of: text) { oldValue, newValue in
                        onChange?(newValue)
                    }
                    .padding(.bottom, 5)
            }
            
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
    TextFieldView(
        label: "Full name (optional):",
        placeholder: "Enter your full Name",
        text: .constant("write here...")
    )
}
