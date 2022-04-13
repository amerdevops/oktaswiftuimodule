//
//  OktaRepository.swift
//  OktaSwiftUIPOC
//
//  Created by Nathan DeGroff on 11/15/21.
//

import Foundation
import OktaOidc
import OktaAuthNative
import os

/**
 * Okta Repository Protocol
 *
 * Defines key methods that the Okta Repository can perform
 *
 * Most of the methods define an "onSuccess" and "onError" closure.  This allows the method to perform the action asyncrohonously
 * and call the closure and pass in related information on success or on failure.  This decouples the app's state from network calls
 * and allows the state to define what happens on success and on failure
 */
public protocol OktaRepository {
    func checkValidState() -> Error?
    func signIn(username: String, password: String, onSuccess: @escaping () -> Void,  onMFAChallenge: @escaping (([OktaFactor])) -> Void, onError: @escaping ((String)) -> Void)
    func sendFactor(factor: OktaFactor, onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void, onError: @escaping ((String)) -> Void)
    func changeFactor(factor: OktaFactor, onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void, onError: @escaping ((String)) -> Void)
    func cancelFactor()
    func resendFactor(onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void, onError: @escaping ((String)) -> Void)
    func verifyFactor(passCode: String, onSuccess: @escaping ((OktaAuthStatus)) -> Void, onError: @escaping ((String)) -> Void)
    func getUser(onSuccess: @escaping ((OktaUserInfo)) -> Void, onError: @escaping ((String)) -> Void)
    func getAccessToken(onSuccess: @escaping ((String)) -> Void, onError: @escaping ((String)) -> Void)
    func logout()
    func helper()
}

/**
 * Functional Okta Repository Implementation
 *
 * This class handles making asynchronous calls to Okta through the Okta SDK as well as maintaining
 * the Okta OIDC Config, the current okta status, and OIDC State Manager
 */
public class OktaRepositoryImpl : OktaRepository {
    var oktaOidcConfig : OktaOidcConfig?
    var oktaOidc : OktaOidc?
    var stateManager: OktaOidcStateManager?
    var user: OktaOidcStateManager?
    var oktaStatus: OktaAuthStatus?
    let logger = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaRepositoryImpl")
    var urlString: String?
    
    public convenience init() {
        self.init(nil)
    }
    
    public init(_ fromPlist: String?) {
        let loggerInst = Logger(subsystem: "com.ameritas.indiv.mobile.OktaSwiftUIModule", category: "OktaRepositoryImpl")
        do {
            //---------------------------------------------------------------
            // Pull Okta OIDC configuration from Okta.plist or specified list
            if let fromPlist = fromPlist {
                oktaOidcConfig = try OktaOidcConfig(fromPlist: fromPlist)
                oktaOidc = try OktaOidc(configuration: oktaOidcConfig)
            } else {
                oktaOidc = try OktaOidc()
                oktaOidcConfig = oktaOidc?.configuration
            }
            //---------------------------------------------------------------
            // Pull main URL from Okta Configuration
            if let issuer = oktaOidc?.configuration.issuer,
               let myUrl = URL(string: issuer) {
                urlString = "https://" + (myUrl.host ?? "")
            }
        } catch let error {
            DispatchQueue.main.async {
                loggerInst.error("\(error.localizedDescription)")
            }
            return
        }
    
        //---------------------------------------------------------------
        // Pull / store Okta status from secure storage
        if  let oktaOidc = oktaOidc,
            let sm : OktaOidcStateManager = OktaOidcStateManager.readFromSecureStorage(for: oktaOidc.configuration) {
            // Hold onto the stored state manager
            // NOTE: the access token may be expired (that is checked in getUser())
            self.stateManager = sm
        } else {
            loggerInst.error("Okta OIDC State manager not loaded")
        }
    }

