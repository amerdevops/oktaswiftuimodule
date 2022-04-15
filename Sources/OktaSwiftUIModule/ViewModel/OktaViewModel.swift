//
//  OktaViewModel.swift
//  OktaSwiftUIModule
//
//  Created by Nathan DeGroff on 12/10/21.
//

import Foundation
import OktaOidc
import OktaAuthNative
import os

/**
 * Okta View Model
 * This view model maintains the authenticated state of the app which the UI uses to draw appropriate screens.
 *
 */
open class OktaViewModel : ObservableObject {
    
    private let repo : OktaRepository
    
    private let isUITest : Bool
    
    public var isDemoMode: Bool = false
    
    @Published
    public var isAuthenticated : Bool = false
    
    @Published
    public var isMFA: Bool = false
    
    @Published
    public var alert: String = ""
    
    @Published
    public var showAlert: Bool = false
   
    @Published
    public var factors = [OktaFactor]()

    @Published
    public var userInfo: OktaUserInfo? = nil
    
    @Published
    public var isUserSet: Bool = false
    
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaViewModel")
    
    public init( _ repo: OktaRepository, _ isUITest: Bool ) {
        self.repo = repo
        self.isUITest = isUITest
        //------------------------------------------------------
        // Check saved state for validity
        initCheckState()
    }
    
