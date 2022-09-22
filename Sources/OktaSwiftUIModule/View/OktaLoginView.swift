//
//  SwiftUIView.swift
//
//
//  Created by Nathan DeGroff on 12/10/21.
//
import SwiftUI
import LocalAuthentication

// NOTE: Need this to make sure only iOS compile creates view
// System will fail compile because macOS doesn't support a few SwiftUI methods
#if !os(macOS)

/**
 * Login View
 * Handle Username / password
 */
public struct OktaLoginView: View {
    var demoMode: Bool
    var isLoginEnabled: Bool
    var msg: String
    var biometricType: LABiometryType?
    var onLoginClick: (_ name: String, _ cred: String) -> Void
    var onDemoModeClick: () -> Void
    var onTapUseBiometricCredentials: (() -> Void)?
    
    @State var name: String = ""
    @State var cred: String = ""
    @State var demoAccept = false

    
    public init(demoMode: Bool,
                isLoginEnabled: Bool,
                msg: String = "Welcome!",
                biometricType: LABiometryType? = nil,
                onLoginClick: @escaping (_ name: String, _ cred: String) -> Void,
                onDemoModeClick: @escaping () -> Void,
                onTapUseBiometricCredentials: (() -> Void)? = nil) {
        self.onLoginClick = onLoginClick
        self.onDemoModeClick = onDemoModeClick
        self.demoMode = demoMode
        self.isLoginEnabled = isLoginEnabled
        self.msg = msg
        self.onTapUseBiometricCredentials = onTapUseBiometricCredentials
        self.biometricType = biometricType
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
                
                //-----------------------------------------------
                // Draw Biometric credentials button to allow user to
                // start the biometric process
                if let bioType = biometricType {
                    BiometricLogin(biometricType: bioType, onTap: onTapUseBiometricCredentials)
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
                .btnFilled(isLoginEnabled == false)
                .disabled(isLoginEnabled == false)
                .accessibilityLabel("Sign In")
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("Button-SignIn-ID")
                
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

/**
 Fragment that shows a prompt that the user can interact with to initiate the biometric login process
 */
struct BiometricLogin: View {
    var biometricType: LABiometryType
    var onTap : (() -> Void)?
    var body: some View {
        HStack(spacing: 0) {
            
            switch biometricType {
            case .none:
                Image(systemName: "faceid")
                    .font(K.BrandFont.medium20)
                Text("/")
                    .font(K.BrandFont.medium20)
                Image(systemName: "touchid")
                    .font(K.BrandFont.medium20)
                Button(action: onTap ?? {} ){
                    Text("Use Biometric")
                        .font(K.BrandFont.medium17)
                        .tracking(0.30)
                        .foregroundColor(K.BrandColor.blue2)
                        .padding(.leading, 7)
                        
                }
            case .touchID:
                Image(systemName: "touchid")
                    .font(K.BrandFont.medium20)
                Button(action: onTap ?? {} ){
                    Text("Use Touch ID")
                        .font(K.BrandFont.medium17)
                        .tracking(0.30)
                        .foregroundColor(K.BrandColor.blue2)
                        .padding(.leading, 7)
                }
            case .faceID:
                Image(systemName: "faceid")
                    .font(K.BrandFont.medium20)
                Button(action: onTap ?? {} ){
                    Text("Use Face ID")
                        .font(K.BrandFont.medium17)
                        .tracking(0.30)
                        .foregroundColor(K.BrandColor.blue2)
                        .padding(.leading, 7)
                }
            @unknown default:
                Text("Unknown Biometric Option")
                    .font(K.BrandFont.medium17)
                    .tracking(0.30)
                    .foregroundColor(K.BrandColor.blue2)
                    .padding(.leading, 7)
            }
            
            Spacer()
        }
        .padding(.top, 5)
        .padding(.leading, 5)
    
        Spacer()
        
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
        let onTapUseBiometricCredentials = { () -> Void in }
        
        Group {
            OktaLoginView( demoMode: false,
                           isLoginEnabled: true,
                           biometricType: LABiometryType.none,
                           onLoginClick: onLoginClick,
                           onDemoModeClick: onDemoModeClick,
                           onTapUseBiometricCredentials: onTapUseBiometricCredentials )
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
            .previewDisplayName("Light Mode")
            .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                           isLoginEnabled: true,
                           biometricType: .touchID,
                           onLoginClick: onLoginClick,
                           onDemoModeClick: onDemoModeClick,
                           onTapUseBiometricCredentials: onTapUseBiometricCredentials )
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
            .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                           isLoginEnabled: true,
                           biometricType: .faceID,
                           onLoginClick: onLoginClick,
                           onDemoModeClick: onDemoModeClick,
                           onTapUseBiometricCredentials: onTapUseBiometricCredentials )
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
            .previewDisplayName("Face ID Mode")
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
                           isLoginEnabled: true,
                           onLoginClick: onLoginClick,
                           onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraSmall)
                .previewDisplayName("Dynamic: Extra Small")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                           isLoginEnabled: true,
                           onLoginClick: onLoginClick,
                           onDemoModeClick: onDemoModeClick )
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewDisplayName("Dynamic: XXXLarge")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaLoginView( demoMode: false,
                           isLoginEnabled: true,
                           onLoginClick: onLoginClick,
                           onDemoModeClick: onDemoModeClick )
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
