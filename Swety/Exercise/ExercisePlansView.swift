//
//  ExercisePlansView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/21/24.
//

import SwiftUI

struct ExercisePlansView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedExercises: [ExercisePlan]
    
    @State private var searchQuery = ""
    @State private var selectedEquipment: Equipment? = nil
    @State private var selectedMuscleGroup: MuscleGroup? = nil
    @State private var allDefaultExercises: [ExercisePlan] = []
    
    var filteredExercises: [ExercisePlan] {
        allDefaultExercises.filter { exercise in
            (searchQuery.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchQuery)) &&
            (selectedEquipment == nil || exercise.equipment == selectedEquipment) &&
            (selectedMuscleGroup == nil || exercise.muscleGroups.contains(selectedMuscleGroup!))
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredExercises) { exercise in
                    Button(role: nil, action: {
                        if selectedExercises.contains(where: { $0.name == exercise.name }) {
                            selectedExercises.removeAll(where: { $0.name == exercise.name })
                        } else {
                            selectedExercises.append(exercise)
                        }
                    }) {
                        HStack {
                            ExerciseRowView(exercise: exercise)
                            Spacer()
                            if selectedExercises.contains(where: { $0.name == exercise.name }) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.accent)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .transition(.opacity)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                    Divider()
                }
            }
            .padding()
            .padding(.top)
            .padding(.bottom, 116) // needs to match filter section height
            .onAppear(perform: loadExercises)
        }
        .overlay(
            VStack {
                HStack {
                    // Picker for equipment
                    Picker("Equipment", selection: $selectedEquipment) {
                        Text("Equipment").tag(Equipment?.none)
                        ForEach(Equipment.allCases, id: \.self) { equipment in
                            Text(equipment.rawValue.capitalized.replacing("_", with: " ")).tag(equipment as Equipment?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Spacer()
                    
                    // Picker for muscle groups
                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        Text("Muscles").tag(MuscleGroup?.none)
                        ForEach(MuscleGroup.allCases, id: \.self) { muscleGroup in
                            Text(muscleGroup.rawValue.capitalized).tag(muscleGroup as MuscleGroup?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                }
                // Search bar
                TextField("Search", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
            }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(.large)
                .padding()
                .shadow(radius: .medium)
            , alignment: .bottom
        )
        .navigationBarTitle("Exercises")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: { dismiss() })
            }
        }
    }
    
    func loadExercises() {
        Task {
            let response: HTTPResponse<[DefaultExercisePlan]> = await sendRequest(endpoint: "/exercises/defaults", method: .GET)
            switch response {
            case .success(let plans):
                DispatchQueue.main.async {
                    self.allDefaultExercises = plans.map { $0.toExercisePlan() }
                }
            case .failure(let error):
                print("Failed to load exercises: \(error)")
            }
        }
    }
}

private struct ExerciseRowView: View {
    var exercise: ExercisePlan
    
    var body: some View {
        HStack {
            if let imageName = exercise.image, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                Text(exercise.notes ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Equipment: \(exercise.equipment.rawValue.capitalized)")
                    .font(.footnote)
                    .foregroundColor(.blue)
                Text("Muscles: \(exercise.muscleGroups.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(.green)
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationView {
        ExercisePlansView(
            selectedExercises: .constant([ExercisePlan(name: "Plank", notes: "some large notes, some large notes, some more notes blah blah blah... heyo", isRepBased: true, equipment: .bodyweight, muscleGroups: [.core, .arms])])
        )
    }
}
