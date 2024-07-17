//
//  SetDetailsView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

struct SetDetailsView: View {
    @StateObject var viewModel: SetDetailsViewModel
    
    private var gridItems: [GridItem] {
        viewModel.onSetComplete == nil
        ? [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        : [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    init(exercise: Exercise, autoSave: Bool = true, onSetComplete: ((ExerciseSet) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: SetDetailsViewModel(exercise: exercise, autoSave: autoSave, onSetComplete: onSetComplete))
    }
    
    var body: some View {
        VStack(alignment: .center) {
            headerView
            Divider()
            setsList
            Button(action: viewModel.addSet) {
                HStack {
                    Text("Add set")
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accent)
                }
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(Color.accent.opacity(0.2))
                .cornerRadius(20)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .transition(.move(edge: .bottom))
        }
        .animation(.easeInOut, value: viewModel.exercise.sets.count)
    }
    
    private var setsList: some View {
        List($viewModel.exercise.sets) { $exerciseSet in
            LazyVGrid(columns: gridItems, alignment: .center) {
                Text("\(exerciseSet.index)")
                if viewModel.exercise.isRepBased {
                    TextField("Reps", value: $exerciseSet.reps, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    TextField("Weight", value: $exerciseSet.weight, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                } else {
                    TextField("Duration", value: $exerciseSet.duration, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    Picker("", selection: $exerciseSet.intensity) {
                        ForEach(Intensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue.first.map(String.init) ?? "")
                                .tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                if viewModel.onSetComplete != nil {
                    Button(action: { viewModel.toggleSetCompletion(exerciseSet.id) }) {
                        Image(systemName: exerciseSet.completedAt == nil ? "square" : "checkmark.square")
                    }
                    .transition(.opacity)
                }
            }
            .listRowInsets(EdgeInsets(
                top: viewModel.rowInsets / 2,
                leading: 0,
                bottom: viewModel.rowInsets / 2,
                trailing: 0
            ))
            .listRowBackground(exerciseSet.completedAt == nil ? nil : Color.green.opacity(0.7))
            .animation(.easeInOut, value: exerciseSet.completedAt)
            .frame(minHeight: viewModel.rowHeight)
            .swipeActions {
                Button(role: .destructive, action: {
                    viewModel.deleteSet(exerciseSet.id)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.plain)
        .frame(minHeight: viewModel.listHeight)
        .cornerRadius(10)
        .padding(0)
        .background(.clear)
        .transition(.move(edge: .bottom))
        .onChange(of: viewModel.exercise.sets.count) { oldCount, newCount in
            withAnimation {
                viewModel.listHeight = CGFloat(newCount) * (viewModel.rowHeight + viewModel.rowInsets)
            }
        }
    }
    
    private var headerView: some View {
        LazyVGrid(columns: gridItems, alignment: .center) {
            Text("Set")
            if viewModel.exercise.isRepBased {
                Text("Reps")
                Text("Kg")
                
            } else {
                Text("Sec")
                Text("Intensity")
            }
            if viewModel.onSetComplete != nil {
                Image(systemName: "checkmark")
            }
        }
        .fontWeight(.medium)
    }
}

#Preview {
    NavigationView {
        ScrollView {
            Section {
                SetDetailsView(exercise: _previewExercises[0], autoSave: false, onSetComplete: { exerciseSet in })
            }
        }
    }
    .navigationTitle("SetDetailsPreview")
}

