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
                msg: String = "Welcome to the Agent App") {
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
                .modifier(K.BrandFontMod.contrast)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .accessibilityLabel(msg)
                .accessibilityAddTraits(.isStaticText)
                .accessibilityIdentifier("Welcome")
                
            //-----------------------------------------------
            // Draw username / password
            VStack {
                HStack() {
                    Text("ID")
                        .modifier(K.BrandFontMod.label)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                        .accessibilityLabel("ID")
                        .accessibilityAddTraits(.isStaticText)
                        .accessibilityIdentifier("Label-ID")

                    TextField("Add UserName", text: $name)
                        .modifier(K.BrandFontMod.contrast)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityLabel("Enter your username")
                        //.accessibilityAddTraits(.isStaticText)
                        .accessibilityIdentifier("Text-ID")
                    
                }
                Divider()
                HStack() {
                    Text("Password")
                        .modifier(K.BrandFontMod.label)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                        .accessibilityLabel("Password")
                        .accessibilityAddTraits(.isStaticText)
                        .accessibilityIdentifier("Label-Pass")
                    SecureInputView("Add Password", text: $cred)
                        .modifier(K.BrandFontMod.contrast)
                        .accessibilityLabel("Enter your password")
                        //.accessibilityAddTraits(.isStaticText)
                        .accessibilityIdentifier("Text-Pass")
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
                .accessibilityIdentifier("Button-SignIn")
                
                //-----------------------------------------------
                // Draw face ID / Forgot Password
                HStack(spacing: 50) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("FaceID")
                    }
                    
                    Text("Forgot Password")
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
                            .modifier(K.BrandFontMod.supplemental)
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    }
                    .frame(maxWidth: .infinity)
                }
                .accessibilityLabel("Accept Terms and Conditions")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("Button-Accept")
                //-----------------------------------------------
                // Draw DemoMode Switch (if Applicable)
                if demoMode {
                    Toggle(isOn: $demoAccept) {
                        Text("Demo Mode")
                    }
                    .accessibilityLabel("Demo Mode")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Demo")
                }
            }
            Spacer()
        }
        //.frame(maxWidth: 300, maxHeight: 470, alignment: .top)
        .frame(maxWidth: 300, alignment: .top)
        .cornerRadius(5)
        
    }
    
    var buttonColor : Color {
        return (acceptTAndC ? Color.blue : Color.gray)
    }

}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
/**
 * Preview Login View
 */
struct LoginView_DemoMode_Previews: PreviewProvider {

    static var previews: some View {
        let onLoginClick = { ( name: String, cred: String) -> Void in
            print("\(name), \(cred)")
        }
        let onDemoModeClick = { () -> Void in
            print("demo mode")
        }
        Group {
            OktaLoginView( demoMode: true,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Demo Mode: Light Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
            
            OktaLoginView( demoMode: true,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Demo Mode: Dark Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
        }
        
    }
}
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
#endif
