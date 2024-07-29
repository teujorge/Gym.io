//
//  SummaryChartView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI
#if canImport(Charts)
#if swift(>=5.10)
import Charts
#endif
#endif

enum SummaryRange: String, CaseIterable, Identifiable {
    case past6Months = "6 Months"
    case past3Months = "3 Months"
    case pastMonth = "1 Month"
    
    var id: String { self.rawValue }
}

enum SummaryType: String, CaseIterable, Identifiable {
    case duration = "Duration"
    case weight = "Weight"
    case reps = "Reps"
    
    var id: String { self.rawValue }
}

struct DataPoint: Identifiable {
    let id = UUID()
    var date: Date
    var duration: Int // Seconds
    var volume: Int // Kg
    var reps: Int
}

struct SummaryChartView: View {
    
    @EnvironmentObject var currentUser: User
    @State private var range: SummaryRange = .pastMonth
    @State private var type: SummaryType = .duration
    
    var filteredData: [DataPoint] {
        var allData: [DataPoint] = []
        currentUser.workouts.forEach { workout in
            guard let completedAt = workout.completedAt else { return }
            
            let duration = Int(workout.updatedAt.timeIntervalSince(workout.createdAt))
            let dataPoint = DataPoint(
                date: completedAt,
                duration: duration,
                volume: calculateVolume(for: workout),
                reps: workout.exercises.reduce(0) { total, exercise in
                    total + exercise.sets.reduce(0) { setTotal, set in
                        setTotal + set.reps
                    }
                }
            )
            allData.append(dataPoint)
            
        }
        
        let endDate = Date()
        let startDate: Date
        
        switch range {
        case .pastMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        case .past3Months:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
        case .past6Months:
            startDate = Calendar.current.date(byAdding: .month, value: -6, to: endDate)!
        }
        
        return allData.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    var summaryString: String {
        switch type {
        case .duration:
            let totalDurationInSeconds = filteredData.reduce(0) { $0 + $1.duration }
            let totalDurationInHours = totalDurationInSeconds / 3600
            return "\(totalDurationInHours) Hours"
        case .weight:
            return "\(filteredData.reduce(0) { $0 + $1.volume }) Kg Lifted"
        case .reps:
            return "\(filteredData.reduce(0) { $0 + $1.reps }) Reps"
        }
    }
    
    private func daysBetweenDates() -> Int {
        guard let minDate = filteredData.map({ $0.date }).min(),
              let maxDate = filteredData.map({ $0.date }).max() else {
            return 1 // Default to avoid division by zero
        }
        let components = Calendar.current.dateComponents([.day], from: minDate, to: maxDate)
        return components.day ?? 1 // Return the number of days, default to 1 if nil
    }
    
    var body: some View {
        VStack {
#if canImport(Charts)
#if swift(>=5.10)
            
            Picker("Select Summary Type", selection: $type.animation()) {
                ForEach(SummaryType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            HStack(alignment: .bottom) {
                Text(summaryString)
                    .fontWeight(.semibold)
                Text("\(range == .pastMonth ? "this month" : "these past \(range.rawValue.lowercased())")")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
            }
            
            Chart {
                ForEach(filteredData, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value(type.rawValue, {
                            switch type {
                            case .duration:
                                return Double(item.duration) / 3600 // Convert seconds to hours directly here
                            case .weight:
                                return Double(item.volume) // Directly use the volume
                            case .reps:
                                return Double(item.reps) // Directly use the reps
                            }
                        }())
                    )
                    .foregroundStyle(Color.accent)
                }
            }
            
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                let totalDays = daysBetweenDates()
                let tickInterval = max(1, totalDays / 3)
                AxisMarks(values: .stride(by: .day, count: tickInterval)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            
            Picker("Select Summary Range", selection: $range.animation()) {
                ForEach(SummaryRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
#endif
#endif
        }
    }
    
}


#Preview {
    SummaryChartView()
        .environmentObject(User(
            username: "teujorge",
            name: "Matheus Jorge",
            workouts: generateWorkouts(count: 100)
        ))
        .padding()
        .frame(maxHeight: 500)
}

func generateWorkouts(count: Int) -> [Workout] {
    var workouts: [Workout] = []
    
    for i in 1...count {
        let completedAt = randomPastDate()
        let durationInSeconds = Double.random(in: 3600 ..< 10000)
        let createdAt = completedAt.addingTimeInterval(-durationInSeconds)
        let updatedAt = completedAt
        
        let workout = Workout(
            name: "Workout \(i)",
            notes: "This is a note for workout \(i)",
            index: i,
            completedAt: completedAt,
            planId: UUID().uuidString,
            ownerId: UUID().uuidString,
            exercises: generateExercises(count: Int.random(in: 1...10)),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        workouts.append(workout)
    }
    
    return workouts
}

func generateExercises(count: Int) -> [Exercise] {
    var exercises: [Exercise] = []
    
    for i in 1...count {
        let exercise = Exercise(
            name: "Exercise \(i)",
            isRepBased: Bool.random(),
            equipment: .none,
            muscleGroups: [.chest],
            sets: generateExerciseSets(count: Int.random(in: 1...8))
        )
        exercises.append(exercise)
    }
    
    return exercises
}

func generateExerciseSets(count: Int) -> [ExerciseSet] {
    var sets: [ExerciseSet] = []
    
    for i in 1...count {
        let set = ExerciseSet(
            reps: Int.random(in: 5...15),
            weight: Int.random(in: 20...100),
            duration: Int.random(in: 30...120),
            intensity: Bool.random() ? .low : .high,
            index: i
        )
        sets.append(set)
    }
    
    return sets
}

func randomPastDate() -> Date {
    let daysAgo = Int.random(in: 0...365)
    return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
}

