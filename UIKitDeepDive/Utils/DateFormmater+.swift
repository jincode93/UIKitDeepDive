//
//  DateFormmater+.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

extension DateFormatter {
    static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .short
        return formatter
    }()
}

extension Date {
    var relativeString: String {
        DateFormatter.relativeFormatter.localizedString(for: self, relativeTo: Date())
    }
}
