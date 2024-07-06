//
//  ChallengesFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/6/24.
//

import SwiftUI

struct ChallengesFormView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    var onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Challenge Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section {
                    Button("Save") {
                        onSave(title, description)
                    }
                }
            }
            .navigationTitle("Challenge Form")
            .navigationBarItems(leading: Button("Cancel") {
                // Handle cancel action
            })
        }
    }
}

#Preview {
    ChallengesFormView() { _, _ in }
}
