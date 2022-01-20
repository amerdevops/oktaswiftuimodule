//
//  OktaUtilMocks.swift
//
//
//  Created by Nathan DeGroff on 12/10/21.
//

import Foundation
import OktaOidc
import OktaAuthNative
import os

public class OktaUtilMocks {

    private static let decoder = JSONDecoder()
    private static let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "MockOktaRepositoryImpl")
    
    private static let sample_json_oktaFactors = """
    [
      {
        "id": "sms1u5bwsmuVJ7BqR1d7",
        "factorType": "sms",
        "provider": "OKTA",
        "vendorName": "OKTA",
        "profile": { "phoneNumber": "+1 XXX-XXX-1234" },
        "_links": {
          "verify": {
            "href": "https://ameritas-d.oktapreview.com/api/v1/authn/factors/sms1u5bwsmuVJ7BqR1d7/verify",
            "hints": { "allow": ["POST"] }
          }
        }
      },
      {
        "id": "clf21b5ac8NxixavN1d7",
        "factorType": "call",
        "provider": "OKTA",
        "vendorName": "OKTA",
        "profile": { "phoneNumber": "+1 XXX-XXX-5678" },
        "_links": {
          "verify": {
            "href": "https://ameritas-d.oktapreview.com/api/v1/authn/factors/clf21b5ac8NxixavN1d7/verify",
            "hints": { "allow": ["POST"] }
          }
        }
      },
      {
        "id": "emf1u5d3bi99AVQCC1d7",
        "factorType": "email",
        "provider": "OKTA",
        "vendorName": "OKTA",
        "profile": { "email": "I...m@ameritas.com" },
        "_links": {
          "verify": {
            "href": "https://ameritas-d.oktapreview.com/api/v1/authn/factors/emf1u5d3bi99AVQCC1d7/verify",
            "hints": { "allow": ["POST"] }
          }
        }
      }
    ]
    """
    private static let sample_json_successResponse = """
{
  "stateToken": "007ucIX7PATyn94hsHfOLVaXAmOBkKHWnOOLG43bsb",
  "expiresAt": "2015-11-03T10:15:57.000Z",
  "status": "PASSWORD_EXPIRED",
  "relayState": "/myapp/some/deep/link/i/want/to/return/to",
  "_embedded": {
    "user": {
      "id": "00ub0oNGTSWTBKOLGLNR",
      "passwordChanged": "2015-09-08T20:14:45.000Z",
      "profile": {
        "login": "dade.murphy@example.com",
        "firstName": "Dade",
        "lastName": "Murphy",
        "locale": "en_US",
        "timeZone": "America/Los_Angeles"
      }
    },
    "policy": {
      "complexity": {
        "minLength": 8,
        "minLowerCase": 1,
        "minUpperCase": 1,
        "minNumber": 1,
        "minSymbol": 0
      }
    },
    "factor": {
      "id": "emf1u5d3bi99AVQCC1d7",
      "factorType": "email",
      "provider": "OKTA",
      "vendorName": "OKTA",
      "profile": { "email": "I...m@ameritas.com" },
      "_links": {
        "verify": {
          "href": "https://ameritas-d.oktapreview.com/api/v1/authn/factors/emf1u5d3bi99AVQCC1d7/verify",
          "hints": { "allow": ["POST"] }
        }
      }
    }
  },
  "_links": {
    "next": {
      "name": "changePassword",
      "href": "https://okta.okta.com/api/v1/authn/credentials/change_password",
      "hints": {
        "allow": ["POST"]
      }
    },
    "cancel": {
      "href": "https://okta.okta.com/api/v1/authn/cancel",
      "hints": {
        "allow": ["POST"]
      }
    }
  }
}

"""

    /**
     * Generate a list of Mock Factors
     */
    public static func getOktaFactors() -> [OktaFactor] {
        
        let data = sample_json_oktaFactors.data(using: .utf8)!
        do {
            let factors: [EmbeddedResponse.Factor] = try decoder.decode([EmbeddedResponse.Factor].self, from: data)

            let oFactors: [OktaFactor] = factors.map {
                OktaFactor(factor: $0,
                           stateToken: "String",
                           verifyLink: nil,
                           activationLink: nil)
            }

            return oFactors
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
        return []
    }
    /**
     * Get Single mock factor
     */
    public static func getOktaFactor() -> OktaFactor {
        return getOktaFactors()[1]
    }
    
    /**
     * Generate Okta Success Response
     */
    public static func getOktaAPISuccessResponse() -> OktaAPISuccessResponse? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        do {
            let data = sample_json_successResponse.data(using: .utf8)!
            return try decoder.decode(OktaAPISuccessResponse.self, from: data)
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
        return nil
    }
    
    public static func getOktaAuthStatus() -> OktaAuthStatus {
        return OktaAuthStatus(oktaDomain: URL(fileURLWithPath: ""))
    }
    
    public static func getOktaAuthStatusFactorChallenge() -> OktaAuthStatusFactorChallenge? {
        do {
            if let successResponse = getOktaAPISuccessResponse() {
                return try OktaAuthStatusFactorChallenge(currentState: getOktaAuthStatus(), model: successResponse)
            }
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
        return nil
    }
    
    public static func getUserInfo() -> OktaUserInfo {
        return OktaUserInfo(
            uclUserid: "testAccount",
            email: "joe@somewhere.com",
            given_name: "Joe Smith",
            corpName: "testAccount",
            ont_roledn: ["role1", "role2"],
            uclAccesscodes: "access,a,b,c;access2,d,e,f",
            uclAgentid: "AG00000012",
            phone: "859-123-4567",
            businessPhone: "859-123-4567")
    }
}

/**
 * Mock Okta Implementation for testing / preview purposes
 */
public class MockOktaRepositoryImpl : OktaRepository {

    var signInPass = true
    var sendFactorPass = true
    var resendPass = true
    var verifyPass = true
    var userPass = true
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "MockOktaRepositoryImpl")
    
    public init() {
        
    }
    
    public func checkValidState() -> Error? {
        logger.log("mock repo checkValidState()")
        return OktaError.internalError("State not set")
    }
    
    public func signIn(username: String, password: String, onSuccess: @escaping (([OktaFactor])) -> Void, onError: @escaping ((String)) -> Void){
        logger.log("mock repo signIn()")
        if (signInPass) {
            onSuccess(OktaUtilMocks.getOktaFactors())
        } else {
            onError("Fail")
        }
    }
    public func sendFactor(factor: OktaFactor, onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void, onError: @escaping ((String)) -> Void){
        logger.log("mock repo sendFactor()")
        if sendFactorPass,
           let factorChallenge = OktaUtilMocks.getOktaAuthStatusFactorChallenge() {
            onSuccess(factorChallenge)
        } else {
            onError("Fail")
        }
    }
    public func cancelFactor() {
        logger.log("mock repo cancelFactor()")
    }
    public func resendFactor(onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void, onError: @escaping ((String)) -> Void) {
        logger.log("mock repo resendFactor()")
        if resendPass,
            let factorChallenge = OktaUtilMocks.getOktaAuthStatusFactorChallenge() {
            onSuccess(factorChallenge)
        } else {
            onError("Fail")
        }
    }
    public func verifyFactor(passCode: String, onSuccess: @escaping ((OktaAuthStatus)) -> Void, onError: @escaping ((String)) -> Void) {
        logger.log("mock repo verifyFactor()")
        if (verifyPass) {
            onSuccess(OktaUtilMocks.getOktaAuthStatus())
        } else {
            onError("Fail")
        }
    }
    public func getUser(onSuccess: @escaping ((OktaUserInfo)) -> Void, onError: @escaping ((String)) -> Void) {
        logger.log("mock repo getUser()")
        if (userPass) {
            onSuccess(OktaUtilMocks.getUserInfo())
        } else {
            onError("Fail")
        }
    }
    public func logout() {
        logger.log("mock repo logout()")
    }
    public func helper() {
        logger.log("mock repo helper()")
    }
}
