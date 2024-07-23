//
//  ExerciseView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExercisePlanView: View {
    @StateObject var exercisePlan: ExercisePlan
    @State private var isPresentingExerciseForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .trailing) {
                    if let image = exercisePlan.image {
                        Image(systemName: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(.all, 24)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(.medium)
                            .padding()
                    }
                }
                .padding()
                
                if let instructions = exercisePlan.notes {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                SetDetailsView(
                    details: SetDetails(exercisePlan: exercisePlan),
                    isEditable: true,
                    isPlan: true,
                    autoSave: false
                )
                .padding()
            }
        }
        .navigationTitle(exercisePlan.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isPresentingExerciseForm.toggle() }) {
                    Text("Edit")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.accent)
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .foregroundColor(.accent)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.accent.opacity(0.2))
                .cornerRadius(.large)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
    
}


#Preview {
    NavigationView {
        ExercisePlanView(
            exercisePlan: _previewExercisePlans[1]
        )
    }
}
