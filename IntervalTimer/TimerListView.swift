//
//  ContentView.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/22/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI

struct TimerListView: View {
    @State var isEditing: Bool = false
    @EnvironmentObject var dataStore: TimerDataStore
    
    var stateContent: AnyView {
        switch dataStore.timers {
        case .success(let timers):
            if timers.count == 0 {
                return Text("Create a timer to get started")
                    .toAnyView()
            } else {
                return List(timers) { timer in
                    NavigationLink(
                        destination: ActiveTimerView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarItems(leading: Button(action: {
                                // TODO: Confirm before exiting if the timer isn't complete
                                self.dataStore.closeTimer()
                            }, label: { Image(systemName: "xmark") })
                                .foregroundColor(.primary)
                        ),
                        isActive: .constant(self.dataStore.hasActiveTimer)
                    ) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(timer.name)
                                    .lineLimit(1)
                                if timer.userDescription?.count ?? 0 > 0 {
                                    Text(timer.userDescription!)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text(timer.totalDuration.toDurationString())
                                .font(Font.subheadline.monospacedDigit())
                                .foregroundColor(.secondary)
                        }
                        .frame(minHeight: 50)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.dataStore.openTimer(timer)
                        }
                    }
                }.toAnyView()
            }
        default:
            return Text("Loading...").toAnyView()
        }
    }
    
    var body: some View {
        NavigationView {
            stateContent
                .navigationBarTitle("Timers")
                .navigationBarItems(trailing: Button(action: {
                    self.isEditing = true
                }, label: { Image(systemName: "plus").padding() } ))
        }
        .sheet(isPresented: $isEditing,
               onDismiss: { self.isEditing = false },
               content: { TimerFormView()})
    }
}

struct TimerListView_Previews: PreviewProvider {
    static var previews: some View {
        TimerListView().environmentObject(TimerDataStore() {})
    }
}
