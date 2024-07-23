//
//  SetDetailsView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

struct SetDetailsView: View {
    @StateObject var viewModel: SetDetailsViewModel
    
    private var showCheckColumn: Bool {
        return !viewModel.isPlan && viewModel.isEditable
    }
    
    private var gridItems: [GridItem] {
        showCheckColumn
        ? [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        : [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    init(
        details: SetDetails,
        isEditable: Bool,
        isPlan: Bool,
        autoSave: Bool,
        onDetailsChanged: ((SetDetails) -> Void)? = nil,
        onDebounceTriggered: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: SetDetailsViewModel(
            details: details,
            isEditable: isEditable,
            isPlan: isPlan,
            autoSave: autoSave,
            onDetailsChanged: onDetailsChanged,
            onDebounceTriggered: onDebounceTriggered
        ))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 16) {
                if viewModel.isEditable && viewModel.onDetailsChanged != nil {
                    HStack {
                        Button(action: { viewModel.isShowingRestTimerOverlay.toggle() }) {
                            Text(viewModel.formatSeconds(viewModel.details.restTime))
                            Image(systemName: "stopwatch")
                                .foregroundColor(.accent)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    Picker("Type", selection: $viewModel.details.isRepBased.animation()) {
                        Text("Rep Based").tag(true)
                        Text("Time Based").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom)
                    .padding(.horizontal)
                }
                
                headerView
                setsList
                
                if viewModel.isEditable && viewModel.onDetailsChanged != nil {
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
            }
            .animation(.easeInOut, value: viewModel.details.sets)
            
            if viewModel.isShowingRestTimerOverlay {
                restTimeOverlay
                    .animation(.easeInOut, value: viewModel.isShowingRestTimerOverlay)
            }
        }
    }
    
    private var setsList: some View {
        List {
            ForEach(viewModel.details.sets.indices, id: \.self) { index in
                ExerciseSetView(
                    exerciseSet: viewModel.details.sets[index],
                    gridItems: gridItems,
                    isEditable: viewModel.isEditable,
                    isRepBased: viewModel.details.isRepBased,
                    index: index,
                    toggleSetCompletion: showCheckColumn ? viewModel.toggleSetCompletion : nil
                )
                .listRowInsets(EdgeInsets(
                    top: viewModel.rowInsets / 2,
                    leading: 0,
                    bottom: viewModel.rowInsets / 2,
                    trailing: 0
                ))
                .frame(minHeight: viewModel.rowHeight)
                .swipeActions {
                    if viewModel.isEditable {
                        Button(role: .destructive, action: {
                            viewModel.deleteSet(index: index)
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
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
        .onChange(of: viewModel.details.sets.count) { oldCount, newCount in
            withAnimation {
                viewModel.listHeight = Double(newCount) * (viewModel.rowHeight + viewModel.rowInsets)
            }
        }
    }
    
    private var headerView: some View {
        LazyVGrid(columns: gridItems, alignment: .center) {
            Text("Set")
            if viewModel.details.isRepBased {
                Text("Reps")
                Text("Kg")
                
            } else {
                Text("Sec")
                Text("Intensity")
            }
            if showCheckColumn {
                Image(systemName: "checkmark")
            }
        }
        .fontWeight(.medium)
    }
    
    private var restTimeOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.isShowingRestTimerOverlay = false
                }
            
            VStack {
                Text("Rest Time")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                TimerView(minutes: $viewModel.restTimeMinutes, seconds: $viewModel.restTimeSeconds)
                    .padding(.horizontal)
                
                Button("Done") {
                    viewModel.isShowingRestTimerOverlay = false
                }
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(.large)
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
    }
}

private struct ExerciseSetView: View {
    @ObservedObject var exerciseSet: SetDetail
    let gridItems: [GridItem]
    let isEditable: Bool
    let isRepBased: Bool
    let index: Int
    let toggleSetCompletion: ((Int) -> Void)?
    
    private var rowColor: Color? {
        if exerciseSet.completedAt != nil {
            return .green.opacity(0.7)
        }
        if index % 2 == 0 {
            return .gray.opacity(0.12)
        } else {
            return .gray.opacity(0.18)
        }
    }
    
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
                    Picker("", selection: $exerciseSet.intensity) {
                        ForEach(Intensity.allCases, id: \.self) { intensity in
                            Text(intensity.rawValue.first.map(String.init) ?? "")
                                .tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                } else {
                    Text("\(exerciseSet.duration)")
                    Text(exerciseSet.intensity.rawValue.capitalized(with: .current))
                        .font(.callout)
                }
            }
            if let toggle = toggleSetCompletion {
                Button(action: { toggle(index) }) {
                    Image(systemName: exerciseSet.completedAt == nil ? "square" : "checkmark.square")
                }
                .transition(.opacity)
            }
        }
        .listRowBackground(rowColor)
    }
}


#Preview {
    NavigationView {
        ScrollView {
            Section {
                SetDetailsView(
                    details: SetDetails(
                        exerciseId: "",
                        isRepBased: true,
                        restTime: 30,
                        sets: [
                            SetDetail(
                                id: "1",
                                reps: 10,
                                weight: 50,
                                duration: 0,
                                intensity: .high,
                                completedAt: nil
                            ),
                            SetDetail(
                                id: "2",
                                reps: 10,
                                weight: 50,
                                duration: 0,
                                intensity: .medium,
                                completedAt: nil
                            )
                        ]
                    ),
                    isEditable: true,
                    isPlan: false,
                    autoSave: false
                )
            }
        }
    }
    .navigationTitle("SetDetailsPreview")
}

