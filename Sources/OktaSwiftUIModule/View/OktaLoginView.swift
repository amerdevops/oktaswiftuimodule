//
//  SwiftUIView.swift
//  
//
//  Created by Nathan DeGroff on 12/10/21.
//
import SwiftUI

// NOTE: Need this to make sure only iOS compile creates view
// System will fail compile because macOS doesn't support a few SwiftUI methods
#if !os(macOS)

/**
 * Login View
 * Handle Username / password
 */
public struct OktaLoginView: View {
    var onLoginClick: (_ name: String, _ cred: String) -> Void
    var onDemoModeClick: () -> Void
    var demoMode: Bool
    var msg: String
    
    @State var name: String = ""
    @State var cred: String = ""
    @State var acceptTAndC = false
    @State var demoAccept = false
    
    public init(demoMode: Bool,
                onLoginClick: @escaping (_ name: String, _ cred: String) -> Void,
                onDemoModeClick: @escaping () -> Void,
                msg: String = "Welcome") {
        self.onLoginClick = onLoginClick
        self.onDemoModeClick = onDemoModeClick
        self.demoMode = demoMode
        self.msg = msg
        UINavigationBar.appearance().backgroundColor = .none
    }

    /**
     * Primary SwiftUI Render method
     * Allow the client to login with name / password
     */
    public var body: some View {
        VStack(alignment: .center, spacing: 50) {
            //-----------------------------------------------
            // Draw Welcome
            Text(msg)
                .titleContrast()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(alignment: .center)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(msg)
                .accessibilityIdentifier("Welcome-ID")
            
            Text("Sign in to receive your access code.")
                .headlineDark()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(alignment: .center)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Sign in to receive your access code.")
                .accessibilityIdentifier("Second-Msg-ID")
                
            //-----------------------------------------------
            // Draw username / password
            VStack {
                HStack() {
                    Text("ID")
                        .labelDark()
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                        .accessibilityHidden(true)
                    
                    SuperTextField(title: "Add UserName", text: $name, aLabel: "Add UserName", aID: "Text-ID")
                    
                }
                Divider()
                HStack() {
                    Text("Password")
                        .labelDark()
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                        .accessibilityHidden(true)
                    SecureInputView("Add Password", $cred,
                                          "Add Password", "Text-Password")
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                Divider()
            }
            
            VStack {
                //-----------------------------------------------
                // Draw Login Button
                Button("Sign In") {
                    print("Pressing Login button...")
                    //-----------------------------------------------
                    // If demo mode is available and was selected...
                    if demoMode && demoAccept {
                        self.onDemoModeClick()
                    }
                    //-----------------------------------------------
                    // Otherwise, login like normal
                    else {
                        self.onLoginClick(name, cred)
                    }
                }
                .buttonStyle(CustomButton(disabled: acceptTAndC == false))
                .disabled(acceptTAndC == false)
                .accessibilityLabel("Sign In")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("Button-SignIn-ID")
                
                //-----------------------------------------------
                // Draw face ID / Forgot Password
                HStack(spacing: 50) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("FaceID")
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Face I D")
                    .accessibilityIdentifier("FaceID-ID")
                    
                    Text("Forgot Password")
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Forgot Password")
                        .accessibilityIdentifier("Forgot-Pass-ID")
                }
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                .frame(maxWidth: .infinity)
            
                //-----------------------------------------------
                // Draw Accept Terms / Conditions
                Button(action: { acceptTAndC = !acceptTAndC }){
                    HStack{
                        Toggle("", isOn: $acceptTAndC)
                            .labelsHidden()
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        Text("I accept Ameritas Terms and Conditions")
                            .footnote()
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Accept Terms and Conditions")
                .accessibilityValue(acceptTAndC ? "On" : "Off")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("Button-Accept-TC-ID")
                //-----------------------------------------------
                // Draw DemoMode Switch (if Applicable)
                if demoMode {
                    Toggle(isOn: $demoAccept) {
                        Text("Demo Mode")
                    }
                    .accessibilityLabel("Demo Mode")
                    .accessibilityValue(demoAccept ? "On" : "Off")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Demo-ID")
                }
            }
            Spacer()
        }
        //.frame(maxWidth: 300, maxHeight: 470, alignment: .top)
        .frame(maxWidth: 300, alignment: .top)
        .cornerRadius(5)
        
    }

}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
/**
 * Preview Login View
 */
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let onLoginClick = { ( name: String, cred: String) -> Void in
            print("\(name), \(cred)")
        }
        let onDemoModeClick = { () -> Void in
        }
        Group {
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
/**
 * Show Dynamic text views
 */
struct LoginView_DyanmicTxt_Previews: PreviewProvider {
    static var previews: some View {
        let onLoginClick = { ( name: String, cred: String) -> Void in
            print("\(name), \(cred)")
        }
        let onDemoModeClick = { () -> Void in
        }
        Group {
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraSmall)
                .previewDisplayName("Dynamic: Extra Small")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewDisplayName("Dynamic: Extra Large")
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
#endif
