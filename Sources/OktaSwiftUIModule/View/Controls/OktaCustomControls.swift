//
//  OktaCustomControls.swift
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
        return (disabled ? Color.gray : K.BrandColor.blue)
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
    }
}

/**
 * Custom Outline Button - Button with outline style
 */
struct CustomOutlineButton: ButtonStyle {
    let disabled: Bool

    var buttonColor : Color {
        return (disabled ? Color.gray : K.BrandColor.blue)
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
    }
}

/**
 * Custom Plain Button - Button with no body / border.. just text and click area like other
 * custom buttons
 */
struct CustomPlainButton: ButtonStyle {
    let disabled: Bool

    var buttonColor : Color {
        return (disabled ? Color.gray : K.BrandColor.blue)
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
    }
}

/**
 * Custom SecureView
 * iOS doesn't have a password field that allows you to show / hide your view
 * Got code for this view from https://stackoverflow.com/questions/63095851/show-hide-password-how-can-i-add-this-feature
 */
struct SecureInputView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}

//------------------------------------------------------------------
// PREVIEWS
//------------------------------------------------------------------
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


/**
 * MFAView Previews
 */
struct SecureInputView_Wrapper : View {
     @State
     private var cred = ""

     var body: some View {
        SecureInputView("Add Password", text: $cred)
            .modifier(K.BrandFontMod.contrast)
     }
}
struct SecureInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SecureInputView_Wrapper()
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Secure Input")
        }

    }
}
