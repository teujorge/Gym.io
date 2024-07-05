//
//  WorkoutsView.swift
//  Gym.io
//
//  Created by Davi Guimell on 05/07/24.
//

import SwiftUI

struct WorkoutsView: View {
    let workouts: [Workout]
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/)
                    {
                        HStack{
                            
                            Button(action: {}) {
                                Text("New Exercise")
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(20)
                            
                            
                            Button(action: {}) {
                                Text("Search")
                                Image(systemName: "questionmark")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(20)
                        }
                        
                        
                    }
                    
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutView(workout: workout)) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(workout.title)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Image(systemName: "dumbbell.fill")
                                        .foregroundColor(.blue)
                                    
                                    Text("Exercises: \(workout.exercises.count)")
                                        .foregroundColor(.secondary)
                                }
                                
                                if !workout.description.isEmpty {
                                    Text(workout.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(color: Color(.black).opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Workouts")
        }
    }
}

#Preview {
    WorkoutsView(workouts: [
        Workout(title: "Ricardo's workout", description: "", exercises: [ExerciseRepBased(name: "pull up", sets: 4, reps: 12, weight: 14)]),
        Workout(title: "Davi's workout", description: "A challenging workout to test your limits.", exercises: exercises)
    ])
}

