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
                        SetDetailsView(viewModel: SetDetailsViewModel(exercise: exercise))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                HStack {
                    Button(action: stopTimer) {
                        Text("Complete workout")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: stopTimer) {
                        Text("discard workout")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
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
