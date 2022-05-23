![Badge](https://img.shields.io/badge/Application:-iOS%20Agent%20Mobile-brightgreen)
![Badge](https://img.shields.io/badge/Platform:-SwiftUI-blue?logo=apple)<br/>
![Badge](https://img.shields.io/badge/Topic:-Fonts,%20Colors,%20and%20Styes-blueviolet)<br/>

# Fonts, Colors, and Styles


### **<span style="color:orange">Built in View modifiers</span>**
Since the fonts styles/weights/colors are similar across all sketch screens, it makes sense to standardize in one place.

In the `OktaConstants.swift` file, we've extended the `View` object so you only need to call one method and it will set that View's style to match the Sketch design.

The following table helps translate the Sketch design.  Check the text values in image and then check table for corresponding modifier.  For example:

<table>
    <thead>
        <tr>
            <th>Screenshot</th>
            <th>Resolves to:</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><img src="docs/img/SketchTextStyle.png" alt="Example Sketch" width="500"/></td>
            <td><code>headline (TextStyle), medium (weight), #333333 (color) = .headline()</code></td>
        </tr>
    </tbody>
</table>

In one method, you set the text color, weight, and style.  The code would look like:
```
//-----------------------------------------------
// Draw message
Text(getMsg())
    .headline()
```

| Font.TextStyle | Weight | Color (light) | Custom View Modifier |
| --- | --- | --- | --- |
| largeTitle |  |  |  |
| title | medium | (#000000) - .contrast | `.titleContrast()` |
| title | medium | (#595959) - .lightDarkGray | `.titleGray()` |
| title2 |  |  |  |
| title3 |  |  |  |
| headline | medium | (#333333) -.secondaryBlack | `.headline()` |
| subheadline |  |  |  |
| body | medium | (#000000) - .contrast | `.bodyContrast()` |
| body | medium | (#FFFFFF) - .reverse | `.bodyReverse()` |
| body | medium | (#595959) -.lightDarkGray | `.bodyGray()` |
| body | regular | (#595959) -.lightDarkGray | `.bodyGrayReg()` |
| body | regular | (#000000) - .contrast | `.labelContrast()` |
| body | regular | (#333333) -.secondaryBlack | `.labelDark()` |
| callout |  |  |  |
| footnote | regular | (#595959) -.lightDarkGray | `.footnote()` |
| footnote | medium | (#333333) -.secondaryBlack | `.footnoteHdr()` |
| caption | regular | (#595959) -.lightDarkGray | `.captionGray()` |
| caption2 |  |  |  |

### **<span style="color:orange">K.BrandColors and K.getColor()</span>**
The following table helps translate the Sketch design hex colors with the matching brand colors.  Use this to color the SF Images.
The `K.getColor` takes in the `CustomColorScheme` enum and whether the OS is in DARK or not, and translates the color.

| Color Hex | K.BrandColor (Light) | K.getColor() | Matching in Dark |
| --- | --- | --- | --- |
| #000000 | .black | `.contrast` | .white |
| #FFFFFF | .white | `.reverse` | .black |
| #595959 | .lightDarkGray | `.lightDarkGray` | .primaryLightGray |
| #333333 | .secondaryBlack | `.secondaryBlack` | .white |
| #767676 | .primaryLightGray | `.primaryLightGray` | .white |
| #D3222A | .redError | `.redError` | .lightRedError |
| #9C9C9C | .gray | `.gray` | .darkGray |
| #0758AC | .blue | `.blue` | .lightBlue |
| #32571A | .green | `.green` | .darkGreen |
| #E36A00 | .orange | `.orange` | .lightOrange |
| #E8E8E9 | .lightGray |  |  |
| #838387 | .darkGray |  |  |
| #F9F9F9 | .veryLightGray |  |  |
| #BE6064 | .lightRedError |  |  |
| #32571A | .darkGreen |  |  |
| #F3AF22 | .lightOrange |  |  |

