////
////  File.swift
////  
////
////  Created by Randy Speakman on 6/29/22.
////
//
//
//
//import Foundation
//import LocalAuthentication
//
//
//class BiometricUtil {
//    /**
//     Launch biometric authentication with TouchID or FaceID
//     
//     Regarding unsuccessful attempts. Per the Apple documentation
//     
//     "Policy evaluation fails if Touch ID or Face ID is unavailable or not enrolled. Evaluation also fails after three failed Touch ID attempts. After two failed Face ID attempts, the system offers a fallback option, but stops trying to authenticate with Face ID. Both Touch ID and Face ID authentication are disabled system-wide after five consecutive unsuccessful attempts, even when the attempts span multiple evaluation calls. When this happens, the system requires the user to enter the device passcode to reenable biometry."
//     */
//    static func launchBiometric(biometricAuthListener: BiometricAuthListener) {
//        
//        let context = LAContext()
//        var error: NSError?
//        
//        //Does the device support biometrics.
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Fast login using biometrics"
//            
//            //Launches the authentication
//            //Will fail if Toucafter 3 failed attempts
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
//                //auth completed
//                DispatchQueue.main.async {
//                    if success {
//                        biometricAuthListener.onBiometricAuthenticationSuccess()
//                    } else {
//                        biometricAuthListener.onBiometricAuthenticationError(errorMessage: authenticationError?.localizedDescription)
//                    }
//                }
//            }
//        } else {
//            DispatchQueue.main.async {
//                biometricAuthListener.onBiometricAuthenticationError(errorMessage: error?.localizedDescription)
//            }
//        }
//        
//    }
//}
//
//
//
/////**
//// Defines methods to be used to handle success and failure events from biometric authentication
//// */
////protocol BiometricAuthListener {
////    /**
////     Handle successful biometric authentication
////     */
////    func onBiometricAuthenticationSuccess()
////    
////    /**
////     Handle errors with biometric authentication
////     */
////    func onBiometricAuthenticationError(errorMessage: String?)
////}
