//
//  Timer.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/22/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

class IntervalTimer: NSManagedObject, Identifiable {
    @NSManaged var id: UUID?
    @NSManaged var name: String
    @NSManaged var userDescription: String?
    @NSManaged var warmUpDuration: Int64
    @NSManaged var lowIntensityDuration: Int64
    @NSManaged var highIntensityDuration: Int64
    @NSManaged var restDuration: Int64
    @NSManaged var cooldownDuration: Int64
    @NSManaged var sets: Int64
    @NSManaged var rounds: Int64
}

enum Phase: String {
    case warmUp = "Warm-Up"
    case low = "Low Intensity"
    case high = "High Intensity"
    case rest = "Rest"
    case cooldown = "Cooldown"
}

extension Phase {
    var backgroundColor: Color {
        get {
            switch self {
            case .warmUp:
                return Color(UIColor.systemBackground)
            case .low:
                return Color(UIColor.systemRed)
            case .high:
                return Color(UIColor.systemGreen)
            case .rest:
                return Color(UIColor.systemYellow)
            case .cooldown:
                return Color(UIColor.systemBlue)
            }
        }
    }
}

extension IntervalTimer {
    func durationForPhase(phase: Phase) -> Int64 {
        switch phase {
        case .warmUp:
            return self.warmUpDuration
        case .low:
            return self.lowIntensityDuration
        case .high:
            return self.highIntensityDuration
        case .rest:
            return self.restDuration
        case .cooldown:
            return self.cooldownDuration
        }
    }
    
    var totalDuration: Int64 {
        get {
            return warmUpDuration + ((((lowIntensityDuration + highIntensityDuration) * sets) + restDuration) * rounds) + cooldownDuration
        }
    }
}

struct ActiveTimerState {
    let timer: IntervalTimer
    let timeRemaining: Int64
    let currentSet: Int64
    let currentRound: Int64
    let soundId: Int?
    let phase: Phase
    let isRunning: Bool
    var backgroundColor: Color {
        get {
            return self.phase.backgroundColor
        }
    }
}

extension ActiveTimerState {
    func copy(
        timer: IntervalTimer? = nil,
        timeRemaining: Int64? = nil,
        currentSet: Int64? = nil,
        currentRound: Int64? = nil,
        soundId: Int? = nil,
        phase: Phase? = nil,
        isRunning: Bool? = nil
    ) -> ActiveTimerState {
        return ActiveTimerState(
            timer: timer ?? self.timer,
            timeRemaining: timeRemaining ?? self.timeRemaining,
            currentSet: currentSet ?? self.currentSet,
            currentRound: currentRound ?? self.currentRound,
            soundId: soundId ?? self.soundId,
            phase: phase ?? self.phase,
            isRunning: isRunning ?? self.isRunning
        )
    }
}
