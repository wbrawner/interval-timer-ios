//
//  Extensions.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/23/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func toAnyView() -> AnyView {
        return AnyView(self)
    }
}

extension Int64 {
    func toDurationString() -> String {
        var seconds: Int64 = self
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
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
