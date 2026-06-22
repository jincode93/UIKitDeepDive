//
//  UIColor+.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import UIKit

extension UIColor {
    static func randomPastel() -> UIColor {
        UIColor(
            hue: CGFloat.random(in: 0...1),
            saturation: 0.3,
            brightness: 0.9,
            alpha: 1.0
        )
    }
}
