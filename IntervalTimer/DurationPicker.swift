//
//  DurationPicker.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/24/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI
import Combine

struct DurationPicker: View {
    @State fileprivate var hours: Int64 {
        didSet {
            updateDuration()
        }
    }
    @State fileprivate var minutes: Int64 {
        didSet {
            updateDuration()
        }
    }
    @State fileprivate var seconds: Int64 {
        didSet {
            updateDuration()
        }
    }
    @Binding var selection: Int64

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Picker("Hours", selection: self.$hours) {
                    ForEach(0..<24) { hour in
                        Text(String(format: "%02d", hour)).tag(Int64(hour))
                    }
                }
                .onReceive(Just(self.hours)) { _ in
                    self.updateDuration()
                }
                .frame(width: geometry.size.width/3, alignment: .center)
                .clipped()
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                Picker("Minutes", selection: self.$minutes) {
                    ForEach(0..<60) { minute in
                        Text(String(format: "%02d", minute)).tag(Int64(minute))
                    }
                }
                .onReceive(Just(self.minutes)) { _ in
                    self.updateDuration()
                }
                .frame(width: geometry.size.width/3, alignment: .center)
                .clipped()
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                Picker("Seconds", selection: self.$seconds) {
                    ForEach(0..<60) { second in
                        Text(String(format: "%02d", second)).tag(Int64(second))
                    }
                }
                .onReceive(Just(self.seconds)) { _ in
                    self.updateDuration()
                }
                .frame(width: geometry.size.width/3, alignment: .center)
                .clipped()
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
            }
        }.frame(height: 200)
    }
    
    init (_ selection: Binding<Int64>) {
        self._selection = selection
        var seconds: Int64 = selection.wrappedValue
        var hours: Int64 = 0
        if (seconds >= 3600) {
            hours = seconds / 3600
            seconds -= hours * 3600
        }
        
        var minutes: Int64 = 0
        if (seconds >= 60) {
            minutes = seconds / 60
            seconds -= minutes * 60
        }
        self._hours = State(initialValue: hours)
        self._minutes = State(initialValue: minutes)
        self._seconds = State(initialValue: seconds)
    }
}

extension DurationPicker {
    func updateDuration() {
        self.selection = (self.hours * 3600) + (self.minutes * 60) + self.seconds
    }
}

struct DurationPicker_Previews: PreviewProvider {
    static var previews: some View {
        DurationPicker(.constant(0))
    }
}
