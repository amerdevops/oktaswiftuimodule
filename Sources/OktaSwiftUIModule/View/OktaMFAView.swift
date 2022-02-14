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
    var onSendCodeClick: (_ factor: OktaFactor, _ isChange: Bool) -> Void
    var onResendClick: (_ factor: OktaFactor) -> Void
    var onVerifyClick: (_ passCode: String) -> Void
    var onCancelClick: () -> Void
    var factors = [OktaFactor]()
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaMFASelectView")
    
    @State var selectedFactor: OktaFactor? = nil
   
    /**
     * Determine if  this is the first time we sent MFA (may need in future to switch MFA otpion
     */
    public func firstTime() -> Bool{
        return (selectedFactor == nil)
    }
    
    public func getMsg() -> String {
        if (firstTime()) {
            return "Select a method below to verify your identity"
        }
        return "Verify Your Identity."
    }
    /**
     * Initialize the class
     */
    public init( factors: [OktaFactor],
        onSendCodeClick: @escaping (_ factor: OktaFactor, _ isChange: Bool) -> Void,
        onResendClick: @escaping (_ factor: OktaFactor) -> Void,
        onVerifyClick: @escaping (_ passCode: String) -> Void,
        onCancelClick: @escaping () -> Void) {
        self.onSendCodeClick = onSendCodeClick
        self.onResendClick = onResendClick
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
        let onGoBack = {
            logger.log("Clicked goBack()")
            selectedFactor = nil
            onCancelClick()
        }
        VStack (alignment: .center, spacing: 50) {
            
            //-----------------------------------------------
            // Draw message
            Text(getMsg())
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0))
                .accessibilityLabel(getMsg())
                .accessibilityAddTraits(.isStaticText)
                .accessibilityIdentifier("Okta-Label")

            if let factor = selectedFactor {
                //-----------------------------------------------
                // Draw the specific factor view
                OktaMFAPushView(factor: factor,
                            onResendClick: onResendClick,
                            onVerifyClick: onVerifyClick,
                            onGoBack: onGoBack)
            } else {
                //-----------------------------------------------
                // Draw the Select MFA view
                OktaDropdownMFA(factors: self.factors,
                                onSelectFactor: { ( factor: OktaFactor ) -> Void in
                                    // Check to see if user selected same factor
                                    if(factor.type.rawValue.caseInsensitiveCompare(self.selectedFactor?.type.rawValue ?? "") != .orderedSame) {
                                        
                                        //-----------------------------------------------
                                        // Trigger Send OTP Push
                                        self.logger.log("FirstTime: \(firstTime())")
                                        onSendCodeClick(factor, firstTime())
                                        self.selectedFactor = factor
                                    }
                                })
                
                OktaMFAOptionsView()
                
                Button("Cancel") { onGoBack() }
                    .buttonStyle(CustomPlainButton())
                    .padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 0))
                    .accessibilityLabel("Cancel Login")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Cancel-Login")
            }
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
 * Otka MFA Dropdown element
 */
struct OktaDropdownMFAElement: View {
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaDropdownMFAElement")
    
    var onSelectFactor: (_ factor: OktaFactor) -> Void
    var factor: OktaFactor
    /**
     * Initialize MFASelectView with factors and the event when selecting a factor
     */
    public init( factor: OktaFactor,
          onSelectFactor: @escaping (_ factor: OktaFactor ) -> Void) {
        self.onSelectFactor = onSelectFactor
        self.factor = factor
    }
        
    public var body: some View {
        let facType = factor.type
        Button {
            logger.log("Clicked on \(factor.type.rawValue, privacy: .public)")
            onSelectFactor( factor )
        } label: {
            switch facType {
            case FactorType.email:
                Label("Email", systemImage: "envelope.fill")
            case FactorType.sms:
                Label("Text", systemImage: "text.bubble.fill")
            case FactorType.call:
                Label("Call", systemImage: "phone.fill")
            default:
                Label("unknown", systemImage: "email")
            }
            
        }
    }
}

/**
 * Otka MFA Dropdown
 */
