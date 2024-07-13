//
//  SetDetailsView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

struct SetDetailsView: View {
    @ObservedObject var viewModel: SetDetailsViewModel
    
    init(exercise: Exercise, autoSave: Bool = true) {
        viewModel = SetDetailsViewModel(exercise: exercise, autoSave: autoSave)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())],
                alignment: .center
            ) {
                headerView
                setsList
                    .transition(.move(edge: .bottom))
            }
            .toolbar { ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }}
            
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
                .buttonStyle(PlainButtonStyle())
                LoaderView(size: 25, weight: .ultraLight, state: viewModel.state)
            }
            .padding(.horizontal)
        }
        .animation(.easeInOut, value: viewModel.exercise.sets.count)
    }
    
    private var setsList: some View {
        ForEach($viewModel.exercise.sets) { $exerciseSet in
            GridRow(alignment: .center) {
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
                HStack {
                    Button(action: { viewModel.deleteSet(exerciseSet.id) }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Toggle("", isOn: .constant(false))
                        .toggleStyle(.switch)
                }
            }
        }
    }
    
    private var headerView: some View {
        GridRow(alignment: .center) {
            VStack {
                Image(systemName: "number")
                    .fontWeight(.semibold)
                Text("Set")
                    .font(.caption2)
            }
            if viewModel.exercise.isRepBased {
                VStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .fontWeight(.semibold)
                    Text("Reps")
                        .font(.caption2)
                }
                VStack {
                    Image(systemName: "scalemass")
                        .fontWeight(.semibold)
                    Text("Kg")
                        .font(.caption2)
                }
            } else {
                VStack {
                    Image(systemName: "timer")
                        .fontWeight(.semibold)
                    Text("Sec")
                        .font(.caption2)
                }
                VStack {
                    Image(systemName: "flame")
                        .fontWeight(.semibold)
                    Text("Intensity")
                        .font(.caption2)
                }
            }
            VStack {
                Image(systemName: "wand.and.rays")
                    .fontWeight(.semibold)
                Text("Act")
                    .font(.caption2)
            }
        }
        .frame(minHeight: 40)
    }
}

#Preview {
    SetDetailsView(exercise: _previewExercises[1], autoSave: false)
}
