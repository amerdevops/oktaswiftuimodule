//
//  OktaUIKitTextField.swift
//
//  Created by Nathan DeGroff on 3/2/22.
//

import SwiftUI
import UIKit

/**
 * OktaUIKitTextField
 * SwiftUI creates TextFields that fail Accessibility audits for hit area as well as contrast.  In order to make
 * a TextField that allows us to extend the hit area, we need to disable the underlying default Vertical "setContentHuggingPriority".
 *
 * We also need to set the placeholder color to a contrast friendly color
 *
 * Finally, we need to turn off auto correction and auto capitalization
 * @see https://www.fivestars.blog/articles/how-to-customize-textfields/
 * @see [OktaCustomTextField] for SwiftUI Wrapper
 */
struct OktaUIKitTextField: UIViewRepresentable {
    
    var titleKey: String
    @Binding var text: String

    public init(_ titleKey: String, text: Binding<String>) {
        self.titleKey = titleKey
        self._text = text
    }

    /**
     * makeUIView
     * This is where the text field is created and the magic happens
     */
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        // (1) Don't set Vertical Hugging Priority so field can be set bigger
        // textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.placeholder = NSLocalizedString(titleKey, comment: "")
        // (2) Set the placeholder color to the higher contrast grey #767676
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString(titleKey, comment: ""),
            attributes: [.foregroundColor: UIColor(red: 118/255, green: 118/255, blue: 118/255, alpha: 1)]
        )
        // (3) Turn off Auto Capitalization and AutoCorrect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        // (4) Set size to auto adjust to .body text style
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
    return textField
  }

  func updateUIView(_ uiView: UITextField, context: Context) {
    if text != uiView.text {
        uiView.text = text
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  final class Coordinator: NSObject, UITextFieldDelegate {
    var parent: OktaUIKitTextField

    init(_ textField: OktaUIKitTextField) {
      self.parent = textField
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
      guard textField.markedTextRange == nil, parent.text != textField.text else {
        return
      }
      parent.text = textField.text ?? ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }
  }
}
