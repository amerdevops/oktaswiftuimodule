//
//  OktaUserInfo.swift
//
//
//  Created by Nathan DeGroff on 12/10/21.
//

import Foundation

public struct OktaUserInfo {
    public let preferred_username: String
    public let uclUserid: String
    public let email: String
    public let given_name: String
    public let corpName: String
    public let ont_roledn: [String]
    public let uclAccesscodes: String
    public let uclAgentid: String
    public let phone: String
    public let businessPhone: String

    public init(preferred_username: String, uclUserid: String, email: String, given_name: String,
                corpName: String, ont_roledn: [String], uclAccesscodes: String,
                uclAgentid: String, phone: String, businessPhone: String) {
        self.preferred_username = preferred_username
        self.uclUserid = uclUserid
        self.email = email
        self.given_name = given_name
        self.corpName = corpName
        self.ont_roledn = ont_roledn
        self.uclAccesscodes = uclAccesscodes
        self.uclAgentid = uclAgentid
        self.phone = phone
        self.businessPhone = businessPhone
    }
}
