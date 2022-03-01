//
//  SwiftUIView.swift
//  
//
//  Created by Sandeep Madineni on 2/14/22.
//

import SwiftUI

struct OktaMFAOptionsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    var isDark : Bool { return colorScheme == .dark }

    var body: some View {
        let msg = "Ameritas requires multifactor authentication to ensure the security of your account"
        VStack{
            VStack{
                Text(msg)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(msg)
                    .accessibilityIdentifier("Legalese-ID")
            }
            .footnote()
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 24){
                HStack{
                    Image(systemName: "text.bubble.fill")
                        .imageScale(.large)
                        .foregroundColor(K.getColor(.lightDarkGrey, isDark))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                        .accessibilityHidden(true)
                    VStack{
                        HStack{
                            Text("SMS Authentication")
                                .footnoteHdr()
                                .multilineTextAlignment(.leading)
                                .accessibilityIdentifier("SMS-ID")
                            Spacer()
                        }
                        
                        VStack{
                            HStack{
                                Text("Enter a single-use code sent to your mobile phone.")
                                    .footnote()
                                    .multilineTextAlignment(.leading)
                                    .accessibilityIdentifier("SMS-Detail-ID")
                                Spacer()
                            }
                        }
                    }
                }
                HStack{
                    Image(systemName: "envelope.fill")
                        .imageScale(.large)
                        .foregroundColor(K.getColor(.lightDarkGrey, isDark))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                        .accessibilityHidden(true)
                    VStack{
                        HStack{
                            Text("Email Authentication").footnoteHdr()
                                .multilineTextAlignment(.leading)
                                .accessibilityIdentifier("Email-ID")
                            Spacer()
                        }
                        
                        VStack{
                            HStack{
                                Text("Enter a single-use code sent to your email.")
                                    .multilineTextAlignment(.leading)
                                    .footnote()
                                    .accessibilityIdentifier("Email-Detail-ID")
                                Spacer()
                            }
                        }
                    }
                }
                HStack{
                    Image(systemName: "phone.fill")
                        .imageScale(.large)
                        .foregroundColor(K.getColor(.lightDarkGrey, isDark))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 36))
                    VStack{
                        HStack{
                            Text("Voice Call Authentication").footnoteHdr()
                                .multilineTextAlignment(.leading)
                                .accessibilityIdentifier("Voice-ID")
                            Spacer()
                        }
                        
                        VStack{
                            HStack{
                                Text("Use a phone to authenticate by following voice instruction.")
                                    .footnote()
                                    .multilineTextAlignment(.leading)
                                    .accessibilityIdentifier("Voice-Detail-ID")
                                Spacer()
                            }
                        }
                    }
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 16))
    }
}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
/**
 * Show Light / Dark views
 */
struct OktaMFAOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OktaMFAOptionsView()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaMFAOptionsView()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
                .previewLayout(PreviewLayout.sizeThatFits)
            
        }
    }
}
/**
 * Show Dynamic Text views
 */
struct OktaMFAOptionsView_DyanmicTxt_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OktaMFAOptionsView()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraSmall)
                .previewDisplayName("Dynamic: Extra Small")
                .previewLayout(PreviewLayout.sizeThatFits)
            OktaMFAOptionsView()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewDisplayName("Dynamic: Extra Large")
                .previewLayout(PreviewLayout.sizeThatFits)
            
        }
    }
}
