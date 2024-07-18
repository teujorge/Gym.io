//
//  ExerciseView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExerciseView: View {
    @StateObject var exercise: Exercise
    @State private var isPresentingExerciseForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .trailing) {
                    if let imageName = exercise.imageName {
                        Image(systemName: imageName)
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
                
                if let instructions = exercise.notes {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                SetDetailsView(exercise: exercise)
                
                Spacer()
                Button(action: {
                    // Start exercise action
                }) {
                    Text("Start Exercise")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(.medium)
                }
                .padding()
            }
            .sheet(isPresented: $isPresentingExerciseForm) {
                ExerciseFormView(
                    exercise: exercise,
                    onSave: { exercise in
                        isPresentingExerciseForm = false
                    },
                    onDelete: { exercise in
                        isPresentingExerciseForm = false
                    }
                )
            }
        }
        .navigationTitle(exercise.name)
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
        ExerciseView(
            exercise: _previewExercises[1]
        )
    }
}