    /**
     * Refresh token
     */
    public func refreshToken(onSuccess: @escaping () -> Void,
                      onError: @escaping ((String)) -> Void) {
        
        //---------------------------------------------------------------
        // Pull / store Okta status from secure storage
        if let sm = stateManager {
            sm.renew(callback: { [weak self] stateManagerNew, error in
                // If we couldn't renew...
                if let error = error {
                    // clear existing saved manager from storage
                    self?.logout()
                    // Call error state
                    onError(error.localizedDescription)
                    return
                }
                // If have a new state manager...
                if let smNew = stateManagerNew {
                    // Save to secure storage
                    smNew.writeToSecureStorage()
                    self?.stateManager = smNew
                    self?.logger.log("Token Refreshed! [\(smNew.accessToken ?? "noAccessToken")]")
                    // handle success
                    onSuccess()
                } else {
                    self?.logger.log("That's a bummer....")
                }
            })
        }
    }
//------------------------------------------------------------------
// MAIN Functions
//------------------------------------------------------------------
    /**
     * Check if Valid state and token (Synchronous)
     *
     * This method will check if the OIDC state manager has been initiated AND if the associated
     * OIDC ID token is valid (i.e. valid JWT and not expired)
     * If the manager exists and the ID token is still valid, then nil is returned.
     * Otherwise, the related error will be returned
     */
    public func checkValidState() -> Error? {
        if let mgr = self.stateManager {
            self.logger.log("STATE MAN LOADED: \(mgr.accessToken ?? "unknown", privacy: .public)")
            return mgr.validateToken(idToken: mgr.idToken)
        }
        return OktaOidcError.JWTValidationError("State manager not loaded")
    }
    

    /**
     * Sign in to Okta with username / password (Async)
     *
     * This method allows the app to sign in with username / password.
     *
     * The method is asynchronously calling Okta.  On success, it will return a list of valid Okta factors for the user.
     * The calling function must implement a closure that accepts the valid OktaFactors and changes the UI based
     * on the results.
     */
    public func signIn(username: String, password: String,
                onSuccess: @escaping () -> Void,
                onMFAChallenge: @escaping (([OktaFactor])) -> Void,
                onError: @escaping ((String)) -> Void) {

        //-----------------------------------------------
        // Define Success / Failure closures
        let successBlock: (OktaAuthStatus) -> Void = { [weak self] status in
            if let mfaStatus = status as? OktaAuthStatusFactorRequired {
                onMFAChallenge(mfaStatus.availableFactors)
                self?.handleStatus(status: status)
            }
            else if let successStatus = status as? OktaAuthStatusSuccess{
                self?.handleStatus(status: status)
                self?.authenticateOIDC(onSuccess: onSuccess, onError: onError)
            }
            else {
                onError("ERROR OCCURRED: \(status.statusType)")
                self?.handleStatus(status: status)
            }
            
        }
        
        // handle error
        let errorBlock: (OktaError) -> Void = { error in
            onError(handleError(error: error))
        }
        //-----------------------------------------------
        // Authenticate...
        if let urlOkta = urlString {
            OktaAuthSdk.authenticate(with: URL(string: urlOkta)!,
                                     username: username,
                                     password: password,
                                     onStatusChange: successBlock,
                                     onError: errorBlock)
            
        }
    }

    /**
     * Change factor (Async)
     *
     * This method will take in an OktaFactor and trigger the factor.
     *
     * If the factor is successful, it will return a success factor challenge.  The calling function must pass a closure that accepts the
     * challenge and changes UI based on result.
     */
    public func sendFactor(factor: OktaFactor,
                    onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void,
                    onError: @escaping ((String)) -> Void) {
        //-----------------------------------------------
        // Define Success / Failure closures
        let successBlock: (OktaAuthStatus) -> Void = { [weak self] status in
            self?.handleStatus(status: status)
            if let mfaStatus = status as? OktaAuthStatusFactorChallenge {
                onSuccess(mfaStatus)
            }
        }
        let errorBlock: (OktaError) -> Void = { error in
            onError(error.localizedDescription)
        }
        //-----------------------------------------------
        // Trigger send factor
        if ( factor.canSelect() ) {
            factor.select(onStatusChange: successBlock, onError: errorBlock)
        }
        
    }
    
