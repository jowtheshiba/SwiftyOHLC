import Foundation

/// Represents a single candlestick with OHLC data
public struct Candle: Codable, Identifiable {
    public var id = UUID()
    public let timestamp: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Double
    
    public init(
        timestamp: Date,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double = 0.0
    ) {
        self.timestamp = timestamp
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
    
    /// Body size of the candle (close - open)
    public var bodySize: Double {
        return close - open
    }
    
    /// Upper shadow size (high - max(open, close))
    public var upperShadow: Double {
        return high - max(open, close)
    }
    
    /// Lower shadow size (min(open, close) - low)
    public var lowerShadow: Double {
        return min(open, close) - low
    }
    
    /// Total candle size (high - low)
    public var totalSize: Double {
        return high - low
    }
    
    /// Whether the candle is bullish (green)
    public var isBullish: Bool {
        return close > open
    }
    
    /// Whether the candle is bearish (red)
    public var isBearish: Bool {
        return close < open
    }
    
    /// Whether the candle is a doji (opening and closing prices are approximately equal)
    public var isDoji: Bool {
        return abs(close - open) < (totalSize * 0.1)
    }
}

// MARK: - Convenience Initializers
extension Candle {
    /// Creates a candle with identical open, high, low, close values
    public static func flat(price: Double, timestamp: Date, volume: Double = 0.0) -> Candle {
        return Candle(
            timestamp: timestamp,
            open: price,
            high: price,
            low: price,
            close: price,
            volume: volume
        )
    }
} 
