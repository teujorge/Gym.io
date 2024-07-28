//
//  WorkoutsView.swift
//  Swety
//
//  Created by Davi Guimell on 05/07/24.
//

import SwiftUI

struct WorkoutPlansView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentUser: User
    @StateObject private var viewModel = WorkoutPlansViewModel()
    
    var filteredWorkouts: [Workout] {
        currentUser.workouts.filter { workout in
            workout.completedAt == nil
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                if !filteredWorkouts.isEmpty {
                    HStack {
                        Text("Workouts in Progress")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                viewModel.showWorkoutsInProgress.toggle()
                            }
                        }) {
                            Image(systemName: viewModel.showWorkoutsInProgress ? "chevron.up" : "chevron.down")
                                .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.showWorkoutsInProgress {
                        ForEach(filteredWorkouts.indices, id: \.self) { index in
                            WorkoutProgressCardView(workout: filteredWorkouts[index])
                                .transition(
                                    .scale(scale: 0.85)
                                    .combined(with: .opacity)
                                    .combined(with: .move(edge: .bottom))
                                )
                            if index < filteredWorkouts.count - 1 {
                                Divider()
                            }
                        }
                        .padding()
                    }
                }
                
                if !currentUser.workoutPlans.isEmpty {
                    HStack {
                        Text("Workout Plans")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                viewModel.showWorkoutPlans.toggle()
                            }
                        }) {
                            Image(systemName: viewModel.showWorkoutsInProgress ? "chevron.up" : "chevron.down")
                                .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.showWorkoutPlans {
                        ForEach(currentUser.workoutPlans.indices, id: \.self) { index in
                            WorkoutPlanCardView(
                                workoutPlan: currentUser.workoutPlans[index],
                                hasWorkoutInProgress: !filteredWorkouts.isEmpty
                            )
                            .transition(
                                .scale(scale: 0.85)
                                .combined(with: .opacity)
                                .combined(with: .move(edge: .bottom))
                            )
                            if index < currentUser.workoutPlans.count - 1 {
                                Divider()
                            }
                        }
                        .padding()
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.state)
            .background(Color(.systemBackground))
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(
                        destination: WorkoutPlanFormView(
                            onSave: { workoutPlan in
                                currentUser.workoutPlans.append(workoutPlan)
                            }
                        )
                    ) {
                        Text("New Workout")
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accent)
                    }
                }
                ToolbarItem(placement: .status) {
                    LoaderView(state: viewModel.state)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
        .onAppear {
            Task {
                let workoutsInProgress = await viewModel.fetchWorkoutsInProgress(for: currentUser.id)
                if let inProgress = workoutsInProgress {
                    for workout in inProgress {
                        if let index = currentUser.workouts.firstIndex(where: { $0.id == workout.id }) {
                            currentUser.workouts[index] = workout
                        } else {
                            currentUser.workouts.append(workout)
                        }
                    }
                }
                
                let workoutPlans = await viewModel.fetchWorkoutPlans(for: currentUser.id)
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
    var hasWorkoutInProgress: Bool
    
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
                
                if !hasWorkoutInProgress {
                    NavigationLink(destination: WorkoutStartedView(workoutPlan: workoutPlan)) {
                        Text("Start Workout")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accent)
                            .foregroundColor(.white)
                            .cornerRadius(.medium)
                            .disabled(hasWorkoutInProgress)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}

struct WorkoutProgressCardView: View {
    var workout: Workout
    
    var totalSetsCount: Int {
        workout.exercises.reduce(0) { count, exercise in
            count + exercise.sets.count
        }
    }
    
    var completedSetsCount: Int {
        workout.exercises.reduce(0) { count, exercise in
            count + exercise.sets.filter { $0.completedAt != nil }.count
        }
    }
    
    var body: some View {
        NavigationLink(destination: WorkoutPlanView(workoutPlan: workout.plan!)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.name)
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.accent)
                    
                    Text("Exercises: \(workout.exercises.count)")
                        .foregroundColor(.secondary)
                }
                
                if let description = workout.notes {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                ProgressView(value: Double(completedSetsCount), total: Double(totalSetsCount))
                    .progressViewStyle(.linear)
                    .foregroundColor(.accent)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                NavigationLink(destination: WorkoutStartedView(workout: workout)) {
                    Text("Continue Workout")
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
