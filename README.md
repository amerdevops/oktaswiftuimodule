
![Badge](https://img.shields.io/badge/Application:-iOS%20Agent%20Mobile-brightgreen)
![Badge](https://img.shields.io/badge/Platform:-SwiftUI-blue?logo=apple)<br/>
![Badge](https://img.shields.io/badge/Library%20Security:-Okta-orange?logo=Okta)<br/>
![Badge](https://img.shields.io/badge/Topic:-Module%20Overview-blueviolet)<br/>

# Okta Swift UI Module
This module contains Ameritas specific Okta screens and logic to handle a custom connection. 


### **<span style="color:orange">How to use</span>**

- **Add Dependency** - Add the https://bitbucket.inbison.com/scm/im/oktaswiftuimodule.git dependency to your SwiftUI project
- **Create Okta PList(s)** - Create an Okta PList with environment specific values
- **Extend OktaViewModel** - Extend okta view model

```
    public init() {
        super.init(OktaRepositoryImpl(<nameofOktaPList>), ProcessInfo.processInfo.arguments.contains("isUITest"))
    }
```


### **<span style="color:orange">Fonts, Colors, and Styles</span>**

We simplify the code so in one method you can set the adaptive font style / color / weight in one method call.  We do this by extending the View class.  The code would look like:
```
//-----------------------------------------------
// Draw message
Text(getMsg())
    .headline()
```

Click on the following link to follow for more detail:
* **[Fonts, Colors, and Styles](./FontStyles.md)**


### **<span style="color:orange">Dependency Modules</span>**
This module requires the inclusion of 2 additional modules (OktaAuthNative and OktaOidc)




