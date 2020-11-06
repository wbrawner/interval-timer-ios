//
//  Timer.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/22/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import AudioToolbox
import CoreData
import Foundation
import SwiftUI

struct IntervalTimer: Identifiable, Equatable {
    let id: UUID?
    let name: String
    let description: String?
    let warmUpDuration: Int64
    let lowIntensityDuration: Int64
    let highIntensityDuration: Int64
    let restDuration: Int64
    let cooldownDuration: Int64
    let sets: Int64
    let rounds: Int64
}

class IntervalTimerMO: NSManagedObject, Identifiable {
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
                return Color(UIColor(named: "WarmUpColor")!)
            case .low:
                return Color(UIColor(named: "LowIntensityColor")!)
            case .high:
                return Color(UIColor(named: "HighIntensityColor")!)
            case .rest:
                return Color(UIColor(named: "RestColor")!)
            case .cooldown:
                return Color(UIColor(named: "CooldownColor")!)
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
    
    func copy(toMO: IntervalTimerMO) {
        toMO.id = self.id
        toMO.name = self.name
        toMO.userDescription = self.description
        toMO.warmUpDuration = self.warmUpDuration
        toMO.lowIntensityDuration = self.lowIntensityDuration
        toMO.highIntensityDuration = self.highIntensityDuration
        toMO.restDuration = self.restDuration
        toMO.cooldownDuration = self.cooldownDuration
        toMO.sets = self.sets
        toMO.rounds = self.rounds
    }
    
    static func create(fromMO: IntervalTimerMO) -> IntervalTimer {
        return IntervalTimer(
            id: fromMO.id,
            name: fromMO.name,
            description: fromMO.userDescription,
            warmUpDuration: fromMO.warmUpDuration,
            lowIntensityDuration: fromMO.lowIntensityDuration,
            highIntensityDuration: fromMO.highIntensityDuration,
            restDuration: fromMO.restDuration,
            cooldownDuration: fromMO.cooldownDuration,
            sets: fromMO.sets,
            rounds: fromMO.rounds
        )
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
