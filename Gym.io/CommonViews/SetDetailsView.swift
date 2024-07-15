//
//  SetDetailsView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

struct SetDetailsView: View {
    @ObservedObject var viewModel: SetDetailsViewModel
    
    let rowHeight = 40.0
    
    private var gridItems: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    init(exercise: Exercise, autoSave: Bool = true) {
        viewModel = SetDetailsViewModel(exercise: exercise, autoSave: autoSave)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            LazyVGrid(columns: gridItems, alignment: .leading) {
                headerView
            }
            setsList
                .transition(.move(edge: .bottom))
            
            HStack {
                Button(action: viewModel.addSet) {
                    HStack {
                        Text("Add set")
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
                LoaderView(size: 25, weight: .ultraLight, state: viewModel.state)
            }
            .padding(.horizontal)
        }
        .animation(.easeInOut, value: viewModel.exercise.sets.count)
        .toolbar { ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }}
    }
    
    private var setsList: some View {
        List($viewModel.exercise.sets) { $exerciseSet in
            LazyVGrid(columns: gridItems, alignment: .leading) {
                Text("\(exerciseSet.index)")
                if viewModel.exercise.isRepBased {
                    TextField("Reps", value: $exerciseSet.reps, formatter: NumberFormatter())
//                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    TextField("Weight", value: $exerciseSet.weight, formatter: NumberFormatter())
//                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                } else {
                    TextField("Duration", value: $exerciseSet.duration, formatter: NumberFormatter())
//                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    Picker("", selection: $exerciseSet.intensity) {
                        ForEach(Intensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue.first.map(String.init) ?? "")
                                .tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .frame(minHeight: rowHeight)
            .swipeActions {
                Button(action: {
                    viewModel.deleteSet(exerciseSet.id)
                }) {
                    Label("Complete", systemImage: "checkmark")
                        .tint(.green)
                }
                Button(role: .destructive, action: {
                    viewModel.deleteSet(exerciseSet.id)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.plain)
        .frame(minHeight: (rowHeight + 22) * Double(viewModel.exercise.sets.count))
        .cornerRadius(10)
        .padding(0)
        .background(.clear)
    }
    
    private var headerView: some View {
        Group {
            Text("Set")
            if viewModel.exercise.isRepBased {
                Text("Reps")
                Text("Kg")
            } else {
                Text("Sec")
                Text("Intensity")
            }
        }
    }
}

#Preview {
    SetDetailsView(exercise: _previewExercises[1], autoSave: false)
}

