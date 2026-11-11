import XCTest
@testable import Tomate
import TomateCore

/// Cost of one menu bar render. The app now renders about twice a minute while
/// running; before, it rendered every second, so this number times 60 was the
/// per-minute cost.
@MainActor
final class StatusIconRenderTests: XCTestCase {
    private let face = MenuBarFace(mode: .running, progressStep: 16, minutesLeft: 25)

    func testRenderTime() {
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()], options: options) {
            for _ in 0..<100 {
                _ = StatusIcon(face: face, dark: false).render(scale: 2)
            }
        }
    }

    func testRenderProducesRetinaImage() throws {
        let image = try XCTUnwrap(StatusIcon(face: face, dark: true).render(scale: 2))
        let rep = try XCTUnwrap(image.representations.first)
        XCTAssertEqual(rep.pixelsHigh, 44)
        XCTAssertGreaterThan(rep.pixelsWide, 80)  // tomato + "25 min"
    }

    /// 1,000 renders must not grow the process memory meaningfully.
    func testRendersDoNotLeak() {
        func residentBytes() -> UInt64 {
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            return result == KERN_SUCCESS ? info.resident_size : 0
        }
        // Warm up caches first, then compare.
        for _ in 0..<100 { autoreleasepool { _ = StatusIcon(face: face, dark: false).render(scale: 2) } }
        let before = residentBytes()
        for i in 0..<1000 {
            autoreleasepool {
                let f = MenuBarFace(mode: .running, progressStep: i % 40, minutesLeft: i % 90 + 1)
                _ = StatusIcon(face: f, dark: i.isMultiple(of: 2)).render(scale: 2)
            }
        }
        let growth = Double(residentBytes()) - Double(before)
        XCTAssertLessThan(growth, 8 * 1024 * 1024, "resident memory grew by \(Int(growth / 1024)) KB")
    }
}
