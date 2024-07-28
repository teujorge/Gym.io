//
//  WorkoutActivityIntents.swift
//  Swety
//
//  Created by Matheus Jorge on 7/27/24.
//

import SwiftUI
import ActivityKit
import AppIntents

struct PrevSetIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Previous Set"
    
    func perform() async throws -> some IntentResult {
        // Implement the action to move to the previous set
        if let activity = currentLiveActivity {
            var newState = activity.content.state

            // Check if the current set is the first one
            if newState.currentSetIndex == 0 {
                // Check if the current exercise is the first one
                if newState.exercise.index == 0 {
                    // Do nothing
                    return .result()
                } else {
                    // Move to the previous exercise
                    newState.exercise.index -= 1
                    newState.currentSetIndex = newState.exercise.sets.count - 1
                }
            } else {
                // Move to the previous set
                newState.currentSetIndex -= 1
            }
            
            let newContent = ActivityContent(state: newState, staleDate: nil)
            await activity.update(newContent)
        }
        
        return .result()
    }
}

struct SkipSetIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Skip Set"
    
    func perform() async throws -> some IntentResult {
        // Implement the action to move to the next set
        if let activity = currentLiveActivity {
            var newState = activity.content.state

            // Check if the current set is the last one
            if newState.currentSetIndex == newState.exercise.sets.count - 1 {
                // Check if the current exercise is the last one
                if newState.exercise.index == newState.totalExercisesCount - 1 {
                    // Do nothing
                    return .result()
                } else {
                    // Move to the next exercise
                    newState.exercise.index += 1
                    newState.currentSetIndex = 0
                }
            } else {
                // Move to the next set
                newState.currentSetIndex += 1
            }
            
            let newContent = ActivityContent(state: newState, staleDate: nil)
            await activity.update(newContent)
        }
        
        return .result()
    }
}

struct CompleteSetIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Complete Set"
    
    func perform() async throws -> some IntentResult {
        // Implement the action to move to the next set (need to set the completedAt (Date) field to mark it as complete)
        if let activity = currentLiveActivity {
            var newState = activity.content.state

            // Mark the current set as complete
            newState.exercise.sets[newState.currentSetIndex].completedAt = Date()

            // Check if the current set is the last one
            if newState.currentSetIndex == newState.exercise.sets.count - 1 {
                // Check if the current exercise is the last one
                if newState.exercise.index == newState.totalExercisesCount - 1 {
                    // Do nothing
                    return .result()
                } else {
                    // Move to the next exercise
                    newState.exercise.index += 1
                    newState.currentSetIndex = 0
                }
            } else {
                // Move to the next set
                newState.currentSetIndex += 1
            }

            let newContent = ActivityContent(state: newState, staleDate: nil)
            await activity.update(newContent)
        }

        return .result()
    }
}

struct FinishWorkoutIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Finish Workout"
    
    func perform() async throws -> some IntentResult {
        // Implement the action to finish the workout
        await stopWorkoutLiveActivity()
        return .result()
    }
}
