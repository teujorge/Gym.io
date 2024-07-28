//
//  WorkoutActivityHelpers.swift
//  Swety
//
//  Created by Matheus Jorge on 7/27/24.
//

import SwiftUI
import ActivityKit

var currentLiveActivity: Activity<WorkoutWidgetAttributes>? = nil

@MainActor
func startOrUpdateLiveActivity(with state: WorkoutState) {
    Task {
        let attributes = WorkoutWidgetAttributes(
            workoutName: state.workoutName
        )
        
        let contentState = WorkoutWidgetAttributes.ContentState(
            exercise: state.currentExercise,
            currentSetIndex: state.currentSetIndex,
            totalExercisesCount: state.totalExercisesCount
        )
        
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        if let currentActivity = currentLiveActivity {
            await currentActivity.update(content)
        } else {
            do {
                currentLiveActivity = try Activity<WorkoutWidgetAttributes>.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
            } catch {
                print("Failed to start activity: \(error)")
            }
        }
    }
}

//@MainActor
//func startWorkoutLiveActivity(
//    exerciseId: String,
//    workoutName: String,
//    totalExercisesCount: Int
//) {
//    Task {
//        guard let exercise = await fetchExercise(exerciseId: exerciseId) else {
//            return
//        }
//
//        let areActivitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
//        print(areActivitiesEnabled)
//
//        let attributes = WorkoutWidgetAttributes(
//            workoutName: workoutName
//        )
//
//        let initialContentState = WorkoutWidgetAttributes.ContentState(
//            exercise: exercise,
//            currentSetIndex: 0,
//            totalExercisesCount: totalExercisesCount
//        )
//
//        let initialContent = ActivityContent(state: initialContentState, staleDate: nil)
//
//        do {
//            currentLiveActivity = try Activity<WorkoutWidgetAttributes>.request(
//                attributes: attributes,
//                content: initialContent,
//                pushType: nil
//            )
//            print("Current activity started: \(currentLiveActivity.debugDescription)")
//        } catch {
//            print("Failed to start activity: \(error)")
//        }
//    }
//}
//
//@MainActor
//func refreshWorkoutLiveActivity(
//    exerciseId: String,
//    currentSetIndex: Int,
//    totalExercisesCount: Int
//) {
//    Task {
//        if let activity = currentLiveActivity {
//            let exerciseId = activity.content.state.exercise.id
//            guard let exercise = await fetchExercise(exerciseId: exerciseId) else {
//                return
//            }
//
//            let newContentState = WorkoutWidgetAttributes.ContentState(
//                exercise: exercise,
//                currentSetIndex: currentSetIndex,
//                totalExercisesCount: totalExercisesCount
//            )
//
//            let newContent = ActivityContent(state: newContentState, staleDate: nil)
//            await activity.update(newContent)
//        }
//    }
//}

@MainActor
func stopWorkoutLiveActivity() {
    Task {
        if let activity = currentLiveActivity {
            let finalContentState = activity.content.state // or create a new final state
            let finalContent = ActivityContent(state: finalContentState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            currentLiveActivity = nil
        }
    }
}

//func fetchExercise(exerciseId: String) async -> Exercise? {
//    let result: HTTPResponse<Exercise> = await sendRequest(
//        endpoint: "/exercises/history/\(exerciseId)",
//        method: .GET
//    )
//    switch result {
//    case .success(let fetchedWorkout):
//        return fetchedWorkout
//    case .failure(let error):
//        print("Failed to fetch workout: \(error)")
//    }
//
//    return nil
//}

class WorkoutState: ObservableObject {
    @Published var workoutName: String
    @Published var currentExercise: Exercise
    @Published var currentSetIndex: Int
    @Published var totalExercisesCount: Int
    @Published var workoutCounter: Int
    @Published var restCounter: Int
    
    init(
        workoutName: String,
        currentExercise: Exercise,
        currentSetIndex: Int,
        totalExercisesCount: Int,
        workoutCounter: Int,
        restCounter: Int
    ) {
        self.workoutName = workoutName
        self.currentExercise = currentExercise
        self.currentSetIndex = currentSetIndex
        self.totalExercisesCount = totalExercisesCount
        self.workoutCounter = workoutCounter
        self.restCounter = restCounter
    }
}
