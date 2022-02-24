//
//  SwiftUIView.swift
//  
//
//  Created by Sandeep Madineni on 2/14/22.
//

import SwiftUI

struct OktaMFAOptionsView: View {
    var body: some View {
        VStack{
            VStack{
                Text("Ameritas requires multifactor authentication to ensure the security of your account")
            }.modifier(K.BrandFontMod.imageDarkGreyForText)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 24){
                HStack{
                    Image(systemName: "text.bubble.fill")
                        .imageScale(.large)
                        .modifier(K.BrandFontMod.imageDarkGrey)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                    VStack{
                        HStack{
                            Text("SMS Authentication")
                                .modifier(K.BrandFontMod.imageDarkGreyForHeader)
                            Spacer()
                        }
                        
                        VStack{
                            HStack{
                                Text("Enter a single-use code sent to your mobile phone.")
                                    .modifier(K.BrandFontMod.imageDarkGreyForText)
                                Spacer()
                            }
                        }
                    }
                }
                HStack{
                    Image(systemName: "envelope.fill")
                        .imageScale(.large)
                        .modifier(K.BrandFontMod.imageDarkGrey)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                    VStack{
                        HStack{
                            Text("Email Authentication")
                                .modifier(K.BrandFontMod.imageDarkGreyForHeader)
                            Spacer()
                        }
                        
                        VStack{
                            HStack{
                                Text("Enter a single-use code sent to your email.")
                                    .modifier(K.BrandFontMod.imageDarkGreyForText)
                                Spacer()
                            }
                        }
                    }
                }
                HStack{
                    Image(systemName: "phone.fill")
                        .imageScale(.large)
                        .modifier(K.BrandFontMod.imageDarkGrey)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 36))
                    VStack{
                        HStack{
                            Text("Voice Call Authentication")
                                .modifier(K.BrandFontMod.imageDarkGreyForHeader)
                            Spacer()
                        }
                        
                        VStack{
                            HStack{
                                Text("Use a phone to authenticate by following voice instruction.")
                                    .modifier(K.BrandFontMod.imageDarkGreyForText)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 16))
    }
}

struct OktaMFAOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OktaMFAOptionsView()
    }
}
