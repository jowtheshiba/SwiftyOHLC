import Foundation

/// Utilities for analyzing candlestick data
public struct CandleAnalyzer {
    
    /// Statistics for an array of candles
    public struct Statistics {
        public let totalCandles: Int
        public let averagePrice: Double
        public let priceRange: ClosedRange<Double>
        public let totalVolume: Double
        public let averageVolume: Double
        public let bullishCandles: Int
        public let bearishCandles: Int
        public let dojiCandles: Int
        public let averageBodySize: Double
        public let averageShadowSize: Double
        public let priceChange: Double
        public let priceChangePercent: Double
        
        public init(candles: [Candle]) {
            self.totalCandles = candles.count
            self.averagePrice = candles.map { ($0.high + $0.low) / 2 }.reduce(0, +) / Double(candles.count)
            self.priceRange = (candles.map { $0.low }.min() ?? 0)...(candles.map { $0.high }.max() ?? 0)
            self.totalVolume = candles.map { $0.volume }.reduce(0, +)
            self.averageVolume = self.totalVolume / Double(candles.count)
            self.bullishCandles = candles.filter { $0.isBullish }.count
            self.bearishCandles = candles.filter { $0.isBearish }.count
            self.dojiCandles = candles.filter { $0.isDoji }.count
            self.averageBodySize = candles.map { abs($0.bodySize) }.reduce(0, +) / Double(candles.count)
            self.averageShadowSize = candles.map { $0.upperShadow + $0.lowerShadow }.reduce(0, +) / Double(candles.count)
            
            if let firstCandle = candles.first, let lastCandle = candles.last {
                self.priceChange = lastCandle.close - firstCandle.open
                self.priceChangePercent = (self.priceChange / firstCandle.open) * 100
            } else {
                self.priceChange = 0
                self.priceChangePercent = 0
            }
        }
    }
    
    /// Analyzes an array of candles and returns statistics
    /// - Parameter candles: Array of candles to analyze
    /// - Returns: Statistics for candles
    public static func analyze(_ candles: [Candle]) -> Statistics {
        return Statistics(candles: candles)
    }
    
    /// Finds candles with highest volume
    /// - Parameters:
    ///   - candles: Array of candles
    ///   - count: Number of candles to return
    /// - Returns: Array of candles with highest volume
    public static func highestVolumeCandles(_ candles: [Candle], count: Int = 10) -> [Candle] {
        return candles.sorted { $0.volume > $1.volume }.prefix(count).map { $0 }
    }
    
    /// Finds candles with largest body size
    /// - Parameters:
    ///   - candles: Array of candles
    ///   - count: Number of candles to return
    /// - Returns: Array of candles with largest body size
    public static func largestBodyCandles(_ candles: [Candle], count: Int = 10) -> [Candle] {
        return candles.sorted { abs($0.bodySize) > abs($1.bodySize) }.prefix(count).map { $0 }
    }
    
    /// Finds candles with largest shadows
    /// - Parameters:
    ///   - candles: Array of candles
    ///   - count: Number of candles to return
    /// - Returns: Array of candles with largest shadows
    public static func largestShadowCandles(_ candles: [Candle], count: Int = 10) -> [Candle] {
        return candles.sorted { ($0.upperShadow + $0.lowerShadow) > ($1.upperShadow + $1.lowerShadow) }.prefix(count).map { $0 }
    }
    
    /// Determines overall trend from candles
    /// - Parameter candles: Array of candles
    /// - Returns: Trend description
    public static func determineTrend(_ candles: [Candle]) -> String {
        guard let firstCandle = candles.first, let lastCandle = candles.last else {
            return "Insufficient data"
        }
        
        let change = lastCandle.close - firstCandle.open
        let changePercent = (change / firstCandle.open) * 100
        
        if changePercent > 5 {
            return "Strong uptrend (+\(String(format: "%.2f", changePercent))%)"
        } else if changePercent > 1 {
            return "Uptrend (+\(String(format: "%.2f", changePercent))%)"
        } else if changePercent < -5 {
            return "Strong downtrend (\(String(format: "%.2f", changePercent))%)"
        } else if changePercent < -1 {
            return "Downtrend (\(String(format: "%.2f", changePercent))%)"
        } else {
            return "Sideways movement (\(String(format: "%.2f", changePercent))%)"
        }
    }
    
    /// Calculates average volatility
    /// - Parameter candles: Array of candles
    /// - Returns: Average volatility in percentage
    public static func averageVolatility(_ candles: [Candle]) -> Double {
        let volatilities = candles.map { (($0.high - $0.low) / $0.open) * 100 }
        return volatilities.reduce(0, +) / Double(volatilities.count)
    }
    
    /// Finds extremes (highs and lows)
    /// - Parameter candles: Array of candles
    /// - Returns: Tuple with highs and lows
    public static func findExtremes(_ candles: [Candle]) -> (highs: [Candle], lows: [Candle]) {
        var highs: [Candle] = []
        var lows: [Candle] = []
        
        for i in 1..<candles.count-1 {
            let current = candles[i]
            let previous = candles[i-1]
            let next = candles[i+1]
            
            // Local maximum
            if current.high > previous.high && current.high > next.high {
                highs.append(current)
            }
            
            // Local minimum
            if current.low < previous.low && current.low < next.low {
                lows.append(current)
            }
        }
        
        return (highs, lows)
    }
} 