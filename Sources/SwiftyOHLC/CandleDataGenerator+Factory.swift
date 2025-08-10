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
    
    /// Creates a generator for Geometric Brownian Motion (GBM)
    /// - Parameters:
    ///   - initialPrice: Initial price
    ///   - drift: Drift coefficient (approx trend). If nil, uses mode suggested
    ///   - volatility: Volatility (sigma)
    ///   - candleCount: Number of candles
    ///   - candleInterval: Interval between candles
    /// - Returns: Configured generator
    public static func gbm(
        initialPrice: Double = 100.0,
        drift: Double? = nil,
        volatility: Double = 0.01,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .gbm,
            volatility: volatility,
            trendStrength: drift,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }

    /// Creates a generator for Jump-Diffusion (Merton)
    public static func jumpDiffusion(
        initialPrice: Double = 100.0,
        drift: Double? = nil,
        volatility: Double = 0.012,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .jumpDiffusion,
            volatility: volatility,
            trendStrength: drift,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }

    /// Creates a generator for GARCH(1,1)
    public static func garch(
        initialPrice: Double = 100.0,
        drift: Double? = nil,
        volatility: Double = 0.008,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .garch,
            volatility: volatility,
            trendStrength: drift,
            candleInterval: candleInterval,
            candleCount: candleCount
        )
        return SwiftyOHLC(config: config)
    }

    /// Creates a generator for Ornstein-Uhlenbeck mean-reverting process (on log-price)
    public static func ou(
        initialPrice: Double = 100.0,
        meanReversionSpeed: Double? = nil, // reserved for future extension via config
        volatility: Double = 0.006,
        candleCount: Int = 100,
        candleInterval: TimeInterval = 60.0
    ) -> SwiftyOHLC {
        let config = GeneratorConfig(
            initialPrice: initialPrice,
            marketMode: .ou,
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
