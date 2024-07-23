//
//  WorkoutsView.swift
//  Swety
//
//  Created by Davi Guimell on 05/07/24.
//

import SwiftUI

struct WorkoutPlansView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var currentUser: User
    @StateObject private var viewModel = WorkoutPlansViewModel()
    
    var filteredWorkouts: [WorkoutPlan] {
        if viewModel.searchText.isEmpty {
            return currentUser.workoutPlans
        } else {
            return currentUser.workoutPlans.filter {
                $0.name.localizedCaseInsensitiveContains(viewModel.searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(filteredWorkouts.indices, id: \.self) { index in
                        WorkoutPlanCardView(workoutPlan: currentUser.workoutPlans[index])
                            .transition(
                                .scale(scale: 0.85)
                                .combined(with: .opacity)
                                .combined(with: .move(edge: .bottom))
                            )
                        if index < filteredWorkouts.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding()
                .animation(.easeInOut, value: viewModel.state)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(
                        destination: WorkoutPlanFormView(onSave: { workoutPlan in
                            DispatchQueue.main.async {
                                currentUser.workoutPlans.append(workoutPlan)
                                dismiss() // pop the form view TODO: not popping atm
                            }
                        })
                    ) {
                        Text("New Workout")
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accent)
                    }
                }
                if (viewModel.state != .idle) {
                    ToolbarItem(placement: .status) {
                        LoaderView(state: viewModel.state)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
        .onAppear {
            Task {
                let workoutPlans = await viewModel.fetchWorkouts(for: currentUser.id)
                if let plans = workoutPlans {
                    for plan in plans {
                        if let index = currentUser.workoutPlans.firstIndex(where: { $0.id == plan.id }) {
                            currentUser.workoutPlans[index] = plan
                        } else {
                            currentUser.workoutPlans.append(plan)
                        }
                    }
                }
            }
        }
    }
    
}

struct WorkoutPlanCardView: View {
    
    var workoutPlan: WorkoutPlan
    
    var body: some View {
        NavigationLink(destination: WorkoutPlanView(workoutPlan: workoutPlan)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(workoutPlan.name)
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.accent)
                    
                    Text("Exercises: \(workoutPlan.exercisePlans.count)")
                        .foregroundColor(.secondary)
                }
                
                if let description = workoutPlan.notes {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                NavigationLink(destination: WorkoutStartedView(workoutPlan: workoutPlan)) {
                    Text("Start Workout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(.medium)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}


#Preview {
    WorkoutPlansView()
        .environmentObject(
            User(
                id: "000739.b5fe4b10f0654ffcb1b9c5109c11887c.1710",
                username: "teujorge",
                name: "matheus",
                workouts: []
            )
        )
}

let _previewWorkoutPlans = [
    WorkoutPlan(
        name: "Davi's workout",
        notes: "A challenging workout to test your limits.",
        exercisePlans: _previewExercisePlans
    ),
    WorkoutPlan(
        name: "Ricardo's workout",
        notes: "pussy shit",
        exercisePlans: [
            ExercisePlan(
                name: "sit on 8=D",
                isRepBased: true,
                equipment: .ball,
                muscleGroups: [.chest],
                setPlans: [
                    ExerciseSetPlan(reps: 6, weight: 35),
                    ExerciseSetPlan(reps: 5, weight: 30),
                    ExerciseSetPlan(reps: 4, weight: 25)
                ]
            ),
            ExercisePlan(
                name: "give but whole",
                isRepBased: false,
                equipment: .none,
                muscleGroups: [.back],
                setPlans: [
                    ExerciseSetPlan(duration: 60, intensity: .low),
                    ExerciseSetPlan(reps: 30, intensity: .high),
                ]
            )
        ]
    )
]
