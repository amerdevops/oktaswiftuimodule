//
//  SwiftUIView.swift
//  
//
//  Created by Nathan DeGroff on 12/10/21.
//

import SwiftUI

import SwiftUI
import OktaOidc
import OktaAuthNative
import os

// NOTE: Need this to make sure only iOS compile creates view
// System will fail compile because macOS doesn't support a few SwiftUI methods
#if !os(macOS)

/**
 * Main MFA View
 * This view allows the user to select which method of MFA they would like to use and also
 * allows them to trigger the push and/or verify the code
 */
public struct OktaMFAView: View {
    var onSendCodeClick: (_ factor: OktaFactor, _ isResend: Bool) -> Void
    var onVerifyClick: (_ passCode: String) -> Void
    var onCancelClick: () -> Void
    var factors = [OktaFactor]()
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaMFASelectView")
    
    @State var selectedFactor: OktaFactor? = nil

    /**
     * Initialize the class
     */
    public init( factors: [OktaFactor],
        onSendCodeClick: @escaping (_ factor: OktaFactor, _ isResend: Bool) -> Void,
        onVerifyClick: @escaping (_ passCode: String) -> Void,
        onCancelClick: @escaping () -> Void) {
        self.onSendCodeClick = onSendCodeClick
        self.onVerifyClick = onVerifyClick
        self.onCancelClick = onCancelClick
        self.factors.removeAll()
        self.factors.append(contentsOf: factors)
    }

    /**
     * Primary SwiftUI Render method
     * Draw the view (either select which MFA factor to use or the specific MFA factor
     */
    public var body: some View {
        if let factor = selectedFactor {
            // Draw the specific factor screen
            OktaMFAPushView(factor: factor,
                        onSendCodeClick: onSendCodeClick,
                        onVerifyClick: onVerifyClick,
                        onGoBack: {
                            logger.log("Clicked goBack()")
                            selectedFactor = nil
                            onCancelClick()
                        })
        } else {
            // Select MFA option
            OktaMFASelectView(factors: self.factors,
                          onSelectFactor: { ( factor: OktaFactor ) -> Void in
                self.selectedFactor = factor
                onSendCodeClick(factor, false)
            } )
        }
    }
}

/**
 * Unique Okta Factor for drawing with ForEach
 */
struct UniqueOktaFactor: Identifiable {
    let id = UUID()
    var factor: OktaFactor
}

/**
 * Select which MFA option should be used
 */
public struct OktaMFASelectView: View {
    var onSelectFactor: (_ factor: OktaFactor) -> Void
    var uFactors: [UniqueOktaFactor] = []
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaMFASelectView")
    
    /**
     * Initialize MFASelectView with factors and the event when selecting a factor
     */
    public init( factors: [OktaFactor],
          onSelectFactor: @escaping (_ factor: OktaFactor ) -> Void) {
        self.onSelectFactor = onSelectFactor
        self.uFactors.removeAll()
        factors.forEach { factor in
            self.uFactors.append(UniqueOktaFactor(factor: factor))
        }
    }

    public var body: some View {
        VStack(alignment: .center) {
            Text("Select MFA factor: ")
                .foregroundColor(Color.white)
            ForEach(uFactors, id: \.id) { uFactor in
                Button(uFactor.factor.type.rawValue) {
                    logger.log("Clicked on \(uFactor.factor.type.rawValue, privacy: .public)")
                    onSelectFactor( uFactor.factor )
                }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
            }
        }
        .frame(maxWidth: 300, maxHeight: 470, alignment: .center)
        .cornerRadius(5)
    }
    

}



/**
 * Handle MFA transactions
 */
public struct OktaMFAPushView: View {
    var onSendCodeClick: (_ factor: OktaFactor, _ isResend: Bool) -> Void = {_,_ in }
    var onVerifyClick: (_ passCode: String) -> Void = {_ in }
    var onGoBack: () -> Void = {}
    var factor: OktaFactor? = nil
    @State var passCode: String = ""
    
