//
//  OktaCustomTextField.swift
//  
//
//  Created by Nathan DeGroff on 3/2/22.
//

import SwiftUI
import os

/**
 * CustomTextField
 * This SwiftUI view wraps the Custom UIKitTextField.  This gives us much more control
 * over how the text field is stylized than a SwiftUI TextField that meets accessibility audit reports.
 */
struct CustomTextField: View {
    
    var title: String
    @Binding var text: String
    var aLabel: String = "Accessibility Label"
    var aID: String = "A-ID"

    var body: some View {
        OktaUIKitTextField(title, text: $text)
            // Make sure height is minimum 44 so Hit area is acceptable
            .frame(minHeight: 44, maxHeight: 100)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(aLabel)
            .accessibilityIdentifier(aID)
    }
    
}

/**
 * Custom SecureView
 * iOS doesn't have a password field that allows you to show / hide your view
 * Got code for this view from https://stackoverflow.com/questions/63095851/show-hide-password-how-can-i-add-this-feature
 */
struct CustomSecureInput: View {
    @Environment(\.colorScheme) var colorScheme
    
    var title: String
    @Binding var text: String
    var aLabel: String = "Accessibility Label Secure"
    var aID: String = "A-Secure-ID"
    
    var isDark : Bool { return colorScheme == .dark }
    
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
                    CustomTextField(title: title, text: $text, aLabel: aLabel, aID: aID)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityValue("Secure Text Field")
                .accessibilityLabel(aLabel)
            } else {
                CustomTextField(title: title, text: $text, aLabel: aLabel, aID: aID)
            }
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(K.getColor(.primaryLightGrey, isDark))
                    .padding(10)
            }
            .bodyGreyReg()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(self.isSecured ? "Show Password" : "Hide Password")
            .accessibilityAddTraits(.isButton)
        }
    }
}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------

/**
 * SecureInputView Previews
 */
struct CustomTextView_Previews: PreviewProvider {
    
    @State static private var text = "JoeSmith"
    @State static private var textBlank = ""
    static var previews: some View {
        Group {
            CustomTextField(title: "Add Username", text: $textBlank,
                        aLabel: "lbl", aID: "id")
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Blank Text Placeholder")
            CustomTextField(title: "Add Username", text: $text,
                        aLabel: "lbl", aID: "id")
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Filled Text")
        }

    }
}

/**
 * CustomSecureInput Previews
 */
struct CustomSecureInput_Previews: PreviewProvider {
    
    @State static private var text = "JoeSmith"
    @State static private var textBlank = ""
    static var previews: some View {
        Group {
            CustomSecureInput("Add Password", $textBlank, "lbl", "ID")
                          .previewLayout(PreviewLayout.sizeThatFits)
                          .previewDisplayName("Blank Secure Text")
            CustomSecureInput("Add Username", $text, "lbl", "ID")
                          .previewLayout(PreviewLayout.sizeThatFits)
                          .previewDisplayName("Filled Secure Text")
        }

    }
}
