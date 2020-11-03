//
//  TimerFormView.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/23/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI

struct TimerFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: TimerDataStore
    let title: String
    let timerId: UUID?
    @State var name: String
    @State var description: String
    @State var warmDuration: Int64
    @State var lowDuration: Int64
    @State var highDuration: Int64
    @State var restDuration: Int64
    @State var coolDuration: Int64
    @State var sets: Int64
    @State var rounds: Int64
    @State var activePicker: ActivePicker = .none
    
    var setsPicker: AnyView {
        if self.activePicker == .sets {
            return Picker("Sets", selection: self.$sets) {
                ForEach(1..<100) {
                    Text(String($0)).tag(Int64($0))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .toAnyView()
        } else {
            return EmptyView().toAnyView()
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: self.$name)
                TextField("Description", text: self.$description)
                CollapsibleFormRowView(
                    rowTitle: "Warm-up",
                    rowValue: "\(warmDuration.toDurationString())",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .warmUp) ? .none : .warmUp
                },
                    expandView: .constant(self.activePicker == .warmUp),
                    collapsibleView: DurationPicker($warmDuration).toAnyView()
                )
                CollapsibleFormRowView(
                    rowTitle: "Low Intensity",
                    rowValue: "\(lowDuration.toDurationString())",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .lowIntensity) ? .none : .lowIntensity
                },
                    expandView: .constant(self.activePicker == .lowIntensity),
                    collapsibleView: DurationPicker($lowDuration).toAnyView()
                )
                CollapsibleFormRowView(
                    rowTitle: "High Intensity",
                    rowValue: "\(highDuration.toDurationString())",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .highIntensity) ? .none : .highIntensity
                },
                    expandView: .constant(self.activePicker == .highIntensity),
                    collapsibleView: DurationPicker($highDuration).toAnyView()
                )
                CollapsibleFormRowView(
                    rowTitle: "Rest",
                    rowValue: "\(restDuration.toDurationString())",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .rest) ? .none : .rest
                },
                    expandView: .constant(self.activePicker == .rest),
                    collapsibleView: DurationPicker($restDuration).toAnyView()
                )
                CollapsibleFormRowView(
                    rowTitle: "Cooldown",
                    rowValue: "\(coolDuration.toDurationString())",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .cooldown) ? .none : .cooldown
                },
                    expandView: .constant(self.activePicker == .cooldown),
                    collapsibleView: DurationPicker($coolDuration).toAnyView()
                )
                CollapsibleFormRowView(
                    rowTitle: "Sets",
                    rowValue: "\(sets)",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .sets) ? .none : .sets
                },
                    expandView: .constant(self.activePicker == .sets),
                    collapsibleView: Picker("Sets", selection: $sets) {
                        ForEach(1..<100) {
                            Text(String($0)).tag(Int64($0))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .toAnyView()
                )
                CollapsibleFormRowView(
                    rowTitle: "Rounds",
                    rowValue: "\(rounds)",
                    buttonAction: {
                        self.activePicker = (self.activePicker == .rounds) ? .none : .rounds
                },
                    expandView: .constant(self.activePicker == .rounds),
                    collapsibleView: Picker("Rounds", selection: $rounds) {
                        ForEach(1..<100) {
                            Text(String($0)).tag(Int64($0))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .toAnyView()
                )
            }
            .gesture(DragGesture()
                        .onChanged({ _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }))
            .navigationBarTitle("\(self.title)", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                }), trailing:
                Button(action: {
                    self.dataStore.saveTimer(
                        id: self.timerId,
                        name: self.name,
                        description: self.description,
                        warmUpDuration: self.warmDuration,
                        lowIntensityDuration: self.lowDuration,
                        highIntensityDuration: self.highDuration,
                        restDuration: self.restDuration,
                        cooldownDuration: self.coolDuration,
                        sets: self.sets,
                        rounds: self.rounds
                    )
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save")
                })
            )
        }
    }
    
    init(_ timer: IntervalTimer? = nil) {
        self.timerId = timer?.id
        if self.timerId != nil {
            self.title = "Edit Timer"
        } else {
            self.title = "New Timer"
        }
        self._name = State(initialValue: timer?.name ?? "")
        self._description = State(initialValue: timer?.userDescription ?? "")
        self._warmDuration = State(initialValue: timer?.warmUpDuration ?? 300)
        self._lowDuration = State(initialValue: timer?.lowIntensityDuration ?? 30)
        self._highDuration = State(initialValue: timer?.highIntensityDuration ?? 60)
        self._restDuration = State(initialValue: timer?.restDuration ?? 60)
        self._coolDuration = State(initialValue: timer?.cooldownDuration ?? 300)
        self._sets = State(initialValue: timer?.sets ?? 4)
        self._rounds = State(initialValue: timer?.rounds ?? 2)
    }
}

enum ActivePicker {
    case none
    case warmUp
    case lowIntensity
    case highIntensity
    case rest
    case cooldown
    case sets
    case rounds
}

struct TimerFormView_Previews: PreviewProvider {
    
    static var previews: some View {
        TimerFormView().environmentObject(TimerDataStore() {})
    }
}