struct OktaDropdownMFA: View {
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "Dropdown")
    var onSelectFactor: (_ factor: OktaFactor) -> Void
    var uFactors: [UniqueOktaFactor] = []
    /**
     * Initialize Dropdown with factors and the event when selecting a factor
     */
    public init( factors: [OktaFactor],
          onSelectFactor: @escaping (_ factor: OktaFactor ) -> Void) {
        self.onSelectFactor = onSelectFactor
        self.uFactors.removeAll()
        factors.forEach { factor in
            self.uFactors.append(UniqueOktaFactor(factor: factor))
        }
    }
    
    /**
     * Only allow SMS / Text / Call MFA factors to show
     */
    public func isValidFactor( _ factorValue: String ) -> Bool {
        return factorValue.caseInsensitiveCompare("email") == .orderedSame ||
            factorValue.caseInsensitiveCompare("sms") == .orderedSame ||
            factorValue.caseInsensitiveCompare("call") == .orderedSame
    }
    
    /**
     * Draw select dropdown
     */
    public var body: some View {
        Menu{
            ForEach(uFactors, id: \.id) { uFactor in
                    let factorValue = uFactor.factor.type.rawValue
                    if isValidFactor(factorValue) {
                        OktaDropdownMFAElement(factor: uFactor.factor, onSelectFactor: onSelectFactor )
                            .accessibilityLabel("Trigger \(factorValue) code")
                            .accessibilityAddTraits(.isButton)
                            .accessibilityIdentifier("\(factorValue)-Factor")
                    }
            }
        } label: {
            VStack(spacing: 0){
                HStack{
                    Text("Select").foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .imageScale(.large)
                        .foregroundColor(K.BrandColor.blue)
                        .padding(.trailing)
                }
                .padding(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 16))
                Divider().padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

/**
 * Handle MFA transactions
 */
public struct OktaMFAPushView: View {
    var onResendClick: (_ factor: OktaFactor ) -> Void = {_ in }
    var onVerifyClick: (_ passCode: String) -> Void = {_ in }
    var onGoBack: () -> Void = {}
    var factor: OktaFactor? = nil
    @State var passCode: String = ""
    
    public init( factor: OktaFactor,
        onResendClick: @escaping (_ factor: OktaFactor ) -> Void,
        onVerifyClick: @escaping (_ passCode: String) -> Void,
        onGoBack: @escaping () -> Void) {
        self.factor = factor
        self.onResendClick = onResendClick
        self.onVerifyClick = onVerifyClick
        self.onGoBack = onGoBack
    }
    
    @ViewBuilder
    public var body: some View {
        VStack(alignment: .center){
            if let fac = factor {
                HStack {
                    switch fac.type {
                    case FactorType.email:
                        Text("Email:")
                            .modifier(K.BrandFontMod.label)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                            .accessibilityLabel("Email")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Label-Email")
                        Text("\(fac.profile?.email ?? "unknown")")
                            .modifier(K.BrandFontMod.contrast)
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                            .accessibilityLabel(fac.profile?.email ?? "unknown")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Value-Email")
                    case FactorType.sms:
                        Text("SMS:")
                            .modifier(K.BrandFontMod.label)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                            .accessibilityLabel("SMS")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Label-SMS")
                        Text("\(fac.profile?.phoneNumber ?? "unknown")")
                            .modifier(K.BrandFontMod.contrast)
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                            .accessibilityLabel(fac.profile?.phoneNumber ?? "unknown")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Value-SMS")
                    case FactorType.call:
                        Text("Call:")
                            .modifier(K.BrandFontMod.label)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                            .accessibilityLabel("Call")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Label-Call")
                        Text("\(fac.profile?.phoneNumber ?? "unknown")")
                            .modifier(K.BrandFontMod.contrast)
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                            .accessibilityLabel(fac.profile?.phoneNumber ?? "unknown")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Value-Call")
                    default:
                        Text("Default")
                            .foregroundColor(Color.white)
                    }
                }
                Divider()
                HStack {
                    Text("Code:")
                        .modifier(K.BrandFontMod.label)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                        .accessibilityLabel("Code")
                        .accessibilityAddTraits(.isStaticText)
                        .accessibilityIdentifier("Passcode-Label")
                    TextField("Passcode", text: $passCode)
                        .modifier(K.BrandFontMod.contrast)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityLabel("Enter passcode")
                        .accessibilityAddTraits(.isSearchField)
                        .accessibilityIdentifier("Passcode-Text")
                }
                Divider()
                
                Button("Verify") { self.onVerifyClick(passCode) }
                    .buttonStyle(CustomButton(disabled: passCode.isEmpty))
                    .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
                    .disabled(passCode.isEmpty)
                    .accessibilityLabel("Verify Passcode")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Verify")
                Button("Resend") { self.onResendClick(fac) }
                    .buttonStyle(CustomOutlineButton())
                    .accessibilityLabel("Resend Passcode")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Resend")
                Button("Cancel") { self.onGoBack() }
                    .buttonStyle(CustomPlainButton())
                    .accessibilityLabel("Cancel Login")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Cancel")
                
            } else {
                Text("Loading...")
                    .accessibilityLabel("Loading")
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityIdentifier("Loading-Text")
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

    static func onSendCodeClick( factor: OktaFactor, isChange: Bool ) {
        // Do Nothing
    }
    static func onResendClick( factor: OktaFactor ) {
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
                    onResendClick: onResendClick,
                    onVerifyClick: onVerifyClick,
                    onCancelClick: onCancelClick)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode MFAView")
                //.previewLayout(PreviewLayout.fixed(width: 400, height: 400))
            
            OktaMFAView(factors: factors,
                    onSendCodeClick: onSendCodeClick,
                    onResendClick: onResendClick,
                    onVerifyClick: onVerifyClick,
                    onCancelClick: onCancelClick)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode MFAView")
                // .previewLayout(PreviewLayout.fixed(width: 400, height: 400))
            
        }

    }
}

/**
 * MFAView Previews
 */
struct OktaMFAPushView_Previews: PreviewProvider {
    
    static func onSendCodeClick( factor: OktaFactor, isChange: Bool ) {
        // Do Nothing
    }
    static func onResendClick( factor: OktaFactor ) {
        // Do Nothing
    }
    static func onVerifyClick(passCode: String) {
        // Do Nothing
    }
    static func onCancelClick() {
        // Do Nothing
    }
    static var previews: some View {
        
        let factors = OktaUtilMocks.getOktaFactors()
        let factor1 = factors[1]
        let factor2 = factors[2]
        
        Group {
            OktaMFAPushView(factor: factor1,
                        onResendClick: onResendClick,
                        onVerifyClick: onVerifyClick,
                        onGoBack: onCancelClick)
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("Light Mode MFAPushView")
            OktaMFAPushView(factor: factor2,
                        onResendClick: onResendClick,
                        onVerifyClick: onVerifyClick,
                        onGoBack: onCancelClick)
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, .dark)
                    .previewDisplayName("Dark Mode MFAPushView")
        }

    }
}

/**
 * MFAView Previews
 */
struct OktaMFAPushView2_Previews: PreviewProvider {
    
    static func onSendCodeClick( factor: OktaFactor, isChange: Bool ) {
        // Do Nothing
    }
    static func onResendClick( factor: OktaFactor ) {
        // Do Nothing
    }
    static func onVerifyClick(passCode: String) {
        // Do Nothing
    }
    static func onCancelClick() {
        // Do Nothing
    }
    static var previews: some View {
        
        let factors = OktaUtilMocks.getOktaFactors()
        let factor1 = factors[1]
        let factor2 = factors[2]
        
        Group {
            OktaMFAView(factors: factors,
                              onSendCodeClick: onSendCodeClick,
                              onResendClick: onResendClick,
                              onVerifyClick: onVerifyClick,
                              onCancelClick: onCancelClick)
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("iPhone 12 OktaMFAView")

            OktaMFAPushView(factor: factor1,
                        onResendClick: onResendClick,
                        onVerifyClick: onVerifyClick,
                        onGoBack: onCancelClick)
                    .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                    .padding()
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("iPhone 12 OktaMFAPushView")
            
            OktaMFAView(factors: factors,
                              onSendCodeClick: onSendCodeClick,
                              onResendClick: onResendClick,
                              onVerifyClick: onVerifyClick,
                              onCancelClick: onCancelClick)
                .previewDevice(PreviewDevice(rawValue: "iPod touch"))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("iPod MFAView")
            OktaMFAPushView(factor: factor2,
                        onResendClick: onResendClick,
                        onVerifyClick: onVerifyClick,
                        onGoBack: onCancelClick)
                .previewDevice(PreviewDevice(rawValue: "iPod touch"))
                    .padding()
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, .dark)
                    .previewDisplayName("iPod MFAPushView")
        }

    }
}

#endif
