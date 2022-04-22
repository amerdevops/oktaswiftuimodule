//
//  OktaConstants.swift
//  Agent Mobile Application (copied)
//
//

import Foundation
import SwiftUI


struct K
{
    // Struct containing named colors assocated with the Ameritas brand
    struct BrandColor
    {
        static let lightGreen = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        static let green = Color(#colorLiteral(red: 0.2745098039, green: 0.631372549, blue: 0.2, alpha: 1)) // #46A133
        static let darkGreen = Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)) // #32571A
        static let lightOrange = Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)) // #F3AF22
        static let orange = Color(#colorLiteral(red: 0.8901960784, green: 0.4156862745, blue: 0, alpha: 1)) // #E36A00
        static let blue = Color(#colorLiteral(red: 0.02745098039, green: 0.3450980392, blue: 0.6745098039, alpha: 1)) // #0758AC
        static let lightDarkGray = Color(red: 89/255, green: 89/255, blue: 89/255) //#595959
        static let secondaryBlack = Color(red: 51/255, green: 51/255, blue: 51/255) //#333333
        static let lightBlue = Color(#colorLiteral(red: 0.1516653001, green: 0.6443269849, blue: 1, alpha: 1))
        static let grey = Color(#colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)) // #9C9C9C
        static let lightGrey = Color(red: 232/255, green: 232/255, blue: 233/255) //#E8E8E9
        static let lightGrey2 = Color(red: 238/255, green: 238/255, blue: 238/255) //#EEEEEE
        static let darkGrey = Color(red: 131/255, green: 131/255, blue: 135/255) //#838387
        static let primaryLightGrey = Color(red: 118/255, green: 118/255, blue: 118/255) //#767676
        static let purple = Color(red: 129/255, green: 99/255, blue: 211/255) //#8163D3
        static let white = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // #FFFFFF
        static let veryLightGrey = Color(red: 249/255, green: 249/255, blue: 249/255) //#F9F9F9
        static let redError = Color(#colorLiteral(red: 0.8274509804, green: 0.1333333333, blue: 0.1647058824, alpha: 1))
        static let lightRedError = Color(#colorLiteral(red: 0.7450980392, green: 0.3764705882, blue: 0.3921568627, alpha: 1))
        static let black = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        static let lavender2 = Color(#colorLiteral(red: 0.5058823529, green: 0.3882352941, blue: 0.8274509804, alpha: 1))
        static let chipBlue = Color(#colorLiteral(red: 0.1843137255, green: 0.4588235294, blue: 0.7921568627, alpha: 1))
        static let chipGreen = Color(#colorLiteral(red: 0.2235294118, green: 0.5137254902, blue: 0.1647058824, alpha: 1))
        static let chipFuscia = Color(#colorLiteral(red: 0.7607843137, green: 0.2117647059, blue: 0.6078431373, alpha: 1))
        static let chipLavender = Color(#colorLiteral(red: 0.4901960784, green: 0.3333333333, blue: 0.7803921569, alpha: 1))
    }
    
    // Struct containing brand-specific fonts
    struct BrandFont
    {
        static let regular14 = Font.system(size: 14.0, weight: .regular)
        static let regular16 = Font.system(size: 16.0, weight: .regular)
        static let regular17 = Font.system(size: 17.0, weight: .regular)
        static let regular18 = Font.system(size: 18.0, weight: .regular)
        static let regular20 = Font.system(size: 20.0, weight: .regular)
        static let regular24 = Font.system(size: 24.0, weight: .regular)
        static let medium16 = Font.system(size: 16.0, weight: .medium)
        static let medium17 = Font.system(size: 17.0, weight: .medium)
        static let medium18 = Font.system(size: 18.0, weight: .medium)
        static let medium28 = Font.system(size: 28.0, weight: .medium)
        static let light14 = Font.system(size: 14.0, weight: .light)
        static let light16 = Font.system(size: 16.0, weight: .light)
        static let bold12 = Font.system(size: 12.0, weight: .bold)
        static let bold14 = Font.system(size: 14.0, weight: .bold)
        static let bold16 = Font.system(size: 16.0, weight: .bold)
        static let bold17 = Font.system(size: 17.0, weight: .bold)
        static let bold18 = Font.system(size: 18.0, weight: .bold)
        static let bold20 = Font.system(size: 20.0, weight: .bold)
        static let bold24 = Font.system(size: 24.0, weight: .bold)
        //-----------------------------------------------------------
        // Dynamic text font modifiers
        static let title = Font.system(.title)
    }
    
    // Struct containing themed font style... Apply to allow easy global theme change (don't have to change
    // every view when changing theme font style.)
    struct BrandFontMod
    {
        static let titleContrast = FontViewModifier(color: .contrast, font: .title, weight: .regular ) // Large: 28
        static let titleGrey = FontViewModifier(color: .lightDarkGrey, font: .title, weight: .regular ) // Large: 28
        static let detailContrast = FontViewModifier(color: .contrast, font: .body, weight: .regular ) // Large: 17
        static let detailGrey = FontViewModifier(color: .lightDarkGrey, font: .body, weight: .regular ) // Large: 17
        static let labelContrast = FontViewModifier(color: .contrast, font: .subheadline, weight: .bold ) // Large: 15
        static let labelGrey = FontViewModifier(color: .grey, font: .subheadline, weight: .bold ) // Large: 15
        static let statusGreen = FontViewModifier(color: .green, font: .callout, weight: .bold ) // Large: 16
        static let statusOrange = FontViewModifier(color: .orange, font: .callout, weight: .bold ) // Large: 16
        static let statusBlue = FontViewModifier(color: .blue, font: .callout, weight: .bold ) // Large: 16
        static let label1Contrast = FontViewModifier(color: .blue, font: .callout, weight: .regular ) // Large: 16
        static let value1Contrast = FontViewModifier(color: .blue, font: .callout, weight: .regular ) // Large: 16
        
        static let contrast = FontViewModifier(color: .contrast, font: .body, weight: .regular )
        static let normal = FontViewModifier(color: .lightDarkGrey, font: .body, weight: .regular )
        static let label = FontViewModifier(color: .lightDarkGrey, font: .body, weight: .regular )
        static let placeholder = FontViewModifier(color: .primaryLightGrey, font: .body, weight: .regular )
        static let error = FontViewModifier(color: .redError, font: .body, weight: .regular )
        static let supplemental = FontViewModifier(color: .primaryLightGrey, font: .footnote, weight: .regular )
        
    }
    

    // Static map which converts a policy status string to a color
    // which is used in the filter buttons and policy cards
    static let caseSummaryStatusToColor: [String:Color] = [
        "All": BrandColor.lightBlue,
        "Pending":BrandColor.chipBlue,
        "Issued":BrandColor.chipGreen,
        "Not Placed": BrandColor.chipFuscia
    ]
    
    static let filterType2AccLabel: [CaseSummaryFilterType:Text] = [
        .issued: Text("Issued"),
        .pending: Text("Pending"),
        .notPlaced: Text("Not placed"),
        .all: Text("All")
    ]
    
    static let defaultCaseSummaryStatusColor: Color = BrandColor.grey
    /**
     * getColor
     * Get the correct color by color scheme (category) whether it is in dark mode or not
     */
    static func getColor(_ color: CustomColorScheme, _ isDark: Bool = false) -> Color {
        switch(color) {
        case .contrast: return isDark ? K.BrandColor.white : K.BrandColor.black
        case .reverse: return isDark ? K.BrandColor.black : K.BrandColor.white
        case .secondaryBlack: return isDark ? K.BrandColor.white : K.BrandColor.secondaryBlack
        case .primaryLightGrey: return isDark ? K.BrandColor.white : K.BrandColor.primaryLightGrey
        case .lightDarkGrey: return isDark ? K.BrandColor.primaryLightGrey : K.BrandColor.lightDarkGray
        case .redError: return isDark ? K.BrandColor.lightRedError : K.BrandColor.redError
        case .grey: return isDark ? K.BrandColor.grey : K.BrandColor.darkGrey
        case .blue: return isDark ? K.BrandColor.lightBlue : K.BrandColor.blue
        case .green: return isDark ? K.BrandColor.lightGreen : K.BrandColor.darkGreen
        case .orange: return isDark ? K.BrandColor.lightOrange : K.BrandColor.orange
        // default: return K.BrandColor.black
        }
    }
    
    static func getCustomError(_ error: String) -> String {
        switch(error) {
            case "E0000001":
                return "Your submitted information is incorrect. Please try again with a valid username and password."
            case "E9999901":
                return "You currently don\'t have access to the Ameritas Agent app. Please contact xxx-xxx-xxxx to gain access."
            case "E0000004" :
                return "Your submitted information is incorrect. Please try again with a valid username and password."
            case "E0000068" :
                return "Your authentication code doesn\'t match our records. Please try again."
            case "E9999900" :
                return "Connection error - you don\'t appear to be connected to the internet. Please check your connection and try again."
            case "E0000118" :
                return "Verification timeout error. Please wait 5 seconds before trying again."
            case "E0000109" :
                return "Verification timeout error. Please wait 30 seconds before trying again."
            case "E0000133" :
                return "Verification timeout error. Please wait 30 seconds before trying again."
            case "E0000069" :
                return "Your account has been locked for your protection. Please contact xxx-xxx-xxxx."
            case "E0000011" :
                return "This authentication code has expired. Please request a new authentication code to proceed."
            case "E9999902" :
                return "We have sent a new code to your mobile device. Please use that code to try again."
            default:
                return ""
        }
        
    }

}

// Enumeration outlining the type of filter that can be applied to a policy
// for viewing
enum CustomColorScheme: String
{
    case contrast = "Contrast"
    case reverse = "Reverse"
    case secondaryBlack = "SecondaryBlack"
    case primaryLightGrey = "PrimaryLightGrey"
    case lightDarkGrey = "LightDarkGrey"
    case redError = "RedError"
    case grey = "Grey"
    case blue = "Blue"
    case green = "Green"
    case orange = "Orange"
}


// Enumeration outlining the type of filter that can be applied to a policy
// for viewing
enum CaseSummaryFilterType: String
{
    case all = "All"
    case pending = "Pending"
    case issued = "Issued"
    case notPlaced = "Not Placed"
}

/**
 * Common themed font modifier settting font of a view to a specific theme
 */
struct FontViewModifier: ViewModifier {

    @Environment(\.colorScheme) var colorScheme
    let color: CustomColorScheme
    var font: Font = .body
    var weight: Font.Weight = .regular

    /**
     * Determine if in dark mode or not
     */
    func getColor() -> Color {
        let isDark = colorScheme == .dark
        return K.getColor(color, isDark)
    }
    
    /**
     * ViewModifier detail.  Sets the values for the view
     */
    func body(content: Content) -> some View {
        content
            .font(font.weight(weight))
            .foregroundColor( getColor() )
    }
}

/**
 * Create placeholder method for TextViews
 */
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension View {
    func titleContrast() -> some View  { self.modifier(FontViewModifier(color: .contrast, font: .title, weight: .medium )) }
    func titleGrey() -> some View { self.modifier(FontViewModifier(color: .lightDarkGrey, font: .title, weight: .medium )) }
    func bodyContrast() -> some View { self.modifier(FontViewModifier(color: .contrast, font: .body, weight: .medium )) }
    func bodyReverse() -> some View { self.modifier(FontViewModifier(color: .reverse, font: .body, weight: .medium )) }
    func bodyGrey() -> some View { self.modifier(FontViewModifier(color: .lightDarkGrey, font: .body, weight: .medium )) }
    func bodyGreyReg() -> some View { self.modifier(FontViewModifier(color: .lightDarkGrey, font: .body, weight: .regular )) }
    func labelContrast() -> some View { self.modifier(FontViewModifier(color: .contrast, font: .body, weight: .regular )) }
    func labelDark() -> some View { self.modifier(FontViewModifier(color: .secondaryBlack, font: .body, weight: .regular )) }
    func footnote() -> some View { self.modifier(FontViewModifier(color: .lightDarkGrey, font: .footnote, weight: .regular )) }
    func footnoteHdr() -> some View { self.modifier(FontViewModifier(color: .secondaryBlack, font: .footnote, weight: .medium )) }
    func headline() -> some View { self.modifier(FontViewModifier(color: .secondaryBlack, font: .headline, weight: .medium )) }
}
