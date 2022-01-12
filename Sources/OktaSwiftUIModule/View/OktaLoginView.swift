//
//  SwiftUIView.swift
//  
//
//  Created by Nathan DeGroff on 12/10/21.
//
import SwiftUI

// NOTE: Need this to make sure only iOS compile creates view
// System will fail compile because macOS doesn't support a few SwiftUI methods
#if !os(macOS)

/**
 * Login View
 * Handle Username / password
 */
public struct OktaLoginView: View {
    var onLoginClick: (_ name: String, _ cred: String) -> Void
    var onDemoModeClick: () -> Void
    var demoMode: Bool
    
    @State var name: String = ""
    @State var cred: String = ""
    @State var acceptTAndC = false
    @State var demoAccept = false
    
    public init(demoMode: Bool,
                onLoginClick: @escaping (_ name: String, _ cred: String) -> Void,
                onDemoModeClick: @escaping () -> Void) {
        self.onLoginClick = onLoginClick
        self.onDemoModeClick = onDemoModeClick
        self.demoMode = demoMode
        UINavigationBar.appearance().backgroundColor = .none
    }

    /**
     * Primary SwiftUI Render method
     * Allow the client to login with name / password
     */
    public var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Spacer()
                Image("ameritas_logo", bundle: .module)
                    .frame(alignment: .center)
                Spacer()
            }.frame(alignment: .center)
            Form {
                TextField("Username", text: $name)
                    .padding()
                    .border(Color.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                SecureField("Password", text: $cred)
                    .padding()
                    .border(Color.black)

                Button(action: { acceptTAndC = !acceptTAndC }){
                    HStack{
                        Image(systemName: acceptTAndC ? "checkmark.square": "square")
                        Text("I accept Ameritas Terms and Conditions")
                            .foregroundColor(Color.black)
                    }
                }
                if demoMode {
                    Toggle(isOn: $demoAccept) {
                        Text("Demo Mode")
                    }
                }
                
                Button("Login") {
                    print("Pressing Login button...")
                    //-----------------------------------------------
                    // If demo mode is available and was selected...
                    if demoMode && demoAccept {
                        self.onDemoModeClick()
                    }
                    //-----------------------------------------------
                    // Otherwise, login like normal
                    else {
                        self.onLoginClick(name, cred)
                    }
                }
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(RoundedRectangle(cornerRadius: 8).fill(buttonColor))
                    .disabled(acceptTAndC == false)
            }
            .frame(maxWidth: 300, maxHeight: 470, alignment: .center)
            .cornerRadius(5)
        }
    }
    
    var buttonColor : Color {
        return (acceptTAndC ? Color.blue : Color.gray)
    }

}

//---------------------------------------------------------
// Previews
//---------------------------------------------------------
/**
 * Preview Login View
 */
struct LoginView_Previews: PreviewProvider {

    static var previews: some View {
        let onLoginClick = { ( name: String, cred: String) -> Void in
            print("\(name), \(cred)")
        }
        let onDemoModeClick = { () -> Void in
            print("demo mode")
        }
        OktaLoginView( demoMode: true,
            onLoginClick: onLoginClick,
            onDemoModeClick: onDemoModeClick )
    }
}
#endif
