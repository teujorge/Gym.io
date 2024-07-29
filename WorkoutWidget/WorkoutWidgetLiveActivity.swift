//
//  WorkoutWidgetLiveActivity.swift
//  WorkoutWidget
//
//  Created by Matheus Jorge on 7/26/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

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
                SetDetailsView(context)
                Divider()
                BottomControlsView(context)
            }
            .padding()
            .activityBackgroundTint(Color("WidgetBackground"))
            //            .activitySystemActionForegroundColor(Color("AccentColor"))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here. Compose the expanded UI through various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.workoutName)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.exercise.name)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.center) {
                    SetDetailsView(context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    BottomControlsView(context)
                }
            } compactLeading: {
                Text("Workout")
            } compactTrailing: {
                Text(context.attributes.workoutName)
            } minimal: {
                Text(context.attributes.workoutName)
            }
            // .widgetURL(URL(string: "http://www.apple.com")) // TODO: implement later
            .keylineTint(Color("AccentColor"))
        }
    }
    
    func SetDetailsView(_ context: ActivityViewContext<WorkoutWidgetAttributes>) -> some View {
        HStack {
            VStack(spacing: 4) {
                Image(systemName: "list.number")
                    .bold()
                Text("\(context.state.currentSetIndex + 1)/\(context.state.exercise.sets.count)")
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            if context.state.exercise.isRepBased {
                VStack(spacing: 4) {
                    Image(systemName: "repeat")
                        .bold()
                    Text("\(context.state.exercise.sets[context.state.currentSetIndex].reps)")
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "scalemass")
                        .bold()
                    Text("\(context.state.exercise.sets[context.state.currentSetIndex].weight) kg")
                        .fontWeight(.semibold)
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "clock")
                        .bold()
                    Text("\(context.state.exercise.sets[context.state.currentSetIndex].duration) s")
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "bolt")
                        .bold()
                    Circle()
                        .fill(context.state.exercise.sets[context.state.currentSetIndex].intensity.color)
                        .frame(width: 10, height: 10)
                }
            }
        }
        .padding(8)
    }
    
    func BottomControlsView(_ context: ActivityViewContext<WorkoutWidgetAttributes>) -> some View {
        HStack {
            // Previous button: Only show if not on the first set of the first exercise
            if context.state.currentSetIndex > 0 || context.state.exercise.index > 0 {
                Button("Prev", intent: PrevSetIntent())
                    .buttonStyle(.plain)
                    .controlSize(.large)
            }

            // Skip button: Only show if not on the last set of the last exercise
            if context.state.currentSetIndex < context.state.exercise.sets.count - 1 || context.state.exercise.index < context.state.totalExercisesCount - 1 {
                Button("Skip", intent: SkipSetIntent())
                    .buttonStyle(.plain)
                    .controlSize(.large)
            }
            
            Spacer()
            
            // Next button: Only show if not on the last set of the last exercise
            if context.state.currentSetIndex < context.state.exercise.sets.count - 1 || context.state.exercise.index < context.state.totalExercisesCount - 1 {
                Button("Next", intent: CompleteSetIntent())
                    .buttonStyle(.plain)
                    .controlSize(.large)
            } else {
                // Finish button: Only show if on the last set of the last exercise
                Button("Finish", intent: FinishWorkoutIntent())
                    .buttonStyle(.plain)
                    .controlSize(.large)
            }
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
