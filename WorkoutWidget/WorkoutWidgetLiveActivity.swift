//
//  WorkoutWidgetLiveActivity.swift
//  WorkoutWidget
//
//  Created by Matheus Jorge on 7/26/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

var currentLiveActivity: Activity<WorkoutWidgetAttributes>? = nil

@MainActor
func startWorkoutLiveActivity(
    exerciseId: String,
    workoutName: String,
    totalExercisesCount: Int
) {
    Task {
        guard let exercise = await fetchExercise(exerciseId: exerciseId) else {
            return
        }
        
        let areActivitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
        print(areActivitiesEnabled)
        
        let attributes = WorkoutWidgetAttributes(
            workoutName: workoutName
        )
        
        let initialContentState = WorkoutWidgetAttributes.ContentState(
            exercise: exercise,
            currentSetIndex: 0,
            totalExercisesCount: totalExercisesCount
        )
        
        let initialContent = ActivityContent(state: initialContentState, staleDate: nil)
        
        do {
            currentLiveActivity = try Activity<WorkoutWidgetAttributes>.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            print("Current activity started: \(currentLiveActivity.debugDescription)")
        } catch {
            print("Failed to start activity: \(error)")
        }
    }
}

@MainActor
func refreshWorkoutLiveActivity(
    exerciseId: String,
    currentSetIndex: Int,
    totalExercisesCount: Int
) {
    Task {
        if let activity = currentLiveActivity {
            let exerciseId = activity.content.state.exercise.id
            guard let exercise = await fetchExercise(exerciseId: exerciseId) else {
                return
            }
            
            let newContentState = WorkoutWidgetAttributes.ContentState(
                exercise: exercise,
                currentSetIndex: currentSetIndex,
                totalExercisesCount: totalExercisesCount
            )
            
            let newContent = ActivityContent(state: newContentState, staleDate: nil)
            await activity.update(newContent)
        }
    }
}

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

func fetchExercise(exerciseId: String) async -> Exercise? {
    let result: HTTPResponse<Exercise> = await sendRequest(
        endpoint: "/exercises/history/\(exerciseId)",
        method: .GET
    )
    switch result {
    case .success(let fetchedWorkout):
        return fetchedWorkout
    case .failure(let error):
        print("Failed to fetch workout: \(error)")
    }
    
    return nil
}

struct WorkoutWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var exercise: Exercise
        var currentSetIndex: Int
        var totalExercisesCount: Int
    }
    
    // Fixed non-changing properties about your activity go here!
    var workoutName: String
}

struct WorkoutWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                
                HStack {
                    Text(context.attributes.workoutName)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(context.state.exercise.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(context.state.exercise.index + 1)/\(context.state.totalExercisesCount)")
                        .font(.caption)
                }
                
                Divider()
                
                HStack {
                    VStack(spacing: 4) {
                        Image(systemName: "list.number")
                            .bold()
                            .font(.title3)
                        Text("\(context.state.currentSetIndex + 1)/\(context.state.exercise.sets.count)")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    if context.state.exercise.isRepBased {
                        VStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .bold()
                                .font(.title3)
                            Text("\(context.state.exercise.sets[context.state.currentSetIndex].reps)")
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .bold()
                                .font(.title3)
                            Text("\(context.state.exercise.sets[context.state.currentSetIndex].weight) kg")
                                .fontWeight(.semibold)
                        }
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "clock")
                                .bold()
                                .font(.title3)
                            Text("\(context.state.exercise.sets[context.state.currentSetIndex].duration) s")
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: "bolt")
                                .bold()
                                .font(.title3)
                            Circle()
                                .fill(context.state.exercise.sets[context.state.currentSetIndex].intensity.color)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .padding(8)
                
                Divider()
                
                HStack {
                    if context.state.exercise.index > 0 {
                        Button(action: {
                            // Decrement the currentExerciseIndex and update the activity state
                            if let activity = currentLiveActivity {
                                let newState = context.state
                                newState.exercise.index -= 1
                                let newContent = ActivityContent(state: newState, staleDate: nil)
                                Task {
                                    await activity.update(newContent)
                                }
                            }
                        }) {
                            Text("Prev")
                                .controlSize(.large)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    if context.state.exercise.index < context.state.totalExercisesCount - 1 {
                        Button(action: {
                            // Increment the currentExerciseIndex and update the activity state
                            if let activity = currentLiveActivity {
                                let newState = context.state
                                newState.exercise.index += 1
                                newState.exercise.sets[context.state.currentSetIndex].completedAt = Date()
                                let newContent = ActivityContent(state: newState, staleDate: nil)
                                Task {
                                    await activity.update(newContent)
                                }
                            }
                        }) {
                            Text("Next")
                                .controlSize(.large)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            Task { await stopWorkoutLiveActivity() }
                        }) {
                            Text("Finish")
                                .controlSize(.large)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            }
            .padding()
            .activityBackgroundTint(Color("AccentColor"))
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.workoutName)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                }
            } compactLeading: {
                Text("Workout")
            } compactTrailing: {
                Text(context.attributes.workoutName)
            } minimal: {
                Text(context.attributes.workoutName)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color("AccentColor"))
        }
    }
}

extension WorkoutWidgetAttributes {
    fileprivate static var preview: WorkoutWidgetAttributes {
        WorkoutWidgetAttributes(workoutName: "World")
    }
}

extension WorkoutWidgetAttributes.ContentState {
    fileprivate static var smallWorkout: WorkoutWidgetAttributes.ContentState {
        WorkoutWidgetAttributes.ContentState(
            exercise: Exercise(
                name: "Bench Press",
                isRepBased: true,
                equipment: .machine,
                muscleGroups: [.chest, .arms],
                sets: [
                    ExerciseSet(reps: 10, weight: 25, index: 0),
                    ExerciseSet(reps: 8, weight: 20, index: 1)
                ]
            ),
            currentSetIndex: 0,
            totalExercisesCount: 0
        )
    }
    
    fileprivate static var bigWorkout: WorkoutWidgetAttributes.ContentState {
        WorkoutWidgetAttributes.ContentState(
            exercise: Exercise(
                name: "sit on 8=D",
                isRepBased: true,
                equipment: .ball,
                muscleGroups: [.chest],
                sets: [
                    ExerciseSet(reps: 6, weight: 35, index: 0),
                    ExerciseSet(reps: 5, weight: 30, index: 1),
                    ExerciseSet(reps: 4, weight: 25, index: 2)
                ]
            ),
            currentSetIndex: 0,
            totalExercisesCount: 0
        )
    }
}

#Preview("Notification", as: .content, using: WorkoutWidgetAttributes.preview) {
    WorkoutWidgetLiveActivity()
} contentStates: {
    WorkoutWidgetAttributes.ContentState.smallWorkout
    WorkoutWidgetAttributes.ContentState.bigWorkout
}
