//
//  ActiveTimerView.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/26/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI

struct ActiveTimerView: View {
    @EnvironmentObject var dataStore: TimerDataStore
    
    var body: some View {
        if let state = dataStore.activeTimer {
            VStack {
                Spacer()
                Text(state.phase.rawValue)
                Text(state.timeRemaining.toDurationString())
                    .font(Font.system(size: 200).monospacedDigit())
                    .lineLimit(1)
                    .scaledToFit()
                    .minimumScaleFactor(0.1)
                    .padding()
                TimerControlsView(dataStore: self.dataStore, timerRunning: .constant(state.isRunning))
                Spacer()
                HStack {
                    LabeledCounter(label: "Sets", counter: state.currentSet)
                    Spacer()
                    LabeledCounter(label: "Round", counter: state.currentRound)
                }
            }
            .navigationBarTitle("\(state.timer.name)", displayMode: .inline)
            .background(state.backgroundColor)
            .edgesIgnoringSafeArea(.vertical)
            .animation(.default)
        }
    }
}

struct TimerControlsView: View {
    let dataStore: TimerDataStore
    @Binding var timerRunning: Bool
    private var toggleButtonImage: String {
        get {
            if self.timerRunning {
                return "pause.fill"
            } else {
                return "play.fill"
            }
        }
    }
    var buttonSize: CGFloat = 32
    
    var body: some View {
        HStack {
            Button(action: {
                self.dataStore.goBack()
            }, label: {
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            })
            .foregroundColor(.primary)
            .padding()
            Button(action: {
                self.dataStore.toggle()
            }, label: {
                Image(systemName: toggleButtonImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            })
            .foregroundColor(.primary)
            .padding()
            Button(action: {
                self.dataStore.goForward()
            }, label: {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            })
            .foregroundColor(.primary)
            .padding()
        }
    }
}

struct LabeledCounter: View {
    let label: String
    let counter: Int64
    
    var body: some View {
        VStack {
            Text(label)
                .multilineTextAlignment(.center)
            Text(String(counter))
                .multilineTextAlignment(.center)
                .font(Font.title.monospacedDigit())
        }
        .padding()
    }
}

struct ActiveTimerView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveTimerView().environmentObject(TimerDataStore() {})
    }
}