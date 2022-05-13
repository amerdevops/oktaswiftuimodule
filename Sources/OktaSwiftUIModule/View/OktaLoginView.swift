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
    var isLoginEnabled: Bool
    
    @State var name: String = ""
    @State var cred: String = ""
    @State var demoAccept = false

    
    public init(demoMode: Bool,
                onLoginClick: @escaping (_ name: String, _ cred: String) -> Void,
                onDemoModeClick: @escaping () -> Void, isLoginEnabled: Bool,
                msg: String = "Welcome!") {
        self.onLoginClick = onLoginClick
        self.onDemoModeClick = onDemoModeClick
        self.demoMode = demoMode
        self.isLoginEnabled = isLoginEnabled
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
                
            //-----------------------------------------------
            // Draw username / password
            VStack {
                if #available(iOS 15.0, *) {
                    OktaBigIDPassView($name, $cred)
                } else {
                    OktaRegularIDPassView($name, $cred)
                }
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
                .accessibilityLabel("Sign In")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("Button-SignIn-ID")
                
                //-----------------------------------------------
                // Draw Accept Terms / Conditions
                
                
                Text("By Signing in, you agree to the [Ameritas Online Privacy Notice](https://www.ameritas.com/about/online-privacy/) and [Legal/Terms of Use](https://www.ameritas.com/about/legal-terms-of-use).")
                    .font(K.BrandFont.regular16)
                    .foregroundColor(K.BrandColor.lightDarkGray)
                    .padding(EdgeInsets(top: 42, leading: 0, bottom: 0, trailing: 0))
                    .fixedSize(horizontal: false, vertical: true)
                
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
                onDemoModeClick: onDemoModeClick, isLoginEnabled: true )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick, isLoginEnabled: true )
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
                           onDemoModeClick: onDemoModeClick, isLoginEnabled: true )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraSmall)
                .previewDisplayName("Dynamic: Extra Small")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick, isLoginEnabled: true )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewDisplayName("Dynamic: XXXLarge")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                onLoginClick: onLoginClick,
                onDemoModeClick: onDemoModeClick, isLoginEnabled: true )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
                .previewDisplayName("Dynamic: SUPER MEGA Extra Extra large")
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
#endif

/**
 * Draw the Name / password
 * Have to separate this out because of Accessibility.  Can't determine dynamic font size unless iOS 15
 * So... we create this abomination and use it when font text is smaller than xxx Large
 */
struct OktaRegularIDPassView: View {
    
    @Binding var name: String
    @Binding var cred: String
    
    init( _ name: Binding<String>,
          _ cred: Binding<String>) {
        self._name = name
        self._cred = cred
    }

   var body: some View {
       VStack {
           HStack() {
               Text("ID")
                   .labelDark()
                   .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                   .frame( width: 90, alignment: .topLeading )
                   .accessibilityHidden(true)
               
               CustomTextField(title: "Add UserName", text: $name, aLabel: "Add UserName", aID: "UserName-Text-ID")
               
           }
           Divider()
           HStack() {
               Text("Password")
                   .labelDark()
                   .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                   .frame( width: 90, alignment: .topLeading )
                   .accessibilityHidden(true)
               CustomSecureInput("Add Password", $cred,
                                     "Add Password", "Text-Password-ID")
           }
           .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
           Divider()
       }
   }
   
}

/**
 * Accessibility Name and Password
 * Draw the ID / Password labels / text fields in vstack rather than next to each other
 * so massively large fonts don't mess up the view
 */
@available(iOS 15, *)
public struct OktaBigIDPassView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dynamicTypeSize) var typeSize
    
    @Binding var name: String
    @Binding var cred: String
    
    init( _ name: Binding<String>,
          _ cred: Binding<String>) {
        self._name = name
        self._cred = cred
    }
    
    /**
     * Determine if we're using a superlarge font
     * change layout to VStack so elements can take up full width
     */
    public var body: some View {
        
        if typeSize > .xxxLarge {
                VStack {
                    Text("ID")
                        .labelDark()
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .accessibilityHidden(true)
                    CustomTextField(title: "Add UserName", text: $name, aLabel: "Add UserName", aID: "Text-ID")
                    Divider()
                    Text("Password")
                        .labelDark()
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .accessibilityHidden(true)
                    CustomSecureInput("Add Password", $cred,
                                          "Add Password", "Text-Password-ID")
                    Divider()
                }
        } else {
            OktaRegularIDPassView($name, $cred)
        }
    }
    
    
}
