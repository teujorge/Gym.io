//
//  WorkoutsViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/10/24.
//

import SwiftUI

enum WorkoutFormViewState {
    case idle
    case operating
    case finished
    case error(String)
}

class WorkoutFormViewModel: ObservableObject {
    
    let isEditing: Bool
    var onSave: () -> Void
    var onDelete: () -> Void
    
    @Published var workout: Workout
    
    @Published var isPresentingExerciseForm = false
    @Published var selectedExercise: Exercise?
    @Published var state: WorkoutFormViewState = .idle
    
    @Published var titleText = "" {
        didSet {
            workout.title = titleText
        }
    }
    @Published var notesText = "" {
        didSet {
            workout.notes = notesText
        }
    }
    
    init(workout: Workout?, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        if let workout = workout {
            self.isEditing = true
            self.workout = workout
            self.titleText = workout.title
            self.notesText = workout.notes ?? ""
        } else {
            self.isEditing = false
            self.workout = Workout(ownerId: UserDefaults.standard.string(forKey: .userId) ?? "" ,title: "", notes: "", exercises: [])
        }
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    func addExercise() {
        selectedExercise = Exercise(index: 1, name: "", sets: [], isRepBased: true)
        isPresentingExerciseForm = true
    }
    
    func moveExercise(from source: IndexSet, to destination: Int) {
        workout.exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteExercise(at offsets: IndexSet) {
        workout.exercises.remove(atOffsets: offsets)
    }
    
    func editExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        isPresentingExerciseForm = true
    }
    
    func handleSaveExercise(_ updatedExercise: Exercise) {
        if let selectedExercise = selectedExercise {
            if let index = workout.exercises.firstIndex(where: { $0.id == selectedExercise.id }) {
                workout.exercises[index] = updatedExercise
            } else {
                workout.exercises.append(updatedExercise)
            }
        } else {
            workout.exercises.append(updatedExercise)
        }
        isPresentingExerciseForm = false
    }
    
    func handleDeleteExercise(_ exercise: Exercise) {
        if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
            workout.exercises.remove(at: index)
        }
        isPresentingExerciseForm = false
    }
    
    func save() {
        Task {
            if isEditing {
                print("TODO: PUT REQUEST")
                onSave()
            } else {
                let newWorkout = await createWorkout()
                if newWorkout == nil {
                    print("Failed to create workout")
                } else {
                    onSave()
                }
            }
        }
    }
    
    private func createWorkout() async -> Workout? {
        guard !workout.title.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide a title for your workout")
                self.state = .error("Please provide a title for your workout")
            }
            return nil
        }
        
        guard !workout.ownerId.isEmpty else {
            DispatchQueue.main.async {
                print("Please provide an owner ID for your workout")
                self.state = .error("Please provide an owner ID for your workout")
            }
            return nil
        }
        
        DispatchQueue.main.async {
            self.state = .operating
        }
        
        let url = URL(string: "https://gym-io-api.vercel.app/api/workouts")!
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(workout)
            print("Encoded JSON string: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                print("createWorkoutRaw: \(String(data: data, encoding: .utf8)!)")
                
                do {
                    let decodedResponse = try JSONDecoder().decode([String: Workout].self, from: data)
                    if let workout = decodedResponse["data"] {
                        print("Workout created: \(workout)")
                        DispatchQueue.main.async {
                            self.state = .finished
                        }
                        
                        return workout
                    } else {
                        print("Failed to find workout in decoded response")
                    }
                } catch let decodeError {
                    print("Failed to decode workout: \(decodeError)")
                    DispatchQueue.main.async {
                        self.state = .error(decodeError.localizedDescription)
                    }
                }
            } catch {
                print("Failed to create workout: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.state = .error(error.localizedDescription)
                }
            }
        } catch {
            print("Failed to encode Workout: \(error)")
        }
        
        return nil
    }
    
    func delete() {
        Task {
            let success = await handleDeleteWorkout()
            if success {
                onDelete()
            }
            else {
                print("Failed to delete workout")
            }
        }
    }
    
    private func handleDeleteWorkout() async -> Bool {
        DispatchQueue.main.async {
            self.state = .operating
        }
        
        let url = URL(string: "https://gym-io-api.vercel.app/api/workouts/\(workout.id)")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            DispatchQueue.main.async {
                self.state = .finished
            }
            return true
        } catch {
            print("Failed to delete workout: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
        }
        
        return false
    }
    
}
