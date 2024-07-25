//
//  WorkoutView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject var currentUser: User
    
    @StateObject var workoutPlan: WorkoutPlan
    
    var exercisePlansList: [(offset: Int, element: ExercisePlan)] {
        return Array(
            workoutPlan.exercisePlans
                .sorted(by: { $0.index < $1.index })
                .enumerated()
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let description = workoutPlan.notes {
                    Text(description)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                // Start Workout Button
                NavigationLink(destination: WorkoutStartedView(workoutPlan: workoutPlan)) {
                    Text("Start Workout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(.medium)
                    
                }
                .padding()
                
                // Exercise List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Exercises")
                        .font(.title2)
                    ForEach(exercisePlansList, id: \.element.id) { index, exercisePlan in
                        VStack(alignment: .leading) {
                            NavigationLink(destination: ExercisePlanView(exercisePlan: exercisePlan)) {
                                Text(exercisePlan.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accent)
                            }
                            
                            SetDetailsView(
                                details: SetDetails(exercisePlan: exercisePlan),
                                isEditable: false,
                                isPlan: true,
                                autoSave: false
                            )
                            
                            if index != workoutPlan.exercisePlans.count - 1 {
                                Divider()
                                    .padding(.top, 32)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                }
            }
            .padding()
        }
        .navigationTitle(workoutPlan.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(
                    destination: WorkoutPlanFormView(
                        workoutPlan: workoutPlan,
                        onSave: { workoutPlan in
                            if let workoutIndex = currentUser.workoutPlans.firstIndex(where: { $0.id == workoutPlan.id }) {
                                currentUser.workoutPlans[workoutIndex] = workoutPlan
                            }
                        },
                        onDelete: { workoutPlan in
                            currentUser.workoutPlans.removeAll(where: { $0.id == workoutPlan.id })
                        }
                    )
                ) {
                    Text("Edit")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.accent)
                    Image(systemName: "gear")
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
        }
    }
}


#Preview {
    NavigationView {
        WorkoutPlanView(workoutPlan: WorkoutPlan(
            name: "Full Body Workout",
            notes: "A complete workout targeting all major muscle groups.",
            exercisePlans: _previewExercisePlans
        ))
    }
}

var _previewExercisePlans: [ExercisePlan] = [
    ExercisePlan(
        name: "Squats",
        notes: "Stand with your feet shoulder-width apart. Lower your body as if you were sitting back into a chair. Push through your heels to return to the starting position.",
        isRepBased: true,
        index: 2,
        equipment: .none,
        muscleGroups: [.legs],
        setPlans: [
            ExerciseSetPlan(reps: 12, weight: 185),
            ExerciseSetPlan(reps: 10, weight: 185),
            ExerciseSetPlan(reps: 12, weight: 185),
            ExerciseSetPlan(reps: 10, weight: 185),
        ]
    ),
    ExercisePlan(
        name: "Plank",
        isRepBased: false,
        index: 3,
        equipment: .none,
        muscleGroups: [.core],
        setPlans: [
            ExerciseSetPlan(duration: 45, intensity: .low),
            ExerciseSetPlan(duration: 35, intensity: .low),
        ]
    ),
    ExercisePlan(
        name: "Bench Press",
        notes: "Lie on a flat bench with your feet flat on the floor. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the bar to your chest, then press it back up.",
        isRepBased: true,
        index: 1,
        equipment: .barbell,
        muscleGroups: [.chest, .arms],
        setPlans: [
            ExerciseSetPlan(reps: 10, weight: 135),
            ExerciseSetPlan(reps: 8, weight: 135),
            ExerciseSetPlan(reps: 10, weight: 135),
            ExerciseSetPlan(reps: 8, weight: 135),
        ]
    ),
    ExercisePlan(
        name: "Deadlift",
        notes: "Stand with your feet hip-width apart. Bend at the hips and knees to grip the barbell. Keep your back straight as you lift the barbell off the ground.",
        isRepBased: true,
        index: 4,
        equipment: .barbell,
        muscleGroups: [.legs, .core],
        setPlans: [
            ExerciseSetPlan(reps: 8, weight: 225),
            ExerciseSetPlan(reps: 8, weight: 225),
            ExerciseSetPlan(reps: 8, weight: 225),
        ]
    )
]
