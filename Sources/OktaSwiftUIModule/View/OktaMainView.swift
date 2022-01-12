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
        NavigationView {
            ZStack {
                //-----------------------------------------------------
                // Passed login and passed mfa
                if ( isMFA && isAuthenticated ) {
                    VStack {
                        Text("Should not be here... Navigation Container should handle")
                    }
                }
                //-----------------------------------------------------
                // Logged in, but not passed MFA
                else if ( isMFA ) {
                    //-----------------------------------------------------
                    // Define the actions outside of view so it can be tested
                    // separately
                    let onSendCodeClick = { ( factor: OktaFactor, isResend: Bool) -> Void in
                        if(!isResend) {
                            oktaViewModel.sendFactor(factor: factor)
                            logger.log("Send Code: \(factor.type.rawValue)")
                        } else {
                            oktaViewModel.resendFactor(factor: factor)
                            logger.log("Resend Code: \(factor.type.rawValue)")
                        }
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
                }
            }
        }
    }
}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
struct OktaMainView_Previews: PreviewProvider {
    static var previews: some View {
        let oktaViewModel = OktaViewModel(MockOktaRepositoryImpl(), true)
        OktaMainView()
            .environmentObject(oktaViewModel)
    }
}
#endif
