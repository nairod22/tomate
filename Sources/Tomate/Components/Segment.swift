import SwiftUI

struct Segment: Identifiable {
    let id: Int
    let weight: Double
    let color: Color
    /// 0...1 filled part.
    var fill: Double = 1
}
