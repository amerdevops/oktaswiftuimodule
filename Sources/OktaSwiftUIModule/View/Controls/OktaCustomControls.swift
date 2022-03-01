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
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    
    var isDark : Bool { return colorScheme == .dark }
    var buttonColor : Color {
        return (disabled ?
                    K.getColor(.primaryLightGrey, isDark) :
                    K.getColor(.blue, isDark))
    }
    

    init( disabled: Bool = false ) {
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
    @Environment(\.colorScheme) var colorScheme
    let disabled: Bool
    
    var isDark : Bool { return colorScheme == .dark }
    var buttonColor : Color {
        return (disabled ?
                    K.getColor(.primaryLightGrey, isDark) :
                    K.getColor(.blue, isDark))
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
    
    var title: String
    @Binding var text: String
    var aLabel: String = "Accessibility Label Secure"
    var aID: String = "A-Secure-ID"
    @State private var isSecured: Bool = true
    
    init(_ title: String, _ text: Binding<String>,
         _ aLabel: String, _ aID: String) {
        self.title = title
        self._text = text
        self.aLabel = aLabel
        self.aID = aID
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(title, text: $text).placeholder(when: text.isEmpty) {
                    SuperTextField(title: title, text: $text, aLabel: aLabel, aID: aID)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityValue("Secure Text Field")
                .accessibilityLabel(aLabel)
            } else {
                SuperTextField(title: title, text: $text, aLabel: aLabel, aID: aID)
            }
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(self.isSecured ? "Show Password" : "Hide Password")
            .accessibilityAddTraits(.isButton)
        }
    }
}

/**
 * SuperTextField
 * @see https://medium.com/app-makers/how-to-use-textfield-in-swiftui-2fc0ca00f75b
 */

struct SuperTextField: View {
    
    var title: String
    @Binding var text: String
    var aLabel: String = "Accessibility Label"
    var aID: String = "A-ID"
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(title).bodyGreyReg()
                    .accessibilityHidden(true)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .bodyContrast()
                .accessibilityLabel(aLabel)
                .accessibilityIdentifier(aID)
        }
    }
    
}


//---------------------------------------------------------
// Previews
//---------------------------------------------------------
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

struct CustomOutlineButton_Dark_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button("Custom Button") { print("Click") }
                .buttonStyle(CustomButton())
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomButton()")
                .previewLayout(PreviewLayout.sizeThatFits)
            Button("Custom Disabled") { print("Click") }
                .buttonStyle(CustomButton(disabled: true))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomButton() Disabled")
                .previewLayout(PreviewLayout.sizeThatFits)
            Button("Outline Button") { print("Click") }
                .buttonStyle(CustomOutlineButton())
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomOutlineButton Dark")
                .previewLayout(PreviewLayout.sizeThatFits)
            Button("Outline Disabled") { print("Click") }
                .buttonStyle(CustomOutlineButton(disabled: true))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomOutlineButton Dark")
                .previewLayout(PreviewLayout.sizeThatFits)
            Button("Plain Button") { print("Click") }
                .buttonStyle(CustomPlainButton())
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomPlainButton Dark")
                .previewLayout(PreviewLayout.sizeThatFits)
            Button("Plain Disabled") { print("Click") }
                .buttonStyle(CustomPlainButton(disabled: true))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("CustomPlainButton Dark")
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
//---------------------------------------------------------
// Previews
//---------------------------------------------------------

/**
 * SecureInputView Previews
 */
struct SecureInputView_Previews: PreviewProvider {
    
    @State static private var text = "JoeSmith"
    @State static private var textBlank = ""
    static var previews: some View {
        Group {
            SuperTextField(title: "Add Username", text: $textBlank,
                        aLabel: "lbl", aID: "id")
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Blank Text Placeholder")
            SuperTextField(title: "Add Username", text: $text,
                        aLabel: "lbl", aID: "id")
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Filled Text")
            SecureInputView("Add Password", $textBlank, "lbl", "ID")
                          .previewLayout(PreviewLayout.sizeThatFits)
                          .previewDisplayName("Blank Secure Text")
            SecureInputView("Add Username", $text, "lbl", "ID")
                          .previewLayout(PreviewLayout.sizeThatFits)
                          .previewDisplayName("Filled Secure Text")
        }

    }
}
