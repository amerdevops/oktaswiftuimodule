//
//  OktaViewModel.swift
//  OktaSwiftUIModule
//
//  Created by Nathan DeGroff on 12/10/21.
//

import Foundation
import OktaOidc
import OktaAuthNative

/**
 * Okta View Model
 * This view model maintains the authenticated state of the app which the UI uses to draw appropriate screens.
 *
 */
public class OktaViewModel : ObservableObject {
    
    private let repo : OktaRepository
    
    private let isUITest : Bool
    
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
    public var user: UserInfo? = nil
    
    @Published
    public var isUserSet: Bool = false
    
    public init( _ repo: OktaRepository, _ isUITest: Bool ) {
        self.repo = repo
        self.isUITest = isUITest
        
        let args = ProcessInfo.processInfo.arguments
        //------------------------------------------------------
        // Check saved state for validity
        initCheckState()
    }
    
    /**
     * Initially check saved state
     * If the internally saved state is valid, kick off getUser().  Otherwise, print error
     */
    func initCheckState() {
        print("CHECKING STATE....")
        let error = repo.checkValidState()
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (initCheckState)....")
            return
        }
        if let err = error {
            print("SAVE STATE ERR \(err.localizedDescription)")
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
        alert = msg
        showAlert = true
    }
    
    /**
     * Handle Sign in with name and password
     */
    public func signIn( name: String, cred: String ) {
        print("SIGNING IN....")

        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (factors: [OktaFactor]) -> Void in
            print("SIGN IN SUCCESS: [\(factors.count) factors]")
            //---------------------------------------------------------
            // Change state if sign in was successful
            self.factors.removeAll()
            self.factors.append(contentsOf: factors)
            self.isMFA = true
        }

        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (signIn)....")
            onSuccess(UtilMocks.getOktaFactors())
            return
        }

        //-----------------------------------------------
        // Call sign in
        repo.signIn(username: name, password: cred, onSuccess: onSuccess, onError: self.onError)
    }
    
    /**
     * Handle sending factor push (i.e. send SMS text, call, or email MFA)
     */
    public func sendFactor( factor: OktaFactor ) {
        print("SENDING FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatusFactorChallenge) -> Void in
            print("SENT FACTOR SUCCESS: [\(status.user?.id ?? "unknown")][\(status.stateToken)]")
        }

        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (sendFactor)....")
            return
        }

        //-----------------------------------------------
        // Call send factor
        repo.sendFactor(factor: factor, onSuccess: onSuccess, onError: self.onError)
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
            print("UI TEST (cancelFactor)....")
            return
        }
        repo.cancelFactor()
    }

    /**
     * Handle resending a factor push (if user requests)
     */
    public func resendFactor( factor: OktaFactor ) {
        print("RESENDING FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatusFactorChallenge) -> Void in
            print("RESEND FACTOR SUCCESS: [\(status.user?.id ?? "unknown")][\(status.stateToken)]")
        }
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (resendFactor)....")
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
        print("VERIFYING FACTOR....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (status: OktaAuthStatus) -> Void in
            print("VERIFYING FACTOR SUCCESS: [\(status.user?.id ?? "unknown")][\(status.statusType.rawValue)]")
            //---------------------------------------------------------
            // Change state if MFA verify was successful
            self.isAuthenticated = true

            //---------------------------------------------------------
            // Trigger get user
            self.getUser()
        }
        
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (verifyFactor)....")
            onSuccess(UtilMocks.getOktaAuthStatus())
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
            print("User is already loaded....")
            return
        }
        
        print("LOADING USER....")
        //-----------------------------------------------
        // Define Success closure
        let onSuccess = { (user: UserInfo) -> Void in
            print("USER SUCCESS: [\(user.given_name)]")
            
            //---------------------------------------------------------
            // Load user info into state
            self.user = user
            self.isUserSet = true
        }
        
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (getUserInfo)....")
            onSuccess(UtilMocks.getUserInfo())
            return
        }

        //-----------------------------------------------
        // Call Get User
        repo.getUser(onSuccess: onSuccess, onError: self.onError)
    }
    
    public func logout() {
        print("LOGOUT....")
        //-----------------------------------------------
        // Clear state indicators
        self.isMFA = false
        self.isAuthenticated = false
        self.isUserSet = false
        //-----------------------------------------------
        // Mock Data if UI Test
        if (isUITest) {
            print("UI TEST (logout)....")
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
        // Change state to demo mode user
        self.user = UtilMocks.getUserInfo()
        self.isUserSet = true
        self.isMFA = true
        self.isAuthenticated = true

    }
}
