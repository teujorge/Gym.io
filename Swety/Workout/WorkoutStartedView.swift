//
//  WorkoutStartedView.swift
//  Swety
//
//  Created by Davi Guimell on 08/07/24.
//

import SwiftUI

struct WorkoutStartedView: View {
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var currentUser: User
    @StateObject var viewModel: WorkoutStartedViewModel
    
    init(workoutPlan: WorkoutPlan){
        _viewModel = StateObject(wrappedValue: WorkoutStartedViewModel(workoutPlan: workoutPlan))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                ForEach($viewModel.workout.exercises, id: \.id) { $exercise in
                    ExerciseCardView(exercise: $exercise, viewModel: viewModel)
                    if !viewModel.isLastExercise(exercise: exercise) {
                        Divider()
                    }
                }
            }
            .padding()
        }
        .onAppear(perform: viewModel.initiateWorkout)
        .onDisappear(perform: viewModel.stopWorkoutTimer)
        .navigationTitle(viewModel.workout.name)
        .toolbar {
            ToolbarItem(placement: .status) {
                Text(formatTime(viewModel.workoutCounter))
                    .foregroundColor(.accent)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Finish", action: {
                    viewModel.stopWorkoutTimer()
                    viewModel.completeWorkout() { newWorkout in
                        currentUser.workouts.append(newWorkout)
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
}

private struct ExerciseCardView: View {
    @Binding var exercise: Exercise
    @ObservedObject var viewModel: WorkoutStartedViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.accent)
            
            Text("Rest timer: \(formatTime(viewModel.restCounter))")
                .font(.caption)
                .foregroundColor(.accent)
                .padding(.bottom, 8)
            
            SetDetailsView(
                sets: exercise.sets.map { SetDetails(exerciseSet: $0) },
                isEditable: true,
                isPlan: false,
                isRepBased: exercise.isRepBased,
                autoSave: false,
                onSetsChanged: { setDetails in
                    exercise.sets = setDetails.enumerated().map { (index, setDetail) in
                        setDetail.toSet(index: index)
                    }
                }
            )
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cornerRadius(.medium)
    }
}

#Preview {
    NavigationView {
        WorkoutStartedView(workoutPlan: _previewWorkoutPlans[1])
    }
}
