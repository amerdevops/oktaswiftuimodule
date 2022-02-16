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
        static let green = Color(#colorLiteral(red: 0.2729613781, green: 0.6303340793, blue: 0.2016084194, alpha: 1))
        static let darkGreen = Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1))
        static let lightOrange = Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
        static let orange = Color(#colorLiteral(red: 0.8903892636, green: 0.416303575, blue: 0, alpha: 1))
        static let blue = Color(red: 7/255, green: 88/255, blue: 172/255) //#0758AC
        static let lightDarkGray = Color(red: 89/255, green: 89/255, blue: 89/255) //#595959
        static let secondaryBlack = Color(red: 51/255, green: 51/255, blue: 51/255) //#333333
        static let lightBlue = Color(#colorLiteral(red: 0.1516653001, green: 0.6443269849, blue: 1, alpha: 1))
        static let grey = Color(#colorLiteral(red: 0.6101055741, green: 0.6101958752, blue: 0.610085845, alpha: 1))
        static let lightGrey = Color(red: 232/255, green: 232/255, blue: 233/255) //#E8E8E9
        static let lightGrey2 = Color(red: 238/255, green: 238/255, blue: 238/255) //#EEEEEE
        static let darkGrey = Color(red: 131/255, green: 131/255, blue: 135/255) //#838387
        static let primaryLightGrey = Color(red: 118/255, green: 118/255, blue: 118/255) //#767676
        static let purple = Color(red: 129/255, green: 99/255, blue: 211/255) //#8163D3
        static let white = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        static let veryLightGrey = Color(red: 249/255, green: 249/255, blue: 249/255) //#F9F9F9
        static let redError = Color(#colorLiteral(red: 0.8274509804, green: 0.1333333333, blue: 0.1647058824, alpha: 1))
        static let lightRedError = Color(#colorLiteral(red: 0.7450980544, green: 0.377785946, blue: 0.391878865, alpha: 1))
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
        static let light14 = Font.system(size: 14.0, weight: .light)
        static let light16 = Font.system(size: 16.0, weight: .light)
        static let bold12 = Font.system(size: 12.0, weight: .bold)
        static let bold14 = Font.system(size: 14.0, weight: .bold)
        static let bold16 = Font.system(size: 16.0, weight: .bold)
        static let bold17 = Font.system(size: 17.0, weight: .bold)
        static let bold18 = Font.system(size: 18.0, weight: .bold)
        static let bold20 = Font.system(size: 20.0, weight: .bold)
        static let bold24 = Font.system(size: 24.0, weight: .bold)
    }
    
    // Struct containing themed font style... Apply to allow easy global theme change (don't have to change
    // every view when changing theme font style.)
    struct BrandFontMod
    {
        static let titleContrast = FontViewModifier(color: "Contrast", font: K.BrandFont.bold20)
        static let titleGrey = FontViewModifier(color: "Grey", font: K.BrandFont.bold20)
        static let detailContrast = FontViewModifier(color: "Contrast", font: K.BrandFont.regular14)
        static let detailGrey = FontViewModifier(color: "Grey", font: K.BrandFont.regular14)
        static let labelContrast = FontViewModifier(color: "Contrast", font: K.BrandFont.bold14)
        static let labelGrey = FontViewModifier(color: "Grey", font: K.BrandFont.bold14)
        static let statusGreen = FontViewModifier(color: "Green", font: K.BrandFont.regular16)
        static let statusOrange = FontViewModifier(color: "Orange", font: K.BrandFont.regular16)
        static let statusBlue = FontViewModifier(color: "Blue", font: K.BrandFont.regular16)
        static let label1Contrast = FontViewModifier(color: "SecondaryBlack", font: K.BrandFont.regular16)
        static let mfalabelContrast = FontViewModifier(color: "SecondaryBlack", font: K.BrandFont.regular14)
        static let value1Contrast = FontViewModifier(color: "PrimaryLightGrey", font: K.BrandFont.regular16)
        static let imageGrey = FontViewModifier(color: "Grey", font: K.BrandFont.regular24)
        
        static let black = FontViewModifier(color: "Black", font: K.BrandFont.regular17)
        static let contrast = FontViewModifier(color: "Contrast", font: K.BrandFont.regular17)
        static let normal = FontViewModifier(color: "Grey", font: K.BrandFont.regular17)
        static let label = FontViewModifier(color: "Grey", font: K.BrandFont.regular17)
        static let placeholder = FontViewModifier(color: "PrimaryLightGrey", font: K.BrandFont.regular17)
        static let error = FontViewModifier(color: "RedError", font: K.BrandFont.regular17)
        static let supplemental = FontViewModifier(color: "PrimaryLightGrey", font: K.BrandFont.regular14)
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
    let color: String
    let font: Font

    /**
     * Determine if in dark mode or not
     */
    func isDark() -> Bool {
        return colorScheme == .dark
    }
    
    /**
     * Determine if in dark mode or not
     */
    func getColor() -> Color {
        switch color {
        case "Contrast": return isDark() ? K.BrandColor.white : K.BrandColor.black
        case "Grey": return isDark() ? K.BrandColor.grey : K.BrandColor.darkGrey
        case "Blue": return isDark() ? K.BrandColor.lightBlue : K.BrandColor.blue
        case "Green": return isDark() ? K.BrandColor.lightGreen : K.BrandColor.darkGreen
        case "Orange": return isDark() ? K.BrandColor.lightOrange : K.BrandColor.orange
        case "SecondaryBlack": return isDark() ? K.BrandColor.white : K.BrandColor.secondaryBlack
        case "PrimaryLightGrey": return isDark() ? K.BrandColor.white : K.BrandColor.primaryLightGrey
        case "RedError": return isDark() ? K.BrandColor.lightRedError : K.BrandColor.redError
        default: return isDark() ? K.BrandColor.white : K.BrandColor.black
        }
    }
    
    /**
     * ViewModifier detail.  Sets the values for the view
     */
    func body(content: Content) -> some View {
        content
            .foregroundColor( getColor() )
            .font(font)
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
