//
//  SetDetailsView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

struct SetDetailsView: View {
    @StateObject var viewModel: SetDetailsViewModel
    
    private var gridItems: [GridItem] {
        viewModel.isPlan
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
    
    init(
        sets: [SetDetails],
        isEditable: Bool,
        isPlan: Bool,
        isRepBased: Bool,
        autoSave: Bool,
        onToggleIsRepBased: ((Bool) -> Void)? = nil,
        onSetsChanged: (([SetDetails]) -> Void)? = nil,
        onDebounceTriggered: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: SetDetailsViewModel(
            sets: sets,
            isEditable: isEditable,
            isPlan: isPlan,
            isRepBased: isRepBased,
            autoSave: autoSave,
            onToggleIsRepBased: onToggleIsRepBased,
            onSetsChanged: onSetsChanged,
            onDebounceTriggered: onDebounceTriggered
        ))
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Picker("Type", selection: $viewModel.isRepBased.animation()) {
                Text("Rep Based").tag(true)
                Text("Time Based").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            .padding(.horizontal)
            
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
                .padding(10)
                .background(Color.accent.opacity(0.2))
                .cornerRadius(.medium)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .transition(.move(edge: .bottom))
        }
        .animation(.easeInOut, value: viewModel.sets)
    }
    
    private var setsList: some View {
        List {
            ForEach(viewModel.sets.indices, id: \.self) { index in
                ExerciseSetView(
                    exerciseSet: viewModel.sets[index],
                    gridItems: gridItems,
                    isEditable: viewModel.isEditable,
                    isRepBased: viewModel.isRepBased,
                    index: index,
                    toggleSetCompletion: viewModel.isPlan ? nil : viewModel.toggleSetCompletion
                )
                .listRowInsets(EdgeInsets(
                    top: viewModel.rowInsets / 2,
                    leading: 0,
                    bottom: viewModel.rowInsets / 2,
                    trailing: 0
                ))
                .frame(minHeight: viewModel.rowHeight)
                .swipeActions {
                    Button(role: .destructive, action: {
                        viewModel.deleteSet(index: index)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .frame(minHeight: viewModel.listHeight)
        .cornerRadius(.medium)
        .padding(0)
        .background(.clear)
        .transition(.move(edge: .bottom))
        .onChange(of: viewModel.sets.count) { oldCount, newCount in
            withAnimation {
                viewModel.listHeight = Double(newCount) * (viewModel.rowHeight + viewModel.rowInsets)
            }
        }
    }
    
    private var headerView: some View {
        LazyVGrid(columns: gridItems, alignment: .center) {
            Text("Set")
            if viewModel.isRepBased {
                Text("Reps")
                Text("Kg")
                
            } else {
                Text("Sec")
                Text("Intensity")
            }
            if !viewModel.isPlan {
                Image(systemName: "checkmark")
            }
        }
        .fontWeight(.medium)
    }
}

private struct ExerciseSetView: View {
    @ObservedObject var exerciseSet: SetDetails
    let gridItems: [GridItem]
    let isEditable: Bool
    let isRepBased: Bool
    let index: Int
    let toggleSetCompletion: ((Int) -> Void)?
    
    var body: some View {
        LazyVGrid(columns: gridItems, alignment: .center) {
            Text("\(index + 1)")
            if isRepBased {
                if isEditable {
                    TextField("Reps", value: $exerciseSet.reps, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                    TextField("Weight", value: $exerciseSet.weight, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                } else {
                    Text("\(exerciseSet.reps)")
                    Text("\(exerciseSet.weight)")
                }
            } else {
                if isEditable {
                    TextField("Duration", value: $exerciseSet.duration, formatter: NumberFormatter())
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                } else {
                    Text("\(exerciseSet.duration)")
                }
                Picker("", selection: $exerciseSet.intensity) {
                    ForEach(Intensity.allCases, id: \.self) { intensity in
                        Text(intensity.rawValue.first.map(String.init) ?? "")
                            .tag(intensity)
                    }
                }
                .pickerStyle(.segmented)
            }
            if let toggle = toggleSetCompletion {
                Button(action: { toggle(index) }) {
                    Image(systemName: exerciseSet.completedAt == nil ? "square" : "checkmark.square")
                }
                .transition(.opacity)
            }
        }
        .listRowBackground(exerciseSet.completedAt == nil ? nil : Color.green.opacity(0.7))
    }
}


#Preview {
    NavigationView {
        ScrollView {
            Section {
                SetDetailsView(
                    sets: [
                        SetDetails(
                            id: "1",
                            reps: 10,
                            weight: 50,
                            duration: 0,
                            intensity: .low,
                            completedAt: nil
                        ),
                        SetDetails(
                            id: "2",
                            reps: 10,
                            weight: 50,
                            duration: 0,
                            intensity: .low,
                            completedAt: nil
                        )
                    ],
                    isEditable: true,
                    isPlan: false,
                    isRepBased: true,
                    autoSave: false
                )
            }
        }
    }
    .navigationTitle("SetDetailsPreview")
}

