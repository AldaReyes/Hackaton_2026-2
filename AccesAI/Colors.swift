//
//  Colors.swift
//  AccesAI
//
//  Created by Fernando Aguilar on 24/03/26.
//

import Foundation
import SwiftUI

extension Color
{
    static let azulUnam = Color(red: 5/255, green: 21/255, blue: 41/255)
    static let customBlue = Color(UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0))
    static let doradoUnam = Color(red: 196/255, green: 146/255, blue: 41/255)
    
    init(hex: String, alpha: Double = 1.0) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hexString.count {
        case 6:
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        case 8:
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        default:
            r = 0; g = 0; b = 0
        }
        self.init(.sRGB, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: alpha)
    }
    
    static let verdePastel = Color(hex: "#BAD08C")
    static let azulPastel = Color(hex: "#93C2C2")
    static let blancoHueso = Color(hex: "#FBF9F3")
    static let verdeFuerte = Color(hex: "#7BA655")
    static let azulFuerte = Color(hex: "#5480BA")
}
