//
//  ActiveTimerView.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/26/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI

struct ActiveTimerView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataStore: TimerDataStore
    @State var isEditing: Bool = false
    
    var body: some View {
        if let state = dataStore.activeTimer {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Text(state.phase.rawValue)
                        .font(.system(size: 30))
                    Text(state.timeRemaining.toDurationString())
                        .font(Font.system(size: 200).monospacedDigit())
                        .lineLimit(1)
                        .scaledToFit()
                        .minimumScaleFactor(0.1)
                        .padding(.horizontal)
                    TimerControlsView(dataStore: self.dataStore, state: state)
                    if verticalSizeClass != .compact {
                        Spacer()
                        HStack {
                            LabeledCounter(label: "Set", counter: state.currentSet)
                            Spacer()
                            LabeledCounter(label: "Round", counter: state.currentRound)
                        }.padding(.horizontal) 
                    }
                }
                .navigationBarTitle("\(state.timer.name)", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading: Button(action: {
                        // TODO: Confirm before exiting if the timer isn't complete
                        self.dataStore.closeTimer()
                    }, label: {
                        Image(systemName: "xmark")
                    }).foregroundColor(.primary),
                    trailing: Button(
                        action: {
                            self.isEditing = true
                        },
                        label: {
                            Text("Edit")
                        }
                    ).foregroundColor(.primary)
                )
                .padding(geometry.safeAreaInsets)
                .background(state.phase.backgroundColor(forColorScheme: colorScheme))
                .foregroundColor(state.phase.textColor(forColorScheme: colorScheme))
                .animation(.default)
                .edgesIgnoringSafeArea(.all)

            }
            .sheet(isPresented: $isEditing,
                   onDismiss: { self.isEditing = false },
                   content: { TimerFormView(state.timer)})
        }
    }
}

struct TimerControlsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    let dataStore: TimerDataStore
    let state: ActiveTimerState
    private var toggleButtonImage: String {
        get {
            if self.state.isRunning {
                return "pause.fill"
            } else {
                return "play.fill"
            }
        }
    }
    var buttonSize: CGFloat = 32
    
    var body: some View {
        HStack {
            if verticalSizeClass == .compact {
                LabeledCounter(label: "Set", counter: state.currentSet)
                Spacer()
            }
            Button(action: {
                self.dataStore.goBack()
            }, label: {
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            })
            .padding()
            Button(action: {
                self.dataStore.toggle()
            }, label: {
                Image(systemName: toggleButtonImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            })
            .padding()
            Button(action: {
                self.dataStore.goForward()
            }, label: {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            })
            .padding()
            if verticalSizeClass == .compact {
                Spacer()
                LabeledCounter(label: "Round", counter: state.currentRound)
            }
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
                .font(.system(size: 20))
            Text(String(counter))
                .multilineTextAlignment(.center)
                .font(Font.system(size: 40).monospacedDigit())
        }
    }
}

struct ActiveTimerView_Previews: PreviewProvider {
    static var dataStore: TimerDataStore {
        get {
            let store = TimerDataStore() {}
            store.openTimer(IntervalTimer(
                id: UUID(),
                name: "Test",
                description: nil,
                warmUpDuration: 300,
                lowIntensityDuration: 10,
                highIntensityDuration: 20,
                restDuration: 50,
                cooldownDuration: 300,
                sets: 4,
                rounds: 2
            ))
            return store
        }
    }
    static var previews: some View {
        ActiveTimerView().environmentObject(dataStore)
            .environment(\.colorScheme, .dark)
    }
}
