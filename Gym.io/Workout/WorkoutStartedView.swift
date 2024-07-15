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
            VStack(alignment: .center) {
                ForEach($workout.exercises, id: \.id) { $exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        SetDetailsView(exercise: exercise)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
        .navigationTitle(workout.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(formattedTime)
                    .foregroundColor(.blue)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: stopTimer) {
                    Text("Complete")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
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
