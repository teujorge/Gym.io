//
//  WorkoutFormView.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/5/24.
//

import SwiftUI

struct WorkoutFormView: View {
    let workout: Workout?
    let onSave: (Workout) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var exercises = [Exercise]()
    
    init(workout: Workout?, onSave: @escaping (Workout) -> Void) {
        self.workout = workout
        self.onSave = onSave
        
        if let workout = workout {
            title = workout.title
            description = workout.description ?? ""
            exercises = workout.exercises
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Exercises")) {
                    ForEach(exercises, id: \.id) { exercise in
                        Text(exercise.name)
                    }
                }
                
                Button(action: {}) {
                    Text("Add Exercise")
                }
            }
            .navigationTitle("New Workout")
            .navigationBarItems(trailing: Button("Save") {
                let newWorkout = Workout(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    exercises: exercises
                )
                onSave(newWorkout)
            })
        }
    }
}

#Preview {
    WorkoutFormView(workout: _previewWorkouts[0], onSave: { workout in
        print(workout)
    })
}
