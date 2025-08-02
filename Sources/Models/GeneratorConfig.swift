import Foundation

/// Configuration for candlestick data generator
public struct GeneratorConfig: Sendable {
    /// Initial price
    public let initialPrice: Double
    
    /// Market mode
    public let marketMode: MarketMode
    
    /// Volatility (0.0 - 1.0)
    public let volatility: Double
    
    /// Trend strength (-1.0 to 1.0, where -1 = strong downtrend, 1 = strong uptrend)
    public let trendStrength: Double
    
    /// Interval between candles in seconds
    public let candleInterval: TimeInterval
    
    /// Number of candles to generate
    public let candleCount: Int
    
    /// Base volume value
    public let baseVolume: Double
    
    /// Volume multiplier for volatility
    public let volumeVolatilityMultiplier: Double
    
    /// Generation start time
    public let startTime: Date
    
    public init(
        initialPrice: Double = 100.0,
        marketMode: MarketMode = .flat,
        volatility: Double? = nil,
        trendStrength: Double? = nil,
        candleInterval: TimeInterval = 60.0, // 1 minute
        candleCount: Int = 100,
        baseVolume: Double = 1000.0,
        volumeVolatilityMultiplier: Double = 2.0,
        startTime: Date = Date()
    ) {
        self.initialPrice = initialPrice
        self.marketMode = marketMode
        self.volatility = volatility ?? marketMode.suggestedVolatility
        self.trendStrength = trendStrength ?? marketMode.suggestedTrend
        self.candleInterval = candleInterval
        self.candleCount = candleCount
        self.baseVolume = baseVolume
        self.volumeVolatilityMultiplier = volumeVolatilityMultiplier
        self.startTime = startTime
    }
    
    /// Creates configuration with recommended parameters for the mode
    public static func forMode(_ mode: MarketMode, initialPrice: Double = 100.0) -> GeneratorConfig {
        return GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: mode,
            volatility: mode.suggestedVolatility,
            trendStrength: mode.suggestedTrend
        )
    }
}

// MARK: - Preset Configurations
extension GeneratorConfig {
    /// Configuration for flat market
    public static let flat = GeneratorConfig.forMode(.flat)
    
    /// Configuration for uptrend
    public static let uptrend = GeneratorConfig.forMode(.uptrend)
    
    /// Configuration for downtrend
    public static let downtrend = GeneratorConfig.forMode(.downtrend)
    
    /// Configuration for panic
    public static let panic = GeneratorConfig.forMode(.panic)
    
    /// Configuration for news spike
    public static let newsSpike = GeneratorConfig.forMode(.newsSpike)
    
    /// Configuration for consolidation
    public static let consolidation = GeneratorConfig.forMode(.consolidation)
    
    /// Configuration for volatile market
    public static let volatile = GeneratorConfig.forMode(.volatile)
} 