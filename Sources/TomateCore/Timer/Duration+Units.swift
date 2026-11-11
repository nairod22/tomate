extension Duration {
    /// Seconds as a floating-point value.
    public var timeInterval: Double {
        let (seconds, attoseconds) = components
        return Double(seconds) + Double(attoseconds) / 1e18
    }
}
