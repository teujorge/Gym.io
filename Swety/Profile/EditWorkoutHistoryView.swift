//
//  EditWorkoutHistoryView.swift
//  Swety
//
//  Created by Matheus Jorge on 8/2/24.
//

import SwiftUI

struct EditWorkoutHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dialogManager: DialogManager
    @EnvironmentObject var currentUser: User
    @StateObject var viewModel: EditWorkoutHistoryViewModel
    
    init(workout: Workout) {
        _viewModel = StateObject(wrappedValue: EditWorkoutHistoryViewModel(workout: workout))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Workout Details Header
                Text("Workout Details")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Start and Finish Date Pickers
                VStack(spacing: 20) {
                    DatePicker("Start", selection: $viewModel.startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(.horizontal)

                    DatePicker("Finish", selection: $viewModel.finishDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding()
                
                // Exercises Header
                Text("Exercises")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Exercise List
                ForEach($viewModel.workout.exercises, id: \.id) { $exercise in
                    ExerciseCardView(exercise: $exercise, viewModel: viewModel)
                    if !viewModel.isLastExercise(exercise: exercise) {
                        Divider()
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.workout.name)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Delete", action: deleteWorkout)
                Button("Cancel", action: { dismiss() })
                Button("Save", action: saveWorkout)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
    
    // Function to delete workout
    private func deleteWorkout() {
        Task {
            dialogManager.showDialog {
                LoaderView()
            }
            if let workout = await viewModel.deleteWorkout() {
                DispatchQueue.main.async {
                    currentUser.workouts.removeAll { $0.id == workout.id }
                    dismiss()
                }
            }
            dialogManager.hideDialog()
        }
    }
    
    // Function to save workout
    private func saveWorkout() {
        Task {
            dialogManager.showDialog {
                LoaderView()
            }
            if let workout = await viewModel.updateWorkout() {
                DispatchQueue.main.async {
                    currentUser.workouts.removeAll { $0.id == workout.id }
                    currentUser.workouts.append(workout)
                    dismiss()
                }
            }
            dialogManager.hideDialog()
        }
    }
}

fileprivate struct ExerciseCardView: View {
    @Binding var exercise: Exercise
    @ObservedObject var viewModel: EditWorkoutHistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(exercise.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
            
            SetDetailsView(
                details: SetDetails(exercise: exercise),
                isEditable: true,
                isPlan: false,
                autoSave: false,
                showTimer: false,
                onDetailsChanged: { setDetails in
                    exercise = setDetails.createExercise(from: exercise)
                }
            )
            .padding(.top)
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        EditWorkoutHistoryView(workout: Workout(
            name: "Workout X",
            exercises: _previewExercisePlans.map { Exercise(exercisePlan: $0) }
        ))
        .environmentObject(User(username: "teujorge", name: "Matheus Jorge"))
        .environmentObject(DialogManager())
    }
}

//import SwiftUI
//
//struct EditWorkoutHistoryView: View {
//    @Environment (\.dismiss) var dismiss
//    @EnvironmentObject var dialogManager: DialogManager
//    @EnvironmentObject var currentUser: User
//    @StateObject var viewModel: EditWorkoutHistoryViewModel
//    
//    init (workout: Workout) {
//        _viewModel = StateObject(wrappedValue: EditWorkoutHistoryViewModel(workout: workout))
//    }
//    
//    var body: some View {
//        ScrollView {
//            // Exercises to edit
//            VStack(alignment: .center) {
//                
//                VStack(spacing: 20) {
//                    Divider()
//                    
//                    // Start Date and Time Picker
//                    DatePicker("Start", selection: $viewModel.startDate, displayedComponents: [.hourAndMinute])
//                        .datePickerStyle(.compact)
//                        .padding(.horizontal)
//
//                    // End Date and Time Picker
//                    DatePicker("Finish", selection: $viewModel.finishDate, displayedComponents: [.date, .hourAndMinute])
//                        .datePickerStyle(.compact)
//                        .padding(.horizontal)
//                    
//                    Divider()
//                }
//                
//                // Exercises
//                ForEach($viewModel.workout.exercises, id: \.id) { $exercise in
//                    ExerciseCardView(exercise: $exercise, viewModel: viewModel)
//                    if !viewModel.isLastExercise(exercise: exercise) {
//                        Divider()
//                            .padding(.top)
//                    }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle(viewModel.workout.name)
//        .toolbar {
//            ToolbarItemGroup(placement: .primaryAction) {
//                Button("Delete", action: {
//                    Task {
//                        dialogManager.showDialog {
//                            LoaderView()
//                        }
//                        if let workout = await viewModel.deleteWorkout() {
//                            DispatchQueue.main.async {
//                                currentUser.workouts.removeAll { $0.id == workout.id }
//                                dismiss()
//                            }
//                        }
//                        dialogManager.hideDialog()
//                    }
//                })
//                Button("Cancel", action: {
//                    DispatchQueue.main.async {
//                        dismiss()
//                    }
//                })
//                Button("Save", action: {
//                    Task {
//                        dialogManager.showDialog {
//                            LoaderView()
//                        }
//                        if let workout = await viewModel.updateWorkout() {
//                            DispatchQueue.main.async {
//                                currentUser.workouts.removeAll { $0.id == workout.id }
//                                currentUser.workouts.append(workout)
//                                dismiss()
//                            }
//                        }
//                        dialogManager.hideDialog()
//                    }
//                })
//            }
//            ToolbarItemGroup(placement: .keyboard) {
//                Spacer()
//                Button("Done", action: dismissKeyboard)
//            }
//        }
//    }
//}
//
//fileprivate struct ExerciseCardView: View {
//    @Binding var exercise: Exercise
//    @ObservedObject var viewModel: EditWorkoutHistoryViewModel
//    
//    var body: some View {
//        VStack(alignment: .center) {
//            Text(exercise.name)
//                .font(.title2)
//                .fontWeight(.semibold)
//                .foregroundColor(.accent)
//                .padding()
//            
//            SetDetailsView(
//                details: SetDetails(exercise: exercise),
//                isEditable: true,
//                isPlan: false,
//                autoSave: false,
//                showTimer: false,
//                onDetailsChanged: { setDetails in
//                    exercise = setDetails.createExercise(from: exercise)
//                }
//            )
//            
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .cornerRadius(.medium)
//    }
//}
//
//#Preview {
//    NavigationView {
//        EditWorkoutHistoryView(workout: Workout(
//            name: "Workout X",
//            exercises: _previewExercisePlans.map { Exercise(exercisePlan: $0) }
//        ))
//        .environmentObject(User(username:"teujorge", name:"Matheus Jorge"))
//        .environmentObject(DialogManager())
//    }
//}
