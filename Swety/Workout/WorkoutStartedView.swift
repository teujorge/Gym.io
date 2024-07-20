//
//  WorkoutStartedView.swift
//  Swety
//
//  Created by Davi Guimell on 08/07/24.
//

import SwiftUI

struct WorkoutStartedView: View {
    @Environment (\.presentationMode) var presentationMode
    @StateObject var viewModel: WorkoutStartedViewModel
    
    init(workoutPlan: WorkoutPlan){
        _viewModel = StateObject(wrappedValue: WorkoutStartedViewModel(workoutPlan: workoutPlan))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                ForEach($viewModel.workout.exercises, id: \.id) { $exercise in
                    ExerciseCardView(exercise: $exercise, viewModel: viewModel)
                }
            }
            .padding()
        }
        .onAppear(perform: viewModel.initiateWorkout)
        .onDisappear(perform: viewModel.stopWorkoutTimer)
        .navigationTitle(viewModel.workout.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(formatTime(viewModel.workoutCounter))
                    .foregroundColor(.accent)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.stopWorkoutTimer()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Complete")
                        .padding(10)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(.medium)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
}
private struct ExerciseCardView: View {
    @Binding var exercise: Exercise
    @ObservedObject var viewModel: WorkoutStartedViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.accent)
            
            Text("Rest timer: \(formatTime(viewModel.restCounter))")
                .font(.caption)
                .foregroundColor(.accent)
            
            // TODO: fix
//            SetDetailsView(
//                sets: exercise.sets.map { SetDetails(exerciseSet: $0) },
//                isPlan: false,
//                isRepBased: exercise.isRepBased,
//                autoSave: true,
//                onSetsChanged: { setDetails in
//                    exercise.sets = setDetails.enumerated().map { (index, setDetail) in
//                        setDetail.toSet(index: index)
//                    }
//                }
//                onDebounceTriggered: {
//                    print("onDebounceTriggered")
//                }
//            )
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(.medium)
    }
}

#Preview {
    _previewStartedWorkoutView()
}

private struct _previewStartedWorkoutView: View {
    @State private var workoutPlan: WorkoutPlan
    
    init() {
        let data = dataString.data(using: .utf8)!
        let decodedResponse = try? JSONDecoder().decode([String: WorkoutPlan].self, from: data)
        self._workoutPlan = State(initialValue: decodedResponse?["data"] ?? _previewWorkoutPlans[1])
    }
    
    var body: some View {
        NavigationView {
            WorkoutStartedView(workoutPlan: workoutPlan)
        }
    }
}

