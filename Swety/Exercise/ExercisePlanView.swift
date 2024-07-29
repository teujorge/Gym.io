//
//  ExerciseView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/4/24.
//

import SwiftUI

struct ExercisePlanView: View {
    @StateObject var exercisePlan: ExercisePlan
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let image = exercisePlan.image {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.all, 24)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(.medium)
                        .padding()
                }
                
                if let instructions = exercisePlan.notes {
                    VStack(alignment: .leading) {
                        Text("Instructions")
                            .font(.headline)
                        Text(instructions)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                ExerciseHistory(exerciseName: exercisePlan.name)
            }
        }
        .navigationTitle(exercisePlan.name)
    }
    
}

struct ExerciseHistory: View {
    let exerciseName: String // TODO: should be ID
    
    @State var history: [Exercise] = []
    
    var totalWeightLifted: Int {
        history.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                if set.completedAt != nil {
                   return setTotal + set.reps * set.weight
                } else {
                    return setTotal
                }
            }
        }
    }
    
    var totalDuration: Int {
        history.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                if set.completedAt != nil {
                    return setTotal + set.duration
                } else {
                    return setTotal
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
            ForEach(history, id: \.id) { exercise in
                VStack {
                    if exercise.isRepBased {
                        Text("Weight: \(totalWeightLifted) kg")
                    } else {
                        Text("Duration: \(totalDuration) seconds")
                    }
                    Text(exercise.completedAt?.formatted(date: .abbreviated, time: .omitted) ?? "No Date")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
        }
        .padding()
        .opacity(history.isEmpty ? 0 : 1)
        .onAppear(perform: loadHistory)
    }
    
    func loadHistory() {
        Task {
            if let history = await fetchHistory() {
                self.history = history
            }
        }
    }
    
    private func fetchHistory() async -> [Exercise]? {
        
        let result: HTTPResponse<[Exercise]> = await sendRequest(
            endpoint: "/exercises/history",
            queryItems: [
                URLQueryItem(name: "name", value: exerciseName),
                URLQueryItem(name: "ownerId", value: currentUserId)
            ],
            method: .GET
        )
        
        switch result {
        case .success(let exercises):
            return exercises
        case .failure(let error):
            print(error)
            return nil
        }
        
    }
}

#Preview {
    NavigationView {
        ExercisePlanView(
            exercisePlan: _previewExercisePlans[0]
        )
    }
}