    /**
     * Initially check saved state
     * If the internally saved state is valid, kick off getUser().  Otherwise, print error
     */
    func initCheckState() {
        let loggerInit = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaViewModel")
        loggerInit.log("CHECKING STATE....")
        let error = repo.checkValidState()
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            loggerInit.log("UI TEST (initCheckState)....")
            return
        }
        if let err = error {
            loggerInit.log("SAVE STATE ERR \(err.localizedDescription, privacy: .public)")
        } else {
            self.isMFA = true
            self.isAuthenticated = true
            getUser()
        }
    }
    
    /**
     * Handle onError
     * This method handles setting the state if an error occurs
     */
    private func onError(msg: String) {
        // Get error code
        let token = msg.components(separatedBy: ":")
        let errorCode = token[0]
        alert = errorCode.isEmpty ? msg : K.getCustomError(errorCode).isEmpty ? msg : K.getCustomError(errorCode)
        showAlert = true
        self.logger.log("\(msg, privacy: .public)")
        eventOnError(msg)
    }
    
    /**
     * Handle Sign in with name and password
     */
    public func signIn( name: String, cred: String ) {
        self.logger.log("SIGNING IN....")

        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { () -> Void in
            self.logger.log("SIGN IN SUCCESS: ")
            //---------------------------------------------------------
            // Change state if sign in was successful
            self.factors.removeAll()
            
            self.isMFA = true
            
            //---------------------------------------------------------
            // Change state if MFA verify was successful
            self.isAuthenticated = true

            //---------------------------------------------------------
            // Trigger get user
            self.getUser()
            
            //---------------------------------------------------------
            // Trap Event
            self.eventSignInSuccess()
        }
        
        let onMFAChallenge = { (factors: [OktaFactor]) -> Void in
            self.logger.log("MFA CHALLENGE: [\(factors.count, privacy: .public) factors]")
            //---------------------------------------------------------
            // Change state if sign in was successful
            self.factors.removeAll()
            self.factors.append(contentsOf: factors)
            self.isMFA = true
            
            //---------------------------------------------------------
            // Trap Event
            self.eventSignInSuccess()
        }
        
        

        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (signIn)....")
            onSuccess()
            return
        }

        //-----------------------------------------------
        // Call sign in
        repo.signIn(username: name, password: cred, onSuccess: onSuccess, onMFAChallenge: onMFAChallenge, onError: self.onError)
    }
    
    /**
     * Handle sending factor push (i.e. send SMS text, call, or email MFA)
     */
    public func sendFactor( factor: OktaFactor ) {
        self.logger.log("SENDING FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatusFactorChallenge) -> Void in
            self.logger.log("SENT FACTOR SUCCESS: [\(status.user?.id ?? "unknown", privacy: .public)][\(status.stateToken, privacy: .public)]")
            //---------------------------------------------------------
            // Trap Event
            self.eventSendFactorSuccess()
        }

        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (sendFactor)....")
            return
        }

        //-----------------------------------------------
        // Call send factor
        repo.sendFactor(factor: factor, onSuccess: onSuccess, onError: self.onError)
    }
    
    /**
     * NOTE: NOT USED YET.... Right now Okta changing MFA factor is broken... it won't return back to the success / error factor
     * Handle changing factor
     *
     * If you want to send a different factor, you have to cancel the first.  This method will
     * call the OktaRepository change factor which will handle cancelling before sending new
     */
    public func changeFactor( factor: OktaFactor ) {
        self.logger.log("Changing FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatusFactorChallenge) -> Void in
            self.logger.log("CHANGE FACTOR SUCCESS: [\(status.user?.id ?? "unknown", privacy: .public)][\(status.stateToken, privacy: .public)]")
            //---------------------------------------------------------
            // Trap Event
            self.eventSendFactorSuccess()
        }

        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (switchFactor)....")
            return
        }

        //-----------------------------------------------
        // Call change factor
        repo.changeFactor(factor: factor, onSuccess: onSuccess, onError: self.onError)
    }
    
    
    /**
     * Handle cancelling a factor (probably not used...)
     */
    public func cancelFactor () {
        isMFA = false
        isAuthenticated = false
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (cancelFactor)....")
            return
        }
        repo.cancelFactor()
    }

    /**
     * Handle resending a factor push (if user requests)
     */
    public func resendFactor( factor: OktaFactor ) {
        self.logger.log("RESENDING FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatusFactorChallenge) -> Void in
            self.logger.log("RESEND FACTOR SUCCESS: [\(status.user?.id ?? "unknown", privacy: .public)][\(status.stateToken, privacy: .public)]")
            //---------------------------------------------------------
            // Trap Event
            self.eventResendFactorSuccess()
        }
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (resendFactor)....")
            return
        }
        //-----------------------------------------------
        // Call resend factor
        repo.resendFactor(onSuccess: onSuccess, onError: self.onError)
    }

    /**
     * Handle verifying a factor's passcode attempt
     */
    public func verifyFactor( passCode: String ) {
        self.logger.log("VERIFYING FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatus) -> Void in
            self.logger.log("VERIFYING FACTOR SUCCESS: [\(status.user?.id ?? "unknown", privacy: .public)][\(status.statusType.rawValue, privacy: .public)]")
            //---------------------------------------------------------
            // Change state if MFA verify was successful
            self.isAuthenticated = true

            //---------------------------------------------------------
            // Trigger get user
            self.getUser()

            //---------------------------------------------------------
            // Trap Event
            self.eventVerifyFactorSuccess()
        }
        
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (verifyFactor)....")
            onSuccess(OktaUtilMocks.getOktaAuthStatus())
            return
        }

        //-----------------------------------------------
        // Call verify factor
        repo.verifyFactor(passCode: passCode, onSuccess: onSuccess, onError: self.onError)
    }
    /**
     * Get OIDC User Information
     */
    public func getUser() {
        //-----------------------------------------------
        // Stop early if user is already set
        if (self.isUserSet) {
            self.logger.log("User is already loaded....")
            return
        }
        
        print("LOADING USER....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (userInfo: OktaUserInfo) -> Void in
            self.logger.log("USER SUCCESS: [\(userInfo.given_name, privacy: .public)]")
            
            //---------------------------------------------------------
            // Load user info into state
            self.setOktaUserInfo(userInfo: userInfo)
        }
        
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (getUserInfo)....")
            onSuccess(OktaUtilMocks.getUserInfo())
            return
        }

        //-----------------------------------------------
        // Call Get User
        repo.getUser(onSuccess: onSuccess, onError: self.onError)
    }
    
    /**
     * Get Access Token
     * If access token is no longer valid (think expired) then it will asynchronously get new token
     */
    public func getAccessToken(onSuccess: @escaping ((String)) -> Void, onError: @escaping ((String)) -> Void) {
        
        //-----------------------------------------------
        // Call Get Access Token
        repo.getAccessToken(onSuccess: onSuccess, onError: onError)
    }
    
    public func logout() {
        self.logger.log("LOGOUT....")
        //-----------------------------------------------
        // Clear state indicators
        self.isMFA = false
        self.isAuthenticated = false
        self.isUserSet = false
        self.isDemoMode = false

        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            self.logger.log("UI TEST (logout)....")
            return
        }
        repo.logout()
    }
    
    public func helper() {
        repo.helper()
    }
    
    /**
     * App allows bypass of login / MFA and creates a mocked user
     */
    public func demoMode() {
        //---------------------------------------------------------
        // Change state to demo mode user and bypass additional
        // Okta checkpoints
        self.isDemoMode = true
        self.setOktaUserInfo(userInfo: OktaUtilMocks.getUserInfo())
        self.isMFA = true
        self.isAuthenticated = true
    }
    
    /**
     * Capture the event when setting the UserInfo is set
     * Can be used in applications to override and trap the event when the user info is set by
     * asyncrhonous API
     */
    public func setOktaUserInfo(userInfo: OktaUserInfo) {
        //---------------------------------------------------------
        // Change state to demo mode user
        self.userInfo = userInfo
        self.isUserSet = true
        eventSetOktaUserInfo(userInfo)
    }
    
    open func eventSetOktaUserInfo(_ userInfo: OktaUserInfo) {
        // Override event in usage application
    }
    open func eventSignInSuccess() {
        // Override event in usage application
    }
    open func eventSendFactorSuccess() {
        // Override event in usage application
    }
    open func eventResendFactorSuccess() {
        // Override event in usage application
    }
    open func eventVerifyFactorSuccess() {
        // Override event in usage application
    }
    open func eventOnError(_ msg: String) {
        // Override event in usage application
    }
}
