//
//  SummaryChartView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

// import Charts
import SwiftUI
import Foundation


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

struct SummaryChartView: View {
    
    struct DataPoint: Identifiable {
        let id = UUID()
        var date: Date
        var duration: Int // Seconds
        var volume: Int // Kg
        var reps: Int
    }
    
    @State private var range: SummaryRange = .pastMonth
    @State private var type: SummaryType = .duration
    @State private var allData = [DataPoint]()
    
    var filteredData: [DataPoint] {
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
            return "\(filteredData.reduce(0) { $0 + $1.duration } / 3600) Hours"
        case .weight:
            return "\(filteredData.reduce(0) { $0 + $1.volume }) Kg Lifted"
        case .reps:
            return "\(filteredData.reduce(0) { $0 + $1.reps }) Reps"
        }
    }
    
    private func loadData() {
        let endDate = Date(timeIntervalSince1970: 1720195200) // July 5, 2024
        let calendar = Calendar.current
        
        // Generate data for past 6 months
        for i in 0..<20 {
            if let date = calendar.date(byAdding: .day, value: -9 * i, to: endDate) {
                let randDuration = Int.random(in: 3600...10800)
                let randVolume = Int.random(in: 1...100)
                let randReps = Int.random(in: 1...10)
                allData.append(DataPoint(date: date, duration: randDuration, volume: randVolume, reps: randReps))
            }
        }
        
        // Sort the data by date because we added them in reverse order
        allData = allData.sorted(by: { $0.date < $1.date })
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
            
//            Chart {
//                ForEach(filteredData, id: \.date) { item in
//                    BarMark(
//                        x: .value("Date", item.date),
//                        y: .value(type.rawValue, {
//                            switch type {
//                            case .duration:
//                                return Double(item.duration) / 3600 // Convert seconds to hours directly here
//                            case .weight:
//                                return Double(item.volume) // Directly use the volume
//                            case .reps:
//                                return Double(item.reps) // Directly use the reps
//                            }
//                        }())
//                    )
//                    .foregroundStyle(Color.accent)
//                }
//            }
            
//            .chartYAxis {
//                AxisMarks(position: .leading) {
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel()
//                }
//            }
//            .chartXAxis {
//                let totalDays = daysBetweenDates()
//                let tickInterval = max(1, totalDays / 3)
//                AxisMarks(values: .stride(by: .day, count: tickInterval)) {
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel(format: .dateTime.day().month())
//                }
//            }

            Picker("Select Summary Range", selection: $range.animation()) {
                ForEach(SummaryRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
        }
        .onAppear { loadData() }
    }
}

extension Button {
    func buttonStyle(inactive: Bool = false) -> some View {
        self
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(inactive ? Color.gray.opacity(0.2) : Color.accent)
            .foregroundColor(inactive ? .primary : .white)
            .cornerRadius(10)
    }
}


#Preview {
    SummaryChartView()
        .padding()
        .frame(maxHeight: 500)
}
