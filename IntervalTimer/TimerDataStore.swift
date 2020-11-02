//
//  TimerDataStore.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/23/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import AudioToolbox
import Combine
import CoreData
import Foundation
import SwiftUI

class TimerDataStore: ObservableObject {
    private var persistentContainer: NSPersistentContainer
    private let internalTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var timerCancellable: AnyCancellable? = nil
    private var sounds: [Phase:SystemSoundID] = [:]
    
    @Published var activeTimer: ActiveTimerState? = nil {
        didSet {
            self.hasActiveTimer = self.activeTimer != nil
        }
    }
    @Published var hasActiveTimer: Bool = false
    @Published var timers: Result<[IntervalTimer], TimerError> = .failure(.loading)
    
    func openTimer(_ timer: IntervalTimer) {
        self.activeTimer = ActiveTimerState(
            timer: timer,
            timeRemaining: timer.warmUpDuration,
            currentSet: timer.sets,
            currentRound: timer.rounds,
            soundId: nil,
            phase: Phase.warmUp,
            isRunning: false
        )
  }
    
    func closeTimer() {
        self.activeTimer = nil
    }
    
    func goBack() {
        guard let state = self.activeTimer else {
            return
        }
        
        switch state.phase {
        case .warmUp:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.warmUpDuration
            )
        case .low:
            if state.currentSet == state.timer.sets && state.currentRound == state.timer.rounds {
                self.activeTimer = state.copy(
                    timeRemaining: state.timer.warmUpDuration,
                    phase: .warmUp
                )
            } else if state.currentSet == state.timer.sets && state.currentRound < state.timer.rounds {
                self.activeTimer = state.copy(
                    timeRemaining: state.timer.restDuration,
                    currentRound: state.timer.rounds + 1,
                    phase: .rest
                )
            } else {
                self.activeTimer = state.copy(
                    timeRemaining: state.timer.highIntensityDuration,
                    currentSet: state.currentSet + 1,
                    phase: .high
                )
            }
        case .high:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.lowIntensityDuration,
                phase: .low
            )
        case .rest:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.highIntensityDuration,
                phase: .high
            )
        case .cooldown:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.highIntensityDuration,
                phase: .high
            )
        }
        if let newState = self.activeTimer {
            if newState.isRunning {
                AudioServicesPlaySystemSound(sounds[newState.phase]!)
            }
        }
    }
    
    func toggle() {
        guard let state = self.activeTimer else {
            return
        }
        if self.timerCancellable != nil {
            self.timerCancellable?.cancel()
            self.timerCancellable = nil
        } else {
            self.timerCancellable = self.internalTimer.sink(receiveValue: { _ in
                self.updateTimer()
            })
        }
        self.activeTimer = state.copy(isRunning: self.timerCancellable != nil)
        UIApplication.shared.isIdleTimerDisabled = self.activeTimer?.isRunning ?? false
    }
    
    private func updateTimer() {
        guard let state = self.activeTimer else {
            return
        }
        let newState = state.copy(timeRemaining: state.timeRemaining - 1)
        if newState.timeRemaining == 0 {
            goForward()
        } else {
            self.activeTimer = newState
        }
    }
    
    func goForward() {
        guard let state = self.activeTimer else {
            return
        }
        switch state.phase {
        case .warmUp:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.lowIntensityDuration,
                phase: .low
            )
        case .low:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.highIntensityDuration,
                phase: .high
            )
        case .high:
            if state.currentSet > 1 {
                self.activeTimer = state.copy(
                    timeRemaining: state.timer.lowIntensityDuration,
                    currentSet: state.currentSet - 1,
                    phase: .low
                )
            } else if state.currentRound > 1 {
                self.activeTimer = state.copy(
                    timeRemaining: state.timer.restDuration,
                    currentRound: state.currentRound - 1,
                    phase: .rest
                )
            } else {
                self.activeTimer = state.copy(
                    timeRemaining: state.timer.cooldownDuration,
                    phase: .cooldown
                )
            }
        case .rest:
            self.activeTimer = state.copy(
                timeRemaining: state.timer.lowIntensityDuration,
                currentSet: state.timer.sets,
                phase: .low
            )
        case .cooldown:
            self.activeTimer = state.copy(
                timeRemaining: 0,
                isRunning: false
            )
            self.timerCancellable?.cancel()
            self.timerCancellable = nil
            UIApplication.shared.isIdleTimerDisabled = false
        }
        if let newState = self.activeTimer {
            if newState.isRunning {
                AudioServicesPlaySystemSound(sounds[newState.phase]!)
            }
        }
    }
    
    func loadTimers() {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IntervalTimer")
            do {
                let fetchedTimers = try self.persistentContainer.viewContext.fetch(fetchRequest) as! [IntervalTimer]
                DispatchQueue.main.async {
                    self.timers = .success(fetchedTimers)
                }
            } catch {
                DispatchQueue.main.async {
                    self.timers = .failure(.failed(error))
                }
            }
        }
    }
    
    func saveTimer(
        id: UUID? = nil,
        name: String,
        description: String? = nil,
        warmUpDuration: Int64,
        lowIntensityDuration: Int64,
        highIntensityDuration: Int64,
        restDuration: Int64,
        cooldownDuration: Int64,
        sets: Int64,
        rounds: Int64
    ) {
        let timer = IntervalTimer.init(entity: NSEntityDescription.entity(forEntityName: "IntervalTimer", in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext) as IntervalTimer
        timer.id = id ?? UUID()
        timer.name = name
        timer.userDescription = description
        timer.warmUpDuration = warmUpDuration
        timer.lowIntensityDuration = lowIntensityDuration
        timer.highIntensityDuration = highIntensityDuration
        timer.restDuration = restDuration
        timer.cooldownDuration = cooldownDuration
        timer.sets = sets
        timer.rounds = rounds
        let viewContext = persistentContainer.viewContext
        viewContext.insert(timer)
        try! viewContext.save()
        loadTimers()
    }

    func deleteTimer(at: IndexSet) {
        let timer = try!  self.timers.get()[at.first!]
        let viewContext = persistentContainer.viewContext
        viewContext.delete(timer)
        try! viewContext.save()
        loadTimers()
    }
    
    private func loadSound(_ phase: Phase) {
        let filePath = Bundle.main.path(forResource: phase.rawValue, ofType: "mp3")
        let url = NSURL(fileURLWithPath: filePath!)
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url, &soundId)
        sounds[phase] = soundId
    }

    init(_ completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "IntervalTimer")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            self.loadTimers()
            completionClosure()
        }
        loadSound(.warmUp)
        loadSound(.low)
        loadSound(.high)
        loadSound(.rest)
        loadSound(.cooldown)
    }
}

enum TimerError: Error {
    case loading
    case failed(_ error: Error)
}
