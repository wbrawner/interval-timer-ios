//
//  CollapsibleFormRowView.swift
//  IntervalTimer
//
//  Created by William Brawner on 10/24/20.
//  Copyright © 2020 William Brawner. All rights reserved.
//

import SwiftUI

struct CollapsibleFormRowView: View {
    let rowTitle: String
    let rowValue: String
    let buttonAction: () -> Void
    @Binding var expandView: Bool
    let collapsibleView: AnyView
    
    // This is a hacky workaround to get multiple if statements inside a single form
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    self.buttonAction()
                }
            }, label: {
                HStack {
                    Text(rowTitle)
                    Spacer()
                    Text(rowValue)
                        .font(Font.body.monospacedDigit())
                        .foregroundColor(.secondary)
                }
            }).foregroundColor(.primary)
            if expandView {
                collapsibleView
            }
        }
    }
}

struct CollapsibleFormRowView_Previews: PreviewProvider {
    static var previews: some View {
        CollapsibleFormRowView(rowTitle: "Sets", rowValue: "2", buttonAction: {}, expandView: .constant(true), collapsibleView: Text("Expanded").toAnyView())
    }
}
