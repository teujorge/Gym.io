//
//  WorkoutView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUser: User
    
    var workout: Workout
    @State var isPresentingWorkoutForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let description = workout.notes {
                    Text(description)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                // Start Workout Button
                NavigationLink(destination: WorkoutStartedView(workout: workout)) {
                    Text("Start Workout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
                .padding()
                
                // Exercise List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Exercises")
                        .font(.title2)
                    ForEach(workout.exercises) { exercise in
                        VStack(alignment: .leading) {
                            NavigationLink(destination: ExerciseView(exercise: exercise)) {
                                Text(exercise.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.accent)
                            }
                            DetailsView(sets: exercise.sets, isRepBased: exercise.isRepBased)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(workout.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isPresentingWorkoutForm.toggle() }) {
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
                .cornerRadius(20)
            }
        }
        .sheet(isPresented: $isPresentingWorkoutForm) {
            WorkoutFormView(
                workout: workout,
                onSave: { workout in
                    DispatchQueue.main.async {
                        if let workoutIndex = currentUser.workouts.firstIndex(where: { $0.id == workout.id }) {
                            currentUser.workouts[workoutIndex] = workout
                        }
                        isPresentingWorkoutForm = false
                    }
                },
                onDelete: { workout in
                    DispatchQueue.main.async {
                        if let workoutIndex = currentUser.workouts.firstIndex(where: { $0.id == workout.id }) {
                            currentUser.workouts.remove(at: workoutIndex)
                        }
                        isPresentingWorkoutForm = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

private struct DetailsView: View {
    var sets: [ExerciseSet]
    var isRepBased:Bool
    
    
    
    var body: some View {
        VStack(alignment: .center) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .center) {
                headerView
                setsList
                
            }
            
        }
        
    }
    
    private var setsList: some View {
        ForEach(sets) {exerciseSet in
            GridRow(alignment: .center) {
                Text("\(exerciseSet.index)")
                if isRepBased {
                    Text("\(exerciseSet.reps)")
                    Text("\(exerciseSet.weight)")
                } else {
                    Text("\(exerciseSet.duration)")
                    Text(exerciseSet.intensity.rawValue.lowercased())
                    
                    
                    
                    
                }
            }.font(.title3)
        }
    }
    
    private var headerView: some View {
        GridRow(alignment: .center) {
            VStack {
                Image(systemName: "number")
                    .fontWeight(.semibold)
                Text("Set")
                    .font(.headline)
            }
            if isRepBased {
                VStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .fontWeight(.semibold)
                    Text("Reps")
                        .font(.headline)
                }
                VStack {
                    Image(systemName: "scalemass")
                        .fontWeight(.semibold)
                    Text("Kg")
                        .font(.headline)
                }
            } else {
                VStack {
                    Image(systemName: "timer")
                        .fontWeight(.semibold)
                    Text("Sec")
                        .font(.headline)
                }
                VStack {
                    Image(systemName: "flame")
                        .fontWeight(.semibold)
                    Text("Intensity")
                        .font(.headline)
                }
            }
        }
        .frame(minHeight: 40)
    }
}

#Preview {
    NavigationView {
        WorkoutView(workout: Workout(
            ownerId: "1",
            title: "Full Body Workout",
            notes: "A complete workout targeting all major muscle groups.",
            exercises: _previewExercises
        ))
    }
}

var _previewExercises: [Exercise] = [
    Exercise(
        index: 2,
        name: "Squats",
        notes: "Stand with your feet shoulder-width apart. Lower your body as if you were sitting back into a chair. Push through your heels to return to the starting position.",
        sets: [
            ExerciseSet(index: 1, reps: 12, weight: 185),
            ExerciseSet(index: 2, reps: 10, weight: 185),
            ExerciseSet(index: 3, reps: 12, weight: 185),
            ExerciseSet(index: 4, reps: 10, weight: 185),
        ],
        isRepBased: true
    ),
    Exercise(
        index: 3,
        name: "Plank",
        sets: [
            ExerciseSet(index: 1, duration: 45, intensity: .low, completedAt: Date()),
            ExerciseSet(index: 2, duration: 35, intensity: .low),
        ],
        isRepBased: false
    ),
    Exercise(
        index: 1,
        name: "Bench Press",
        notes: "Lie on a flat bench with your feet flat on the floor. Grip the barbell with your hands slightly wider than shoulder-width apart. Lower the bar to your chest, then press it back up.",
        sets: [
            ExerciseSet(index: 1, reps: 10, weight: 135),
            ExerciseSet(index: 2, reps: 8, weight: 135),
            ExerciseSet(index: 3, reps: 10, weight: 135),
            ExerciseSet(index: 4, reps: 8, weight: 135),
        ],
        isRepBased: true
    ),
    Exercise(
        index: 4,
        name: "Deadlift",
        notes: "Stand with your feet hip-width apart. Bend at the hips and knees to grip the barbell. Keep your back straight as you lift the barbell off the ground.",
        sets: [
            ExerciseSet(index: 1, reps: 8, weight: 225),
            ExerciseSet(index: 2, reps: 8, weight: 225),
            ExerciseSet(index: 3, reps: 8, weight: 225),
        ],
        isRepBased: true
    )
]
