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
    
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center, spacing: 20){
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                    
                    Text("Duration: ").fontWeight(.semibold)
                    + Text(formattedTime).foregroundColor(.blue)
                    Spacer()
                    Text("Weight:").fontWeight(.semibold)
                    Spacer()
                    Text("Sets:").fontWeight(.semibold)
                }
                .padding()
                
                ForEach(workout.exercises, id: \.id) { exercise in
                    VStack(alignment: .leading) {
                        
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        if let repBasedExercise = exercise as? ExerciseRepBased {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]) {
                                Text("sets")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("reps")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("lbs")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                ForEach(0..<repBasedExercise.sets, id: \.self) { setIndex in
                                    
                                    Text("\(setIndex + 1)")
                                        .foregroundColor(.secondary)
                                    
                                    
                                    Text("\(repBasedExercise.reps)")
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(repBasedExercise.weight)")
                                        .foregroundColor(.secondary)
                                    
                                }
                                
                            }
                        }
                        else if let timeBasedExercise = exercise as? ExerciseTimeBased {
                            HStack {
                                Text("Duration: \(timeBasedExercise.duration) seconds")
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        HStack(){
                            Spacer()
                            Button(action:{}){
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
                
                Button(action: {
                    stopTimer()
                }) {
                    Text("Comoplete workout")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .onAppear(perform: startTimer)
        }
        .padding()
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
    
    var formattedTime: String {
        let minutes = counter / 60
        let seconds = counter % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
}

#Preview {
    WorkoutStartedView(workout: _previewWorkouts[0])
}

