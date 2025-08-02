import Foundation

// MARK: - Factory Methods
extension SwiftyOHLC {
    
    /// Creates a generator for flat market
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func flat(
        initialPrice: Double = 100.0,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .flat,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator for uptrend
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - trendStrength: Trend strength (0.1 - 1.0)
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func uptrend(
        initialPrice: Double = 100.0,
        trendStrength: Double = 0.8,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .uptrend,
            trendStrength: trendStrength,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator for downtrend
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - trendStrength: Trend strength (0.1 - 1.0)
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func downtrend(
        initialPrice: Double = 100.0,
        trendStrength: Double = 0.8,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .downtrend,
            trendStrength: -trendStrength,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator for panic
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - volatility: Volatility
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func panic(
        initialPrice: Double = 100.0,
        volatility: Double = 0.03,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .panic,
            volatility: volatility,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator for news spike
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - volatility: Volatility
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func newsSpike(
        initialPrice: Double = 100.0,
        volatility: Double = 0.02,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .newsSpike,
            volatility: volatility,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator for consolidation
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - volatility: Volatility
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func consolidation(
        initialPrice: Double = 100.0,
        volatility: Double = 0.002,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .consolidation,
            volatility: volatility,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator for volatile market
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - volatility: Volatility
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func volatile(
        initialPrice: Double = 100.0,
        volatility: Double = 0.015,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .volatile,
            volatility: volatility,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }
    
    /// Creates a generator with custom configuration
    /// - Parameter config: Generator configuration
    /// - Returns: Configured generator
    public static func custom(config: GeneratorConfig) -> SwiftyOHLC {
        return SwiftyOHLC(config: config)
    }
} 