    public init( factor: OktaFactor,
        onSendCodeClick: @escaping (_ factor: OktaFactor, _ isResend: Bool) -> Void,
        onVerifyClick: @escaping (_ passCode: String) -> Void,
        onGoBack: @escaping () -> Void) {
        self.factor = factor
        self.onSendCodeClick = onSendCodeClick
        self.onVerifyClick = onVerifyClick
        self.onGoBack = onGoBack
    }
    
    @ViewBuilder
    public var body: some View {

        VStack{
            let sendButtonText = "Resend Code"

            if let fac = factor {
                switch fac.type {
                case FactorType.email:
                    Text("Email: \(fac.profile?.email ?? "unknown")")
                        .foregroundColor(Color.white)
                case FactorType.sms:
                    Text("SMS: \(fac.profile?.phoneNumber ?? "unknown")")
                        .foregroundColor(Color.white)
                case FactorType.call:
                    Text("Call: \(fac.profile?.phoneNumber ?? "unknown")")
                        .foregroundColor(Color.white)
                default:
                    Text("Default")
                        .foregroundColor(Color.white)
                }
                TextField("Passcode", text: $passCode)
                        .background(Color(.systemBackground))
                        .padding()
                        .border(Color.black)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                Button("Verify") { self.onVerifyClick(passCode) }
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(RoundedRectangle(cornerRadius: 8).fill(buttonColor(passCode.isEmpty)))
                    .disabled( passCode.isEmpty )
                Button(sendButtonText) { self.onSendCodeClick(fac, true) }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                Button("Go Back") { self.onGoBack() }
                    .padding()
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                
            } else {
                Text("Loading...")
            }
        }
        .frame(maxWidth: 300, maxHeight: 470, alignment: .center)
        .cornerRadius(5)
    }
    
    func buttonColor(_ disabled: Bool) -> Color {
        return (disabled ? Color.gray : Color.blue)
    }
}




//---------------------------------------------------------
// Previews
//---------------------------------------------------------
/**
 * MFAView Previews
 */
struct OktaMFAView_Previews: PreviewProvider {

    static func onSendCodeClick( factor: OktaFactor, isResend: Bool ) {
        // Do Nothing
    }
    static func onVerifyClick(passCode: String) {
        // Do Nothing
    }
    static func onCancelClick() {
        // Do Nothing
    }
    
    static var previews: some View {
        //-----------------------------------------------------
        // Get Factors
        let factors = OktaUtilMocks.getOktaFactors()
        Group {
            OktaMFAView(factors: factors,
                    onSendCodeClick: onSendCodeClick,
                    onVerifyClick: onVerifyClick,
                    onCancelClick: onCancelClick)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                //.background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode MFAView")
            
            OktaMFAView(factors: factors,
                    onSendCodeClick: onSendCodeClick,
                    onVerifyClick: onVerifyClick,
                    onCancelClick: onCancelClick)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode MFAView")
            
        }

    }
}

/**
 * MFAView Previews
 */
struct OktaMFAPushView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let factor = OktaUtilMocks.getOktaFactor()
        Group {
            OktaMFAPushView(factor: factor,
                        onSendCodeClick: OktaMFAView_Previews.onSendCodeClick,
                        onVerifyClick: OktaMFAView_Previews.onVerifyClick,
                        onGoBack: OktaMFAView_Previews.onCancelClick)
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    //.background(Color(.systemBackground))
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("Light Mode MFAPushView")
            OktaMFAPushView(factor: factor,
                        onSendCodeClick: OktaMFAView_Previews.onSendCodeClick,
                        onVerifyClick: OktaMFAView_Previews.onVerifyClick,
                        onGoBack: OktaMFAView_Previews.onCancelClick)
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    //.background(Color(.systemBackground))
                    .environment(\.colorScheme, .dark)
                    .previewDisplayName("Dark Mode MFAPushView")
        }

    }
}

#endif
