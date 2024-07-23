//
//  ExerciseView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExercisePlanView: View {
    @StateObject var exercisePlan: ExercisePlan
    
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
    }
    
}


#Preview {
    NavigationView {
        ExercisePlanView(
            exercisePlan: _previewExercisePlans[1]
        )
    }
}
