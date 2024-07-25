//
//  WorkoutPlanFormView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct WorkoutPlanFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.dismissAll) var dismissAll
    
    @EnvironmentObject private var currentUser: User
    @EnvironmentObject private var dialogManager: DialogManager
    
    @StateObject private var viewModel: WorkoutPlanFormViewModel
    
    var exercisePlansList: [(offset: Int, element: ExercisePlan)] {
        return Array(
            viewModel.workoutPlan.exercisePlans
                .sorted(by: { $0.index < $1.index })
                .enumerated()
        )
    }
    
    // Initializer with save functionality only
    init(onSave: @escaping (WorkoutPlan) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanFormViewModel(
            workoutPlan: nil,
            onSave: onSave,
            onDelete: {workoutPlan in}
        ))
    }
    
    // Initializer with workout, save and delete functionality
    init(workoutPlan: WorkoutPlan, onSave: @escaping (WorkoutPlan) -> Void, onDelete: @escaping (WorkoutPlan) -> Void) {
        _viewModel = StateObject(wrappedValue: WorkoutPlanFormViewModel(
            workoutPlan: workoutPlan,
            onSave: onSave,
            onDelete: onDelete
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        // Workout details section
                        TextFieldView(label: "Name", placeholder: "Name", text: $viewModel.nameText)
                            .padding(.top)
                            .padding(.horizontal)
                        TextFieldView(label: "Description", placeholder: "Description", text: $viewModel.notesText, lines: 3)
                            .padding()
                    }
                    .padding(.vertical)
                    
                    // Exercises section
                    ForEach(exercisePlansList, id: \.element.id) { index, exercisePlan in
                        VStack(alignment: .leading) {
                            // Header
                            HStack {
                                // Move Buttons
                                VStack {
                                    if index != 0 {
                                        Button(action: {
                                            withAnimation {
                                                proxy.scrollTo(exercisePlansList[index - 1].element.id, anchor: .center)
                                                viewModel.moveExerciseUp(index: index)
                                            }
                                        }) {
                                            Image(systemName: "arrow.up")
                                                .foregroundColor(.accentColor)
                                                .font(.system(size: 14))
                                                .bold()
                                        }
                                    }
                                    if index != viewModel.workoutPlan.exercisePlans.count - 1 {
                                        Button(action: {
                                            withAnimation {
                                                proxy.scrollTo(exercisePlansList[index + 1].element.id, anchor: .center)
                                                viewModel.moveExerciseDown(index: index)
                                            }
                                        }) {
                                            Image(systemName: "arrow.down")
                                                .foregroundColor(.accentColor)
                                                .font(.system(size: 14))
                                                .bold()
                                        }
                                    }
                                }
                                
                                // Index
                                Text("\(index + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                
                                // Title
                                Text(exercisePlan.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                // Move and Delete Buttons
                                Button(action: {
                                    withAnimation {
                                        viewModel.deleteExercise(index: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            
                            SetDetailsView(
                                details: SetDetails(exercisePlan: exercisePlan),
                                isEditable: true,
                                isPlan: true,
                                autoSave: false,
                                onDetailsChanged: { setDetails in
                                    viewModel.workoutPlan.exercisePlans[index] = setDetails.createExercisePlan(from: exercisePlan)
                                }
                            )
                            .id(exercisePlan.id)
                            
                            if index < viewModel.workoutPlan.exercisePlans.count - 1 {
                                Divider()
                                    .padding(.top, 32)
                            }
                        }
                        .padding()
                        .transition(.move(edge: .bottom))
                        .swipeActions {
                            Button(action: { viewModel.editExercisePlan(exercisePlan) }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                if let index = viewModel.workoutPlan.exercisePlans.firstIndex(where: { $0.id == exercisePlan.id }) {
                                    viewModel.workoutPlan.exercisePlans.remove(at: index)
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .animation(.easeInOut, value: viewModel.workoutPlan.exercisePlans)
                    
                    // Add exercise button
                    NavigationLink(
                        destination: ExercisePlansView(selectedExercises: $viewModel.workoutPlan.exercisePlans)
                    ) {
                        Text("Add Exercise")
                            .foregroundColor(.accent)
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accent)
                    }
                    .padding()
                    .buttonStyle(.plain)
                    .background(.accent.opacity(0.2))
                    .cornerRadius(.medium)
                    .padding()
                }
            }
        }
        .onChange(of: viewModel.state) { _, newState in
            switch newState {
            case .loading:
                dialogManager.showDialog(allowPop: false) {
                    LoaderView()
                }
            case .failure(let error):
                dialogManager.showDialog {
                    VStack(alignment: .center, spacing: 8) {
                        ErrorView(error: error)
                        Button("OK") {
                            dialogManager.hideDialog()
                        }
                    }
                }
            default:
                dialogManager.hideDialog()
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Workout" : "New Workout")
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete") { viewModel.delete() { dismissAll() } }
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { viewModel.save() { dismiss() } }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
}


#Preview("New") {
    NavigationView {
        WorkoutPlanFormView(onSave: { workout in
            print("save form")
        })
    }
    .environmentObject(DialogManager())
}

#Preview("Edit") {
    NavigationView {
        WorkoutPlanFormView(
            workoutPlan: _previewWorkoutPlans[0],
            onSave: { workoutPlan in
                DispatchQueue.main.async {
                    print("save form")
                }
            },
            onDelete: { workoutPlan in
                DispatchQueue.main.async {
                    print("del form")
                }
            }
        )
    }
    .environmentObject(DialogManager())
}
