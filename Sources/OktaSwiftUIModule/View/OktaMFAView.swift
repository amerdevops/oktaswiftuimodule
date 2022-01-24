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
            //-----------------------------------------------
            // Draw Welcome
            Text("Select MFA factor: ")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                .frame(alignment: .center)
            //-----------------------------------------------
            // Draw Factor buttons
            ForEach(uFactors, id: \.id) { uFactor in
                Button(uFactor.factor.type.rawValue) {
                    logger.log("Clicked on \(uFactor.factor.type.rawValue, privacy: .public)")
                    onSelectFactor( uFactor.factor )
                }
                .buttonStyle(CustomButton())
            }
        }
        .frame(maxWidth: 318, maxHeight: 470, alignment: .center)
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
        let sendButtonText = "Resend Code"

        VStack{
            Text("Verify Your Identity.")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                .frame(alignment: .center)
            
            if let fac = factor {
                HStack {
                    switch fac.type {
                    case FactorType.email:
                        Text("Email:")
                            .modifier(K.BrandFontMod.label)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                        Text("\(fac.profile?.email ?? "unknown")")
                            .modifier(K.BrandFontMod.contrast)
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                    case FactorType.sms:
                        Text("SMS:")
                            .modifier(K.BrandFontMod.label)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                        Text("\(fac.profile?.phoneNumber ?? "unknown")")
                            .modifier(K.BrandFontMod.contrast)
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                    case FactorType.call:
                        Text("Call:")
                            .modifier(K.BrandFontMod.label)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                        Text("\(fac.profile?.phoneNumber ?? "unknown")")
                            .modifier(K.BrandFontMod.contrast)
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                    default:
                        Text("Default")
                            .foregroundColor(Color.white)
                    }
                }
                HStack {
                    Text("Code:")
                        .modifier(K.BrandFontMod.label)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                    TextField("Passcode", text: $passCode)
                        .modifier(K.BrandFontMod.contrast)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button("Verify") { self.onVerifyClick(passCode) }
                    .buttonStyle(CustomButton(disabled: passCode.isEmpty))
                Button(sendButtonText) { self.onSendCodeClick(fac, true) }
                    .buttonStyle(CustomOutlineButton())
                Button("Go Back") { self.onGoBack() }
                    .buttonStyle(CustomPlainButton())
                
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
                .background(Color(.systemBackground))
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
        
        let factors = OktaUtilMocks.getOktaFactors()
        let factor1 = factors[1]
        let factor2 = factors[2]
        
        Group {
            OktaMFAPushView(factor: factor1,
                        onSendCodeClick: OktaMFAView_Previews.onSendCodeClick,
                        onVerifyClick: OktaMFAView_Previews.onVerifyClick,
                        onGoBack: OktaMFAView_Previews.onCancelClick)
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("Light Mode MFAPushView")
            OktaMFAPushView(factor: factor2,
                        onSendCodeClick: OktaMFAView_Previews.onSendCodeClick,
                        onVerifyClick: OktaMFAView_Previews.onVerifyClick,
                        onGoBack: OktaMFAView_Previews.onCancelClick)
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, .dark)
                    .previewDisplayName("Dark Mode MFAPushView")
        }

    }
}

#endif
