//
//  OktaCustomButtons.swift
//
//  Created by Nathan DeGroff on 1/21/22.
//

import SwiftUI

/**
 * Custom Button - Filled button style
 */
struct CustomButton: ButtonStyle {
    let disabled: Bool

    var buttonColor : Color {
        return (disabled ? Color.gray : Color.blue)
    }

    init( disabled: Bool = false ) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding()
            .frame(maxWidth: 322, maxHeight: 50)
            .background(RoundedRectangle(cornerRadius: 8).fill(buttonColor))
            .disabled(disabled)
    }
}

/**
 * Custom Outline Button - Button with outline style
 */
struct CustomOutlineButton: ButtonStyle {
    let disabled: Bool

    var buttonColor : Color {
        return (disabled ? Color.gray : Color.blue)
    }

    init( disabled: Bool = false ) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(buttonColor)
            .frame(maxWidth: 290, maxHeight: 50)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(buttonColor, lineWidth: 2))
            .disabled(disabled)
    }
}

/**
 * Custom Plain Button - Button with no body / border.. just text and click area like other
 * custom buttons
 */
struct CustomPlainButton: ButtonStyle {
    let disabled: Bool

    var buttonColor : Color {
        return (disabled ? Color.gray : Color.blue)
    }

    init( disabled: Bool = false ) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(buttonColor)
            .frame(maxWidth: 322, maxHeight: 50)
            .cornerRadius(6)
            //.overlay(RoundedRectangle(cornerRadius: 8).stroke(buttonColor, lineWidth: 2))
           // .padding([.top, .bottom], 2)
            .disabled(disabled)
    }
}

struct CustomOutlineButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            Button("Custom Button") { print("Click") }
                .buttonStyle(CustomButton())
                .previewDisplayName("CustomButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Custom Disabled") { print("Click") }
                .buttonStyle(CustomButton(disabled: true))
                .previewDisplayName("CustomButton() Disabled")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Outline Button") { print("Click") }
                .buttonStyle(CustomOutlineButton())
                .previewDisplayName("CustomOutlineButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Outline Disabled") { print("Click") }
                .buttonStyle(CustomOutlineButton(disabled: true))
                .previewDisplayName("CustomOutlineButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Plain Button") { print("Click") }
                .buttonStyle(CustomPlainButton())
                .previewDisplayName("CustomPlainButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Plain Disabled") { print("Click") }
                .buttonStyle(CustomPlainButton(disabled: true))
                .previewDisplayName("CustomPlainButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
        }

    }
}