    /**
     * Send factor (Async)
     *
     * This method will cancel the existing factor and then request the new factor
     *
     * If the factor is successful, it will return a success factor challenge.  The calling function must pass a closure that accepts the
     * challenge and changes UI based on result.
     */
    public func changeFactor(factor: OktaFactor,
                    onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void,
                    onError: @escaping ((String)) -> Void) {
        
        //-----------------------------------------------
        // Define Success / Failure closures
        let successCancelBlock: (() -> Void) = { [weak self] in

            self?.logger.log("CANCEL SUCCESS: Old factor cancelled, now sending new...")
            //-----------------------------------------------
            // Send new factor
            self?.sendFactor(factor: factor, onSuccess: onSuccess, onError: onError)
        }
        let errorCancelBlock: ((String) -> Void) = { errorString in
            onError(errorString)
        }

        //-----------------------------------------------
        // Send Cancel existing factor
        cancelFullFactor(onSuccess: successCancelBlock, onError: errorCancelBlock)
    }

    /**
     * Resend the current factor (Async)
     *
     * Okta Repository tracks the latest MFA challenge.  If the current Okta status is a challenge, then it will resend the
     * MFA challenge again.
     */
    public func resendFactor(onSuccess: @escaping ((OktaAuthStatusFactorChallenge)) -> Void,
                      onError: @escaping ((String)) -> Void) {
        
        if let mfaStatus = oktaStatus as? OktaAuthStatusFactorChallenge {
            if mfaStatus.canResend() {
                //-----------------------------------------------
                // Define Success / Failure closures
                let successBlock: (OktaAuthStatus) -> Void = { [weak self] status in
                    self?.handleStatus(status: status)
                    if let mfaStatus = status as? OktaAuthStatusFactorChallenge {
                        onSuccess(mfaStatus)
                    }
                }
                let errorBlock: (OktaError) -> Void = { error in
                    onError(error.localizedDescription)
                }
                
                //-----------------------------------------------
                // Trigger resend factor
                mfaStatus.resendFactor(onStatusChange: successBlock, onError: errorBlock)
            }
        }
    }

    /**
     * Allow trapping cancel factor
     */
    private func cancelFullFactor(onSuccess: (() -> Void)? = nil,
                            onError: ((String) -> Void)? = nil) {
        
        if let status = oktaStatus as? OktaAuthStatusFactorChallenge {
            if status.canCancel() {
                //-----------------------------------------------
                // Define Success / Failure closures
                let successBlock: () -> Void = {
                    if (onSuccess != nil ) {
                        onSuccess!()
                    }
                }
                let errorBlock: (OktaError) -> Void = { error in
                    if (onError != nil ) {
                        onError!(error.localizedDescription)
                    }
                }
                //-----------------------------------------------
                // Trigger cancel factor
                self.logger.log("Cancelling STATUS: [\(status.stateToken, privacy: .public)][\(status.statusType.rawValue, privacy: .public)")
                oktaStatus?.cancel(onSuccess: successBlock, onError: errorBlock)
            }
        }
        
    }
    
    /**
     * Cancel the current factor status (if possible)
     *
     * This method will cancel a given MFA Factor challenge
     */
    public func cancelFactor() {
        cancelFullFactor()
    }
    
    /**
     * Verify MFA Factor (Async)
     *
     * This method will verify if the passcode a user enters matches the MFA Factor challenge
     */
    public func verifyFactor(passCode: String,
                      onSuccess: @escaping ((OktaAuthStatus)) -> Void,
                      onError: @escaping ((String)) -> Void) {
        if let status = oktaStatus as? OktaAuthStatusFactorChallenge {
            let factor = status.factor
            //-----------------------------------------------
            // Define Success / Failure closures
            let successBlock: (OktaAuthStatus) -> Void = { [weak self] status in
                //---------------------------------------------------------------------
                // Trigger OIDC authentication
                self?.handleStatus(status: status)
                
                //---------------------------------------------------------------------
                // If MFA was successful, Trigger OIDC authentication to create state
                // manager.  Pass along the onSuccess status
                self?.logger.log("MFA successful, triggering OIDC")
                let onOIDCSuccess = { onSuccess(status) }
                self?.authenticateOIDC(onSuccess: onOIDCSuccess, onError: onError)
            }
            let errorBlock: (OktaError) -> Void = { error in
                onError(error.localizedDescription)
            }

            //---------------------------------------------------------------------
            // Call verify factor
            factor.verify(passCode: passCode,
                          answerToSecurityQuestion: nil,
                          onStatusChange: successBlock, onError: errorBlock)

        }
    }

