//
//  Font+SpaceGrotesk.swift
//  axe-mobile-app
//
//  Custom font extension for Space Grotesk
//

import SwiftUI

extension Font {
    // MARK: - Space Grotesk Fonts
    
    /// Space Grotesk Light (300)
    static func spaceGrotesk(_ size: CGFloat) -> Font {
        .custom("SpaceGrotesk-Regular", size: size)
    }
    
    static func spaceGroteskLight(_ size: CGFloat) -> Font {
        .custom("SpaceGrotesk-Light", size: size)
    }
    
    static func spaceGroteskMedium(_ size: CGFloat) -> Font {
        .custom("SpaceGrotesk-Medium", size: size)
    }
    
    static func spaceGroteskBold(_ size: CGFloat) -> Font {
        .custom("SpaceGrotesk-Bold", size: size)
    }
    
    // MARK: - Convenience Methods
    
    /// Large budget display font
    static var budgetDisplay: Font {
        .custom("SpaceGrotesk-Bold", size: 44)
    }
    
    /// Logo text
    static var logoText: Font {
        .custom("SpaceGrotesk-Bold", size: 24)
    }
    
    /// Section headers
    static var sectionHeader: Font {
        .custom("SpaceGrotesk-Bold", size: 17)
    }
    
    /// Body text
    static var bodyText: Font {
        .custom("SpaceGrotesk-Regular", size: 15)
    }
}

// MARK: - UIFont Extension for debugging
extension UIFont {
    static func printAllFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   - \(name)")
            }
        }
    }
}
