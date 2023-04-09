import Foundation
import SwiftUI

enum Tab: Int, Identifiable, CaseIterable, Comparable {
    internal var id: Int { rawValue }
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case home, second
    
    var icon: String {
        switch self {
        case .home:
            return "pills"
        case .second:
            return "syringe"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .second:
            return "Games"
        }
    }
    
    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .second:
            return .orange
        }
    }
}