    /**
     * Get OIDC user info (Async)
     *
     * Using the OIDC State Manager, make a call to pull and load the OktaUserInfo
     */
    public func getUser(onSuccess: @escaping ((OktaUserInfo)) -> Void, onError: @escaping ((String)) -> Void) {
        //---------------------------------------------------------------------
        // get state manager
        if let sm = self.stateManager {
            
            //---------------------------------------------------------------
            // if the stored access token expired, need to trigger refresh (if possible)
            // BEFORE getting user
            if (sm.accessToken == nil) {
                self.logger.log("REFRESH TOKEN BEFORE getUser....")
                let onSuccessRefresh : () -> Void = { [weak self] in
                    // if refresh successful, call get user NOW
                    self?.helper_getUser(onSuccess: onSuccess, onError: onError)
                }
                let onErrorRefresh : (String) -> Void = { errMsg in
                    // if refresh failed....
                    onError("REFRESH getUser: AWW \(errMsg)")
                }
                // Refresh token before calling get User
                refreshToken(onSuccess: onSuccessRefresh, onError: onErrorRefresh)
            }
            //---------------------------------------------------------------
            // Otherwise, go right to getting the User
            else {
                helper_getUser(onSuccess: onSuccess, onError: onError)
            }

        } else {
            onError("State manager doesn't exist")
        }

    }
    
    /**
     * Get Access Token
     * If the token has expired, get a new token.
     */
    public func getAccessToken(onSuccess: @escaping ((String)) -> Void, onError: @escaping ((String)) -> Void) {       //---------------------------------------------------------------------
        // Get state manager
        
        if let sm = self.stateManager {
            self.logger.log("GET ACCESS TOKEN: \(sm.accessToken ?? "unknown", privacy: .public)")
            //---------------------------------------------------------------------
            // Access token will be nil if expired or invalid
            if let accessToken = sm.accessToken {
                onSuccess(accessToken)
            } else {
                //---------------------------------------------------------------------
                // Setup success
                let onSuccessRefresh : () -> Void = { [weak self] in
                    self?.logger.log("GET ACCESS TOKEN: onSuccessRefresh")
                    guard let sm1 = self?.stateManager,
                          let token = sm1.accessToken else {
                        onError("GET ACCESS TOKEN: Could not get new token")
                        return
                    }
                    self?.logger.log("GET ACCESS TOKEN: Success \(token)")
                    onSuccess(token);
                }
                //---------------------------------------------------------------------
                // Refresh token
                refreshToken(onSuccess: onSuccessRefresh, onError: onError)
            }
        } else {
            onError("GET ACCESS TOKEN: State manager doesn't exist")
        }
    }

    
    /**
     * Logout of app
     */
    public func logout() {
        //---------------------------------------------------------------------
        // get state manager
        if let sm = self.stateManager {
            do {
                //---------------------------------------------------------------
                // Try to remove OIDC client from Keychain
                try sm.removeFromSecureStorage()
                self.stateManager = nil
            } catch let error {
                self.logger.error("\(error.localizedDescription, privacy: .public)")
                return
            }
        } else {
            self.logger.log("No OIDC State manager to logout from")
        }
    }
    
