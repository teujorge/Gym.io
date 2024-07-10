//
//  ExerciseSetsDetailView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

struct ExerciseSetsDetailView: View {
    
    @Binding var exercise: Exercise
    
    var body: some View {
        VStack {
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                headerView
                Divider()
                setsList
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            addSetButton
        }
    }
    
    private var setsList: some View {
        ForEach($exercise.sets.indices, id: \.self) { index in
            GridRow {
                Text("\(index + 1)")
                    .frame(maxWidth: .infinity)
                if exercise.isRepBased {
                    TextField("Reps", value: $exercise.sets[index].reps, formatter: NumberFormatter())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    TextField("Weight", value: $exercise.sets[index].weight, formatter: NumberFormatter())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                } else {
                    TextField("Duration", value: $exercise.sets[index].duration, formatter: NumberFormatter())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    Picker("Intensity", selection: $exercise.sets[index].intensity) {
                        ForEach(Intensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity)
            .background(index % 2 == 0 ? .blue.opacity(0.05) : .blue.opacity(0.10))
        }
    }
    
    private var headerView: some View {
        GridRow {
            Text("Set").bold()
            if exercise.isRepBased {
                Text("Reps").bold()
                Text("Kg").bold()
            } else {
                Text("Sec").bold()
                Text("Intensity").bold()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(.blue)
        .foregroundColor(.white)
    }
    
    private var addSetButton: some View {
        HStack {
            Button(action: { exercise.sets.append(ExerciseSet(index: exercise.sets.count)) } ) {
                Text("Add set")
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding(6)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(20)
        }
    }
    
}



#Preview {
    ExerciseSetsDetailView(exercise: .constant(_previewExercises[1]))
}
