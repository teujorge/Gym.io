//
//  WorkoutStartedView.swift
//  Gym.io
//
//  Created by Davi Guimell on 08/07/24.
//

import SwiftUI

struct WorkoutStartedView: View {
    
    @StateObject var viewModel:WorkoutStartedViewModel
        
    init(workout:Workout){
        _viewModel = StateObject(wrappedValue: WorkoutStartedViewModel(workout: workout))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                ForEach($viewModel.workout.exercises, id: \.id) { $exercise in
                    ExerciseCardView(exercise: $exercise, viewModel: viewModel)
                }
            }
            .padding()
        }
        .onAppear(perform: viewModel.startWorkoutTimer)
        .onDisappear(perform: viewModel.stopWorkoutTimer)
        .navigationTitle(viewModel.workout.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(viewModel.formattedTime(viewModel.workoutCounter))
                    .foregroundColor(.blue)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.stopWorkoutTimer) {
                    Text("Complete")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
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
                .foregroundColor(.blue)
            
            Text("Rest timer: \(viewModel.formattedTime(viewModel.restCounter))")
                .font(.caption)
                .foregroundColor(.blue)
            
            SetDetailsView(
                exercise: exercise,
                onSetComplete: { exerciseSet in
                    viewModel.completeSet(exerciseSet: exerciseSet)
                }
            )

//            Button(action: {
//                viewModel.completeSet(for: exercise.id)
//            }) {
//                Text("Complete Set")
//                    .padding(10)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .padding(.top)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .alert(isPresented: $viewModel.isPresentingSetCompletedAlert) {
            Alert(
                title: Text("Set completed"),
                message: Text("Do you want to go to the next set?"),
                primaryButton: .default(Text("Yes")) {
                    // get current exercise index in list
                    guard let index = viewModel.workout.exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
                    // get next exercise index
                    let nextIndex = index + 1
                    // check if next exercise is available
                    guard nextIndex < viewModel.workout.exercises.count else { return }
                    // set next exercise as current
                    viewModel.currentExercise = viewModel.workout.exercises[nextIndex]
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    NavigationView {
        WorkoutStartedView(workout: _previewWorkouts[0])
    }
}
