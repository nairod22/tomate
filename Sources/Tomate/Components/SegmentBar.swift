import SwiftUI

/// Horizontal bar of proportional segments with a 2 pt gap.
struct SegmentBar: View {
    let segments: [Segment]
    var height: CGFloat = 6
    var track: Color = .clear

    var body: some View {
        GeometryReader { geo in
            let total = max(0.0001, segments.map(\.weight).reduce(0, +))
            let avail = max(0, geo.size.width - CGFloat(max(0, segments.count - 1)) * 2)
            HStack(spacing: 2) {
                ForEach(segments) { s in
                    let w = avail * s.weight / total
                    ZStack(alignment: .leading) {
                        Capsule().fill(track)
                        Capsule().fill(s.color).frame(width: w * min(1, max(0, s.fill)))
                    }
                    .frame(width: w)
                }
            }
        }
        .frame(height: height)
    }
}