    /**
     * Helper function (TODO: DELETE ME)
     * This is a helper function that allows a UI action to run a dummy command through the view model and repository
     * to debug a current state or whatever
     */
    public func helper() {
        if let status = oktaStatus {
            self.logger.log("HELPER: ")
            logStatus(status)
            if let mfaStatus = status as? OktaAuthStatusFactorChallenge {
                self.logger.log("DETAIL: [\(mfaStatus.stateToken, privacy: .public)][\(mfaStatus.factor.type.rawValue, privacy: .public)]")
                self.logger.log("LINKS: [\(String(describing: mfaStatus.links), privacy: .public)]")
            }
        }
    }

//------------------------------------------------------------------
// HELPER Functions
//------------------------------------------------------------------
    func helper_getUser(onSuccess: @escaping ((OktaUserInfo)) -> Void, onError: @escaping ((String)) -> Void) {
        
        if let sm = self.stateManager {
            //-------------------------------------------------------------
            // Successfully logged in, store it to device and to repo
            sm.getUser { (attributes, error) in
                if let err = error {
                    onError(err.localizedDescription)
                } else {
                    if let atts = attributes {
                        let userInfo = OktaUserInfo(
                            uclUserid: atts["uclUserid"] as? String ?? "",
                            email: atts["email"] as? String ?? "",
                            given_name: atts["name"] as? String ?? "",
                            corpName: atts["corpName"] as? String ?? "",
                            ont_roledn: atts["ont_roledn"] as? [String] ?? [],
                            uclAccesscodes: atts["uclAccesscodes"] as? String ?? "",
                            uclAgentid: atts["uclAgentid"] as? String ?? "",
                            phone: atts["primaryPhone"] as? String ?? "TBD",
                            businessPhone: atts["primaryPhone"] as? String ?? "TBD")
                        
                        onSuccess(userInfo)
                    }
                }
            }
        }
    }
    /**
     * Authenticate into OIDC using the current session token
     *
     * Once the user has successfully passed MFA, this method will start the OIDC handshake
     * with the single use session token to pull back the refresh / access / ID tokens
     */
    private func authenticateOIDC(onSuccess: @escaping () -> Void, onError: @escaping ((String)) -> Void) {
        
        self.logger.log("Starting authenticateOIDC()...")
        if let oidcClient = oktaOidc,
           let status = oktaStatus as? OktaAuthStatusSuccess {
            self.logger.log("Asking OIDC client for access token...")
            oidcClient.authenticate(withSessionToken: status.sessionToken!, callback: { [weak self] stateManager, error in
                if let err = error {
                    onError(err.localizedDescription)
                } else {
                    if let sm = stateManager {
                        //-------------------------------------------------------------
                        // Successfully logged in, store it to device and to repo
                        sm.writeToSecureStorage()
                        self?.stateManager = sm
                        self?.logger.log("StateManager: [\(sm.accessToken ?? "noAccessToken", privacy: .public)]")
                        
                        //-------------------------------------------------------------
                        // Let caller know they successfully logged in
                        onSuccess()
                    }
                }
                
            })
        }
    }
    
    func logStatus(_ status: OktaAuthStatus) {
        self.logger.log("STATUS: \(status.statusType.rawValue, privacy: .public)")
    }

    /**
     * Just log valid factors that were returned.
     */
    func handleMFARequired(status: OktaAuthStatus) {
        var factors: [OktaFactor] {
            let mfaRequiredStatus = status as! OktaAuthStatusFactorRequired
                 return mfaRequiredStatus.availableFactors
             }
        for factor in factors {
            self.logger.log("Factor: \(factor.type.rawValue, privacy: .public)")
        }
    }
    /**
     * Handle Okta State
     * This method was pulled from Okta samples on identifying the Okta State engine and providing a place
     * to handle specific states that may be returned from Okta.
     */
    func handleStatus(status: OktaAuthStatus) {
        
        oktaStatus = status
        switch status.statusType {
            
            case .success:
                logStatus(status)

            case .passwordWarning:
                // TODO
                logStatus(status)
            
            case .passwordExpired:
                // TODO
                logStatus(status)

            case .MFARequired:
                logStatus(status)
                handleMFARequired(status: status)
            case .MFAChallenge:
                logStatus(status)
            
            case .MFAEnroll:
                // TODO
                logStatus(status)
                 
            case .MFAEnrollActivate:
                // TODO (Probably don't need this as app would have to enroll
                logStatus(status)
            
            case .recoveryChallenge:
                // TODO
                logStatus(status)
            
            case .recovery:
                // TODO
                logStatus(status)

            case .passwordReset:
                // TODO
                logStatus(status)
            
            case .lockedOut:
                // TODO
                logStatus(status)
            
            case .unauthenticated:
                // TODO
                logStatus(status)
            
            case .unknown(_):
                // TODO
                logStatus(status)
        }
    }
    
    func handleError(error: OktaError) -> String {
        switch error {
            case .serverRespondedWithError(let errorResponse):
                //print("Error: \(errorResponse.errorSummary ?? "server error")")
            return errorResponse.errorCode + ": " + error.description
            default:
                return error.description
                //print("Error: \(error.description)")
            
        }
    }
}
