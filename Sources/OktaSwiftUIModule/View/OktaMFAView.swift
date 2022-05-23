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
    
    @Environment(\.colorScheme) var colorScheme
    var isDark : Bool { return colorScheme == .dark }

    @State var selectedFactor: OktaFactor? = nil
   
    /**
     * Determine if  this is the first time we sent MFA (may need in future to switch MFA otpion
     */
    public func firstTime() -> Bool{
        return (selectedFactor == nil)
    }
    
    public func getMsg() -> String {
        if (firstTime()) {
            return "Select a method below to verify your identity."
        }
        else {
            switch(selectedFactor?.type) {
                case .email:
                        return "We sent a verification code to your email address. Enter it below."
                case .sms :
                        return "We texted a verification code to your phone. Enter it below."
                case .call :
                    return "We left a voice message with your verification code on your phone. Enter it below."
                default:
                    return "Unknown"
            }
        }
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
                .headline()
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
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
                    .btnPlain()
                    .accessibilityLabel("Cancel Login")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Cancel-Login-ID")
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("ChooseFactor")
        .accessibilityValue(factor.type.rawValue)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("Choose-Factor-ID")
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
        VStack{
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
                        Text("Select")
                            .bodyGrayReg()
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .foregroundColor(K.BrandColor.blue)
                            .padding(EdgeInsets(top: 0, leading: 112, bottom: 20, trailing: 16))
                    }
                    .padding(EdgeInsets(top: 0, leading: 32, bottom: 10, trailing: 16))
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Select Factor")
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("Select-Factor-ID")
            
            Divider().padding(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 16))

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
                            .labelDark()
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                            .accessibilityLabel("Email")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Label-Email-ID")
                        Text("\(fac.profile?.email ?? "unknown")")
                            .labelDark()
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                            .accessibilityLabel(fac.profile?.email ?? "unknown")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Value-Email-ID")
                    case FactorType.sms:
                        Text("SMS:")
                            .labelDark()
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                            .accessibilityLabel("SMS")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Label-SMS-ID")
                        Text("\(fac.profile?.phoneNumber ?? "unknown")")
                            .labelDark()
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                            .accessibilityLabel(fac.profile?.phoneNumber ?? "unknown")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Value-SMS-ID")
                    case FactorType.call:
                        Text("Call:")
                            .labelDark()
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            .frame( width: 90, alignment: .topLeading )
                            .accessibilityLabel("Call")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Label-Call-ID")
                        Text("\(fac.profile?.phoneNumber ?? "unknown")")
                            .labelDark()
                            .frame( maxWidth: .infinity, alignment: .topLeading )
                            .accessibilityLabel(fac.profile?.phoneNumber ?? "unknown")
                            .accessibilityAddTraits(.isStaticText)
                            .accessibilityIdentifier("Factor-Value-Call-ID")
                    default:
                        Text("Default")
                            .foregroundColor(Color.white)
                    }
                }
                Divider()
                HStack {
                    Text("Code:")
                        .labelDark()
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        .frame( width: 90, alignment: .topLeading )
                        .accessibilityLabel("Code")
                        .accessibilityAddTraits(.isStaticText)
                        .accessibilityIdentifier("Passcode-Label-ID")
                    CustomTextField(title: "Passcode", text: $passCode, aLabel: "Enter passcode", aID: "Passcode-Text-ID")
                }
                Divider()
                
                Button("Verify") { self.onVerifyClick(passCode) }
                    .btnFilled(passCode.isEmpty)
                    .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
                    .disabled(passCode.isEmpty)
                    .accessibilityLabel("Verify Passcode")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Verify-ID")
                Button("Resend") { self.onResendClick(fac) }
                    .btnOutline()
                    .accessibilityLabel("Resend Passcode")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Resend-ID")
                Button("Cancel") { self.onGoBack() }
                    .btnPlain()
                    .accessibilityLabel("Cancel Login")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("Button-Cancel-ID")
                
            } else {
                Text("Loading...")
                    .accessibilityLabel("Loading")
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityIdentifier("Loading-Text-ID")
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

    static var previews: some View {
        //-----------------------------------------------------
        // Get Factors
        let factors = OktaUtilMocks.getOktaFactors()
        Group {
            OktaMFAView(factors: factors,
                              onSendCodeClick: {_, _ -> Void in },
                              onResendClick: {_ -> Void in },
                              onVerifyClick: {_ -> Void in },
                              onCancelClick: {})
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode MFAView")
            
            OktaMFAView(factors: factors,
                              onSendCodeClick: {_, _ -> Void in },
                              onResendClick: {_ -> Void in },
                              onVerifyClick: {_ -> Void in },
                              onCancelClick: {})
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
                                  onResendClick: {_ -> Void in },
                                  onVerifyClick: {_ -> Void in },
                                  onGoBack: {})
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .padding()
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("Light Mode MFAPushView")
            OktaMFAPushView(factor: factor2,
                                  onResendClick: {_ -> Void in },
                                  onVerifyClick: {_ -> Void in },
                                  onGoBack: {})
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

    static var previews: some View {
        
        let factors = OktaUtilMocks.getOktaFactors()
        let factor1 = factors[1]
        let factor2 = factors[2]
        
        Group {
            OktaMFAView(factors: factors,
                              onSendCodeClick: {_, _ -> Void in },
                              onResendClick: {_ -> Void in },
                              onVerifyClick: {_ -> Void in },
                              onCancelClick: {})
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("iPhone 12 OktaMFAView")

            OktaMFAPushView(factor: factor1,
                    onResendClick: {_ -> Void in },
                    onVerifyClick: {_ -> Void in },
                    onGoBack: {})
                    .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                    .padding()
                    .environment(\.colorScheme, .light)
                    .previewDisplayName("iPhone 12 OktaMFAPushView")
            
            OktaMFAView(factors: factors,
                              onSendCodeClick: {_, _ -> Void in },
                              onResendClick: {_ -> Void in },
                              onVerifyClick: {_ -> Void in },
                              onCancelClick: {})
                .preferredColorScheme(.dark)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDevice(PreviewDevice(rawValue: "iPod touch"))
                .previewDisplayName("iPod MFAView")
            OktaMFAPushView(factor: factor2,
                                  onResendClick: {_ -> Void in },
                                  onVerifyClick: {_ -> Void in },
                                  onGoBack: {})
                    .preferredColorScheme(.dark)
                    .padding()
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, .dark)
                    .previewDevice(PreviewDevice(rawValue: "iPod touch"))
                    .previewDisplayName("iPod MFAPushView")
        }
    }
}
/**
 * MFAView Previews
 */
