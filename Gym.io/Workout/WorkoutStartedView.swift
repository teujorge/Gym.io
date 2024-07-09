//
//  WorkoutStartedView.swift
//  Gym.io
//
//  Created by Davi Guimell on 08/07/24.
//

import SwiftUI
import Combine

struct WorkoutStartedView: View {
    
    let workout:Workout
    
    @State private var counter = 0
    @State private var timerCancellable: Cancellable? = nil
    
    private var formattedTime: String {
        let minutes = counter / 60
        let seconds = counter % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                
                ForEach(workout.exercises, id: \.id) { exercise in
                    VStack(alignment: .leading) {
                        
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        LazyVGrid(columns: detailColumns(for: exercise)) {
                            Text("sets")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if exercise.reps != nil {
                                Text("reps")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            if exercise.weight != nil {
                                Text("weight")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            if exercise.duration != nil {
                                Text("duration")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }

                            ForEach(0..<exercise.sets, id: \.self) { setIndex in
                                Text("\(setIndex + 1)")
                                    .foregroundColor(.secondary)

                                if let reps = exercise.reps {
                                    Text("\(reps)")
                                        .foregroundColor(.secondary)
                                }

                                if let weight = exercise.weight {
                                    Text("\(weight) kg")
                                        .foregroundColor(.secondary)
                                }

                                if let duration = exercise.duration {
                                    Text("\(duration) s")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        HStack() {
                            Spacer()
                            Button(action: { }) {
                                Text("New set")
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth:.infinity)
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
        .navigationTitle(workout.title)
        .navigationBarItems(trailing: Text(formattedTime).foregroundColor(.blue))
    }
    
    private func detailColumns(for exercise: Exercise) -> [GridItem] {
        if exercise.reps != nil && exercise.weight != nil {
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

