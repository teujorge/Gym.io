//
//  ExercisePlansView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/21/24.
//

import SwiftUI

struct ExercisePlansView: View {
    @State private var searchQuery = ""
     @State private var exercises: [ExercisePlan] = []
    
    var filteredExercises: [ExercisePlan] {
        if searchQuery.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredExercises) { exercise in
                    ExerciseRowView(exercise: exercise)
                }
            }
            .navigationBarTitle("Exercises")
            .navigationBarItems(trailing:
                Button(action: loadExercises) {
                    Text("Load")
                }
            )
            .searchable(text: $searchQuery)
            .onAppear(perform: loadExercises)
        }
    }
    
    func loadExercises() {
        Task {
            let response: HTTPResponse<[DefaultExercisePlan]> = await sendRequest(endpoint: "/exercises/defaults", method: .GET)
            switch response {
            case .success(let plans):
                DispatchQueue.main.async {
                    self.exercises = plans.map { $0.toExercisePlan() }
                }
            case .failure(let error):
                print("Failed to load exercises: \(error)")
            }
        }
    }
}

private struct ExerciseRowView: View {
    var exercise: ExercisePlan
    
    var body: some View {
        HStack {
            if let imageName = exercise.image, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                Text(exercise.notes ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ExercisePlansView()
}