struct OktaMFAView_DyanmicTxt_Previews: PreviewProvider {

    static var previews: some View {
        //-----------------------------------------------------
        // Get Factors
        let factors = OktaUtilMocks.getOktaFactors()
        Group {
            OktaMFAView(factors: factors,
                              onSendCodeClick: {_, _ -> Void in },
                              onResendClick: {_ -> Void in },
                              onVerifyClick: {_ -> Void in },
                              onCancelClick: {})
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraSmall)
                .previewDisplayName("Dynamic: Extra Small")
                .previewLayout(PreviewLayout.sizeThatFits)
            
            OktaMFAView(factors: factors,
                              onSendCodeClick: {_, _ -> Void in },
                              onResendClick: {_ -> Void in },
                              onVerifyClick: {_ -> Void in },
                              onCancelClick: {})
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewDisplayName("Dynamic: Extra Large")
                .previewLayout(PreviewLayout.sizeThatFits)
            
        }

    }
}
/**
 * MFAView Previews
 */
struct OktaMFAPushView2_DyanmicTxt_Previews: PreviewProvider {

    static var previews: some View {
        
        let factors = OktaUtilMocks.getOktaFactors()
        let factor1 = factors[1]
        let factor2 = factors[2]
        
        Group {

            OktaMFAPushView(factor: factor1,
                    onResendClick: {_ -> Void in },
                    onVerifyClick: {_ -> Void in },
                    onGoBack: {})
                    .padding()
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, .light)
                    .environment(\.sizeCategory, .extraSmall)
                    .previewDisplayName("Dynamic: Extra Small")
                    .previewLayout(PreviewLayout.sizeThatFits)

            OktaMFAPushView(factor: factor2,
                                  onResendClick: {_ -> Void in },
                                  onVerifyClick: {_ -> Void in },
                                  onGoBack: {})
                    .padding()
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, .light)
                    .environment(\.sizeCategory, .extraExtraExtraLarge)
                    .previewDisplayName("Dynamic: Extra Large")
                    .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
#endif
