//
//  OktaMainView.swift
//  OktaSwiftUIModule
//
//  Created by Nathan DeGroff on 11/19/21.
//

import SwiftUI
import OktaAuthNative
import os

// NOTE: Need this to make sure only iOS compile creates view
// System will fail compile because macOS doesn't support a few SwiftUI methods
#if !os(macOS)
/**
 * Primary Okta View
 * This view holds the primary Okta screens and handles navigating between login and MFA views.
 */
public struct OktaMainView: View {
    
    @ScaledMetric var heightPad: CGFloat = UIScreen.main.bounds.height * 0.1
    
    @EnvironmentObject
    var oktaViewModel: OktaViewModel
    
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaMainView")
    
    var demoMode: Bool
    // This lets us dismiss the screen when the back nav button is clicked
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /**
     * Initialize the class
     */
    public init(demoMode: Bool = false) {
        self.demoMode = demoMode
    }
    
    /**
     * Primary SwiftUI Render method
     * Decide whether to render the Login view or the MFA view
     */
    public var body: some View {
        let isAuthenticated = oktaViewModel.isAuthenticated
        let isMFA = oktaViewModel.isMFA
        ScrollView {
            VStack(spacing: 0) {
                //-----------------------------------------------
                // Draw Logo
                Image("agent-app-logo").background(Color.white)
                    .accessibilityLabel("Ameritas Logo")
                    .accessibilityAddTraits(.isImage)
                
                //-----------------------------------------------------
                // Passed login and passed mfa
                if ( isMFA && isAuthenticated ) {
                    VStack {
                        Text("Retrieving user info...")
                    }
                }
                //-----------------------------------------------------
                // Logged in, but not passed MFA
                else if ( isMFA ) {
                    //-----------------------------------------------------
                    // Define the actions outside of view so it can be tested
                    // separately
                    let onSendCodeClick = { ( factor: OktaFactor, isChange: Bool) -> Void in
                        // NOTE: Not using isChange now... this will be
                        // if Okta can fix sending a different MFA factor
                        oktaViewModel.sendFactor(factor: factor)
                        logger.log("Send Code: \(factor.type.rawValue)")
                    }
                    let onResendClick = { ( factor: OktaFactor ) -> Void in
                        oktaViewModel.resendFactor(factor: factor)
                        logger.log("Resend Code: \(factor.type.rawValue)")
                    }
                    let onCancelClick = { () -> Void in
                        oktaViewModel.cancelFactor()
                        logger.log("Cancel MFA")
                    }
                    let onVerifyClick = { (passCode: String) -> Void in
                        oktaViewModel.verifyFactor(passCode: passCode)
                        logger.log("Verify Click: [\(passCode)]")
                    }

                    //-----------------------------------------------------
                    // Draw view
                    OktaMFAView(factors: oktaViewModel.factors,
                            onSendCodeClick: onSendCodeClick,
                            onResendClick: onResendClick,
                            onVerifyClick: onVerifyClick,
                            onCancelClick: onCancelClick)
                }
                //-----------------------------------------------------
                // Have not logged in yet
                else {
                    //-----------------------------------------------------
                    // Define the actions outside of view so it can be tested
                    // separately
                    let onLoginClick = { ( name: String, cred: String) -> Void in
                        oktaViewModel.signIn(name: name, cred: cred)
                    }
                    let onDemoModeClick =  { () -> Void in
                        oktaViewModel.demoMode()
                    }
                    
                    //-----------------------------------------------------
                    // Draw view
                    OktaLoginView(demoMode: demoMode,
                                  onLoginClick: onLoginClick,
                                  onDemoModeClick: onDemoModeClick)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
            .padding(EdgeInsets(top: heightPad, leading: 0, bottom: 0, trailing: 0))
        }
        .edgesIgnoringSafeArea(.top)
    }
}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
/**
 * Mock Okta ViewModel for preview sake
 */
class MockOktaViewModel : OktaViewModel {
    
    init(isMFA: Bool = false, isAuthenticated: Bool = false, isUserSet: Bool = false) {
        super.init(MockOktaRepositoryImpl(), true)
        super.isMFA = isMFA
        super.isAuthenticated = isAuthenticated
        super.isUserSet = isUserSet
        super.factors = OktaUtilMocks.getOktaFactors()
    }
}

/**
 * PREVIEW: iPhone12 previews
 */
struct OktaMainView_iPhone12_Login_Previews: PreviewProvider {
    static var previews: some View {
        let oktaViewModel : OktaViewModel = MockOktaViewModel()
        Group {
            OktaMainView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .environmentObject(oktaViewModel)
                .previewDisplayName("Login Light Mode (iPhone 12)")
            
            OktaMainView()
                .preferredColorScheme(.dark)
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .environmentObject(oktaViewModel)
                .previewDisplayName("Login Dark Mode (iPhone 12)")
            OktaMainView()
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .environment(\.colorScheme, .dark)
                .environmentObject(oktaViewModel)
                .previewDisplayName("MFA Dark Mode SUPER MEGA Extra Extra large")
        }
    }
}

/**
 * PREVIEW: iPod previews
 */
struct OktaMainView_iPod_Login_Previews: PreviewProvider {
    static var previews: some View {
        let oktaViewModel : OktaViewModel = MockOktaViewModel()
        Group {
            OktaMainView()
                .previewDevice(PreviewDevice(rawValue: "iPod touch"))
                .environmentObject(oktaViewModel)
                .previewDisplayName("Login Light Mode (iPod touch)")
            
            OktaMainView()
                .preferredColorScheme(.dark)
                .previewDevice(PreviewDevice(rawValue: "iPod touch"))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .environmentObject(oktaViewModel)
                .previewDisplayName("Login Dark Mode (iPod touch)")
        }
    }
}

struct OktaMainView_MFA_Previews: PreviewProvider {

    static var previews: some View {
        let oktaViewModel : OktaViewModel = MockOktaViewModel(isMFA: true)
        Group {
            OktaMainView()
                .environmentObject(oktaViewModel)
                .previewDisplayName("MFA Light Mode")
            
            OktaMainView()
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .environmentObject(oktaViewModel)
                .previewDisplayName("MFA Dark Mode")
            
            OktaMainView()
                .preferredColorScheme(.dark)
                .background(Color(.systemBackground))
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .environment(\.colorScheme, .dark)
                .environmentObject(oktaViewModel)
                .previewDisplayName("MFA Dark Mode Extra large")
        }
    }
}
#endif