private let dataString = """
{"data":{"createdAt":"2024-07-15T21:35:13.437Z","updatedAt":"2024-07-15T21:35:13.437Z","id":"6484f4e1-6b1a-4975-baf9-5de8cf70f56d","ownerId":"000739.b5fe4b10f0654ffcb1b9c5109c11887c.1710","title":"Fist workout ","notes":"Hehehe Coolio ","completedAt":null,"exercises":[{"createdAt":"2024-07-11T04:46:48.000Z","updatedAt":"2024-07-11T04:46:48.000Z","id":"67120c72-e0c7-44e8-9f3d-86a645e0ec1b","workoutId":"6484f4e1-6b1a-4975-baf9-5de8cf70f56d","index":1,"name":"Push ups","imageName":null,"notes":null,"completedAt":null,"isRepBased":true,"restDuration":90,"sets":[{"createdAt":"2024-07-12T19:13:42.000Z","updatedAt":"2024-07-15T19:48:54.000Z","id":"ecf2dd4b-129a-4b64-a151-4a185079c542","exerciseId":"67120c72-e0c7-44e8-9f3d-86a645e0ec1b","index":1,"reps":10,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-12T19:13:43.000Z","updatedAt":"2024-07-15T19:48:55.000Z","id":"e41bdae0-d712-4ada-aad4-6b9d64fb90e8","exerciseId":"67120c72-e0c7-44e8-9f3d-86a645e0ec1b","index":2,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-12T19:13:44.000Z","updatedAt":"2024-07-15T19:48:54.000Z","id":"33d63a4d-4465-4c19-a2da-95655d344ead","exerciseId":"67120c72-e0c7-44e8-9f3d-86a645e0ec1b","index":3,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null}]},{"createdAt":"2024-07-11T04:46:59.000Z","updatedAt":"2024-07-11T04:46:59.000Z","id":"8461e05a-af2a-4821-8df1-062281397949","workoutId":"6484f4e1-6b1a-4975-baf9-5de8cf70f56d","index":1,"name":"Jumping jacks","imageName":null,"notes":null,"completedAt":null,"isRepBased":false,"restDuration":90,"sets":[{"createdAt":"2024-07-11T18:08:26.000Z","updatedAt":"2024-07-11T18:08:26.000Z","id":"ab7b661c-2b4d-4fe7-b843-b5decdaab682","exerciseId":"8461e05a-af2a-4821-8df1-062281397949","index":1,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T18:17:42.000Z","updatedAt":"2024-07-11T18:17:42.000Z","id":"a1858418-d930-4c69-8faa-74ec48544845","exerciseId":"8461e05a-af2a-4821-8df1-062281397949","index":2,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T20:29:17.000Z","updatedAt":"2024-07-11T20:29:17.000Z","id":"d4574b34-0769-44ca-b466-4af957738611","exerciseId":"8461e05a-af2a-4821-8df1-062281397949","index":3,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T20:29:18.000Z","updatedAt":"2024-07-11T20:29:18.000Z","id":"ac4b74da-cc8e-4da4-97ef-d4bb3dc5dd2b","exerciseId":"8461e05a-af2a-4821-8df1-062281397949","index":4,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null}]},{"createdAt":"2024-07-11T04:47:16.000Z","updatedAt":"2024-07-11T04:47:16.000Z","id":"f761c1db-0c4a-4d43-ba11-130412620828","workoutId":"6484f4e1-6b1a-4975-baf9-5de8cf70f56d","index":1,"name":"Tennis","imageName":null,"notes":null,"completedAt":null,"isRepBased":false,"restDuration":90,"sets":[{"createdAt":"2024-07-11T20:29:20.000Z","updatedAt":"2024-07-12T17:41:50.000Z","id":"faf15f9b-7a80-4dbd-9b5b-fece75cd6744","exerciseId":"f761c1db-0c4a-4d43-ba11-130412620828","index":1,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T20:29:21.000Z","updatedAt":"2024-07-12T17:41:50.000Z","id":"92fd003c-b5e5-4074-b733-4fbcf25acdb6","exerciseId":"f761c1db-0c4a-4d43-ba11-130412620828","index":2,"reps":0,"weight":0,"duration":0,"intensity":"HIGH","completedAt":null},{"createdAt":"2024-07-15T15:45:20.000Z","updatedAt":"2024-07-15T15:45:20.000Z","id":"62db8391-d296-468d-a4ee-8b25ddf1934c","exerciseId":"f761c1db-0c4a-4d43-ba11-130412620828","index":3,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-15T15:45:21.000Z","updatedAt":"2024-07-15T15:45:21.000Z","id":"5dae694a-694c-41ca-a627-cd23472adf04","exerciseId":"f761c1db-0c4a-4d43-ba11-130412620828","index":4,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null}]},{"createdAt":"2024-07-11T04:47:27.000Z","updatedAt":"2024-07-11T04:47:27.000Z","id":"4fbf65bd-694f-4369-92ab-19f8d8475963","workoutId":"6484f4e1-6b1a-4975-baf9-5de8cf70f56d","index":1,"name":"Deadlift","imageName":null,"notes":null,"completedAt":null,"isRepBased":true,"restDuration":90,"sets":[{"createdAt":"2024-07-11T04:47:33.000Z","updatedAt":"2024-07-12T16:12:26.000Z","id":"ec601610-5c1e-4e7c-a9f1-4cc4904620cd","exerciseId":"4fbf65bd-694f-4369-92ab-19f8d8475963","index":0,"reps":5,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T20:01:39.000Z","updatedAt":"2024-07-11T20:01:39.000Z","id":"aaf0fbfd-8b62-4df7-8644-ec8ff4f481e3","exerciseId":"4fbf65bd-694f-4369-92ab-19f8d8475963","index":2,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T20:01:40.000Z","updatedAt":"2024-07-11T20:01:40.000Z","id":"91d71e33-4fa4-4a99-b4c5-8dd8390689ba","exerciseId":"4fbf65bd-694f-4369-92ab-19f8d8475963","index":3,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-11T20:01:40.000Z","updatedAt":"2024-07-11T20:01:40.000Z","id":"810cffde-b66c-49aa-adc2-af3218930579","exerciseId":"4fbf65bd-694f-4369-92ab-19f8d8475963","index":4,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null},{"createdAt":"2024-07-15T15:45:18.000Z","updatedAt":"2024-07-15T15:45:18.000Z","id":"3b009414-9647-41a1-abd2-d949914ff0ad","exerciseId":"4fbf65bd-694f-4369-92ab-19f8d8475963","index":5,"reps":0,"weight":0,"duration":0,"intensity":"MEDIUM","completedAt":null}]}]}}
"""
