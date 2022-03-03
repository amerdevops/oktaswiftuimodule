//
//  OktaCustomButtons.swift
//  
//
//  Created by Nathan DeGroff on 3/3/22.
//

import SwiftUI
import os

/**
 * Custom Button - Filled button style
 */
struct CustomFilledButton: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    
    var isDark : Bool { return colorScheme == .dark }
    var buttonColor : Color {
        return (disabled ?
                    K.getColor(.primaryLightGrey, isDark) :
                    K.getColor(.blue, isDark))
    }

    init( _ disabled: Bool = false ) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bodyReverse()
            .padding()
            .frame(maxWidth: 322, maxHeight: 50)
            .background(RoundedRectangle(cornerRadius: 8).fill(buttonColor))
    }
}

/**
 * Custom Outline Button - Button with outline style
 */
struct CustomOutlineButton: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    
    var isDark : Bool { return colorScheme == .dark }
    var buttonColor : Color {
        return (disabled ?
                    K.getColor(.primaryLightGrey, isDark) :
                    K.getColor(.blue, isDark))
    }

    init( _ disabled: Bool = false ) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(buttonColor)
            .frame(maxWidth: 290, maxHeight: 50)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(buttonColor, lineWidth: 2))
    }
}

/**
 * Custom Plain Button - Button with no body / border.. just text and click area like other
 * custom buttons
 */
struct CustomPlainButton: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    
    var isDark : Bool { return colorScheme == .dark }
    var buttonColor : Color {
        return (disabled ?
                    K.getColor(.primaryLightGrey, isDark) :
                    K.getColor(.blue, isDark))
    }

    init( _ disabled: Bool = false ) {
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(buttonColor)
            .frame(maxWidth: 290, maxHeight: 50)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemBackground), lineWidth: 5))
    }
}

extension Button {
    func btnFilled(_ disabled: Bool = false ) -> some View { self.buttonStyle(CustomFilledButton(disabled)) }
    func btnOutline(_ disabled: Bool = false ) -> some View { self.buttonStyle(CustomOutlineButton(disabled)) }
    func btnPlain(_ disabled: Bool = false ) -> some View { self.buttonStyle(CustomPlainButton(disabled)) }
}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
struct CustomOutlineButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button("Custom Button") { print("Click") }
                .btnFilled()
                .previewDisplayName("CustomButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Custom Disabled") { print("Click") }
                .btnFilled(true)
                .previewDisplayName("CustomButton() Disabled")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Outline Button") { print("Click") }
                .btnOutline()
                .previewDisplayName("CustomOutlineButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Outline Disabled") { print("Click") }
                .btnOutline(true)
                .previewDisplayName("CustomOutlineButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Plain Button") { print("Click") }
                .btnPlain()
                .previewDisplayName("CustomPlainButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Plain Disabled") { print("Click") }
                .btnPlain(true)
                .previewDisplayName("CustomPlainButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
        }
    }
}

struct CustomOutlineButton_Dark_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button("Custom Button") { print("Click") }
                .btnFilled()
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomButton()")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Custom Disabled") { print("Click") }
                .btnFilled(true)
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomButton() Disabled")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Outline Button") { print("Click") }
                .btnOutline()
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomOutlineButton Dark")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Outline Disabled") { print("Click") }
                .btnOutline(true)
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomOutlineButton Dark")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Plain Button") { print("Click") }
                .btnPlain()
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomPlainButton Dark")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
            Button("Plain Disabled") { print("Click") }
                .btnPlain(true)
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomPlainButton Dark")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 70))
        }
    }
}
