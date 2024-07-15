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
                        .background(Color.blue)
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
                .opacity(viewModel.currentExerciseId == exercise.id ? 1 : 0)
            
            SetDetailsView(exercise: exercise)
            
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
    }
}

#Preview {
    NavigationView {
        WorkoutStartedView(workout: _previewWorkouts[0])
    }
}
