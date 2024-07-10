//
//  WorkoutStartedView.swift
//  Gym.io
//
//  Created by Davi Guimell on 08/07/24.
//

import SwiftUI
import Combine

struct WorkoutStartedView: View {
    

    @State var workout: Workout
    @State private var counter = 0
    @State private var timerCancellable: AnyCancellable? = nil
    @State private var repsInputs: [UUID: [Int: String]] = [:]
    @State private var weightInputs: [UUID: [Int: String]] = [:]
    
    private var formattedTime: String {
        let minutes = counter / 60
        let seconds = counter % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                
                ForEach($workout.exercises, id: \.id) { $exercise in
                    VStack(alignment: .leading) {
                        
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        LazyVGrid(columns: detailColumns(for: exercise)) {
                            Text("sets")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if exercise.sets[0].reps != nil {
                                Text("reps")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            if exercise.sets[0].weight != nil {
                                Text("weight")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            if exercise.sets[0].duration != nil {
                                Text("duration")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            ForEach(0..<exercise.sets.count, id: \.self) { setIndex in
                                setsDetailsView(index: setIndex, set: exercise.sets[setIndex])
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: { }) {
                                Text("New set")
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(20)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Button(action: stopTimer) {
                    Text("Complete workout")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
        }
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
        .navigationTitle(workout.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(formattedTime)
                    .foregroundColor(.blue)
            }
        }
    }
    
    struct setsDetailsView: View {
        let index: Int
        let set: ExerciseSet
        
        var body: some View {
            Text("\(index + 1)")
                .foregroundColor(.secondary)
            
            if let reps = set.reps {
                Text("\(reps)")
                    .foregroundColor(.secondary)
            }
            
            if let weight = set.weight {
                Text("\(weight) kg")
                    .foregroundColor(.secondary)
            }
            
            if let duration = set.duration {
                Text("\(duration) s")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func detailColumns(for exercise: Exercise) -> [GridItem] {
         if exercise.sets[0].reps != nil && exercise.sets[0].weight != nil {
             return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
         } else {
             return [GridItem(.flexible()), GridItem(.flexible())]
         }
     }
    
    private func startTimer() {
        timerCancellable?.cancel()  // Cancel any existing timer
        counter = 0  // Reset the counter
        
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                counter += 1
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()  // Cancel the timer
        timerCancellable = nil  // Set the cancellable to nil
    }
    
}

#Preview {
    NavigationView {
        WorkoutStartedView(workout: _previewWorkouts[0])
    }
}
