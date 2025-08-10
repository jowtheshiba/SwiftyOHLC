import Foundation

/// Main generator of synthetic candlestick data
public class SwiftyOHLC {
    private let config: GeneratorConfig
    private var currentPrice: Double
    private var currentTime: Date
    
    // State for models that require memory
    private var garchVariance: Double?
    
    public init(config: GeneratorConfig) {
        self.config = config
        self.currentPrice = config.initialPrice
        self.currentTime = config.startTime
        self.garchVariance = config.volatility * config.volatility
    }
    
    /// Generates an array of candles according to configuration
    /// - Returns: Array of candles
    public func generate() -> [Candle] {
        var candles: [Candle] = []
        
        for i in 0..<config.candleCount {
            let candle = generateNextCandle(index: i)
            candles.append(candle)
            
            // Update current price and time for the next candle
            currentPrice = candle.close
            currentTime = candle.timestamp.addingTimeInterval(config.candleInterval)
        }
        
        return candles
    }
    
    /// Generates the next candle
    /// - Parameter index: Candle index
    /// - Returns: Generated candle
    private func generateNextCandle(index: Int) -> Candle {
        let timestamp = currentTime.addingTimeInterval(TimeInterval(index) * config.candleInterval)
        
        // Generate opening price
        let open = generateOpenPrice()
        
        // Generate high, low, close prices depending on mode
        let (high, low, close) = generateOHLC(open: open, index: index)
        
        // Generate volume
        let volume = generateVolume(priceVolatility: abs(close - open) / open)
        
        return Candle(
            timestamp: timestamp,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
    
    /// Generates opening price
    /// - Returns: Opening price
    private func generateOpenPrice() -> Double {
        switch config.marketMode {
        case .flat:
            return generateFlatOpenPrice()
        case .uptrend, .downtrend:
            return generateTrendOpenPrice()
        case .panic:
            return generatePanicOpenPrice()
        case .newsSpike:
            return generateNewsSpikeOpenPrice()
        case .consolidation:
            return generateConsolidationOpenPrice()
        case .volatile:
            return generateVolatileOpenPrice()
        case .gbm:
            return generateGBMOpenPrice()
        case .jumpDiffusion:
            return generateJumpDiffusionOpenPrice()
        case .garch:
            return generateGARCHOpenPrice()
        case .ou:
            return generateOUOpenPrice()
        }
    }
    
    /// Generates OHLC prices
    /// - Parameters:
    ///   - open: Opening price
    ///   - index: Candle index
    /// - Returns: Tuple (high, low, close)
    private func generateOHLC(open: Double, index: Int) -> (high: Double, low: Double, close: Double) {
        switch config.marketMode {
        case .flat:
            return generateFlatOHLC(open: open)
        case .uptrend, .downtrend:
            return generateTrendOHLC(open: open)
        case .panic:
            return generatePanicOHLC(open: open)
        case .newsSpike:
            return generateNewsSpikeOHLC(open: open, index: index)
        case .consolidation:
            return generateConsolidationOHLC(open: open)
        case .volatile:
            return generateVolatileOHLC(open: open)
        case .gbm:
            return generateGBMOHLC(open: open)
        case .jumpDiffusion:
            return generateJumpDiffusionOHLC(open: open)
        case .garch:
            return generateGARCHOHLC(open: open)
        case .ou:
            return generateOUOHLC(open: open)
        }
    }
    
    // MARK: - Flat Mode
    private func generateFlatOpenPrice() -> Double {
        let change = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.5)
        return currentPrice * (1 + change)
    }
    
    private func generateFlatOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let bodySize = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.3)
        let close = open * (1 + bodySize)
        
        let shadowSize = abs(RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.2))
        let high = max(open, close) * (1 + shadowSize)
        let low = min(open, close) * (1 - shadowSize)
        
        return (high, low, close)
    }
    
    // MARK: - Trend Mode
    private func generateTrendOpenPrice() -> Double {
        let trendComponent = config.trendStrength * config.volatility * 0.5
        let randomComponent = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.3)
        return currentPrice * (1 + trendComponent + randomComponent)
    }
    
    private func generateTrendOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let trendDirection = config.trendStrength > 0 ? 1.0 : -1.0
        let bodySize = RandomGenerator.normal(mean: trendDirection * config.volatility * 0.5, standardDeviation: config.volatility * 0.3)
        let close = open * (1 + bodySize)
        
        let shadowSize = abs(RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.2))
        let high = max(open, close) * (1 + shadowSize)
        let low = min(open, close) * (1 - shadowSize)
        
        return (high, low, close)
    }
    
    // MARK: - Panic Mode
    private func generatePanicOpenPrice() -> Double {
        let panicComponent = -abs(RandomGenerator.exponential(lambda: 2.0)) * config.volatility
        let randomComponent = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.5)
        return currentPrice * (1 + panicComponent + randomComponent)
    }
    
    private func generatePanicOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let panicBody = -abs(RandomGenerator.exponential(lambda: 1.5)) * config.volatility
        let close = open * (1 + panicBody)
        
        let upperShadow = abs(RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.3))
        let lowerShadow = abs(RandomGenerator.exponential(lambda: 2.0)) * config.volatility
        
        let high = open * (1 + upperShadow)
        let low = min(open, close) * (1 - lowerShadow)
        
        return (high, low, close)
    }
    
    // MARK: - News Spike Mode
    private func generateNewsSpikeOpenPrice() -> Double {
        let spikeProbability = 0.1 // 10% probability of spike
        let isSpike = Double.random(in: 0...1) < spikeProbability
        
        if isSpike {
            let spikeSize = RandomGenerator.exponential(lambda: 1.0) * config.volatility * 3
            return currentPrice * (1 + spikeSize)
        } else {
            let change = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.3)
            return currentPrice * (1 + change)
        }
    }
    
    private func generateNewsSpikeOHLC(open: Double, index: Int) -> (high: Double, low: Double, close: Double) {
        // If this is a spike, create a sharp rise followed by retracement
        let isSpike = open > currentPrice * 1.02
        
        if isSpike {
            let spikeHigh = open * (1 + RandomGenerator.exponential(lambda: 1.0) * config.volatility)
            let retracement = RandomGenerator.normal(mean: -0.3, standardDeviation: 0.2)
            let close = open * (1 + retracement)
            let low = min(open, close) * (1 - abs(RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.2)))
            
            return (spikeHigh, low, close)
        } else {
            return generateFlatOHLC(open: open)
        }
    }
    
    // MARK: - Consolidation Mode
    private func generateConsolidationOpenPrice() -> Double {
        let range = config.volatility * 0.5
        let center = config.initialPrice
        return RandomGenerator.normalInRange(min: center * (1 - range), max: center * (1 + range), center: center, concentration: 0.8)
    }
    
    private func generateConsolidationOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let smallBody = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.1)
        let close = open * (1 + smallBody)
        
        let smallShadow = abs(RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.1))
        let high = max(open, close) * (1 + smallShadow)
        let low = min(open, close) * (1 - smallShadow)
        
        return (high, low, close)
    }
    
    // MARK: - Volatile Mode
    private func generateVolatileOpenPrice() -> Double {
        let direction = RandomGenerator.direction(probability: 0.5)
        let volatility = config.volatility * (1 + abs(RandomGenerator.normal(mean: 0, standardDeviation: 0.5)))
        let change = direction * RandomGenerator.exponential(lambda: 1.0) * volatility
        return currentPrice * (1 + change)
    }
    
    private func generateVolatileOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let bodySize = RandomGenerator.normal(mean: 0, standardDeviation: config.volatility * 0.8)
        let close = open * (1 + bodySize)
        
        let shadowSize = abs(RandomGenerator.exponential(lambda: 1.0)) * config.volatility
        let high = max(open, close) * (1 + shadowSize)
        let low = min(open, close) * (1 - shadowSize)
        
        return (high, low, close)
    }
    
    // MARK: - GBM Mode (Geometric Brownian Motion)
    // S_{t+dt} = S_t * exp((mu - 0.5*sigma^2)*dt + sigma*sqrt(dt)*Z)
    // We simulate intra-candle micro steps to derive realistic High/Low
    private func generateGBMOpenPrice() -> Double {
        // Drift is derived from trendStrength; volatility uses config.volatility
        let mu = config.trendStrength * config.volatility
        let sigma = max(1e-6, config.volatility)
        let dt = max(1.0 / 390.0, config.candleInterval / 86400.0) // normalize to trading day fractions
        let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
        let multiplier = exp((mu - 0.5 * sigma * sigma) * dt + sigma * sqrt(dt) * z)
        return max(0.0001, currentPrice * multiplier)
    }
    
    private func generateGBMOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        // Number of micro-steps within one candle
        let steps = max(4, Int(max(1, round(config.candleInterval / 15.0)))) // at least 4, ~15s step
        let mu = config.trendStrength * config.volatility
        let sigma = max(1e-6, config.volatility)
        let dt = max(1e-4, (config.candleInterval / Double(steps)) / 86400.0)
        
        var price = open
        var highPrice = open
        var lowPrice = open
        
        for _ in 0..<steps {
            let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
            price = price * exp((mu - 0.5 * sigma * sigma) * dt + sigma * sqrt(dt) * z)
            if price > highPrice { highPrice = price }
            if price < lowPrice { lowPrice = price }
        }
        let close = price
        
        // Guard against degenerate values
        let high = max(open, max(highPrice, close))
        let low = min(open, min(lowPrice, close))
        
        return (high, low, close)
    }
    
    // MARK: - Jump-Diffusion (Merton)
    private func generateJumpDiffusionOpenPrice() -> Double {
        let mu = config.trendStrength * config.volatility
        let sigma = max(1e-6, config.volatility)
        let dt = max(1.0 / 390.0, config.candleInterval / 86400.0)
        let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
        var multiplier = exp((mu - 0.5 * sigma * sigma) * dt + sigma * sqrt(dt) * z)
        // Jumps at open with small probability
        let lambdaPerDay = 0.3
        let pJump = min(0.5, lambdaPerDay * dt)
        if Double.random(in: 0...1) < pJump {
            let jumpMu = -0.02
            let jumpSigma = 0.08
            let jz = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
            let jumpFactor = exp(jumpMu + jumpSigma * jz)
            multiplier *= jumpFactor
        }
        return max(0.0001, currentPrice * multiplier)
    }
    
    private func generateJumpDiffusionOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let steps = max(4, Int(max(1, round(config.candleInterval / 15.0))))
        let mu = config.trendStrength * config.volatility
        let sigma = max(1e-6, config.volatility)
        let lambdaPerDay = 0.3
        let dt = max(1e-4, (config.candleInterval / Double(steps)) / 86400.0)
        let pJump = min(0.5, lambdaPerDay * dt)
        
        var price = open
        var highPrice = open
        var lowPrice = open
        
        for _ in 0..<steps {
            let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
            price = price * exp((mu - 0.5 * sigma * sigma) * dt + sigma * sqrt(dt) * z)
            if Double.random(in: 0...1) < pJump {
                let jumpMu = -0.02
                let jumpSigma = 0.08
                let jz = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
                let jumpFactor = exp(jumpMu + jumpSigma * jz)
                price *= jumpFactor
            }
            if price > highPrice { highPrice = price }
            if price < lowPrice { lowPrice = price }
        }
        let close = price
        let high = max(open, max(highPrice, close))
        let low = min(open, min(lowPrice, close))
        return (high, low, close)
    }
    
    // MARK: - GARCH(1,1)
    private func generateGARCHOpenPrice() -> Double {
        // Initialize variance if needed
        if garchVariance == nil { garchVariance = config.volatility * config.volatility }
        let dt = max(1.0 / 390.0, config.candleInterval / 86400.0)
        let sigma = sqrt(max(1e-10, garchVariance ?? (config.volatility * config.volatility)))
        let mu = config.trendStrength * config.volatility
        let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
        let multiplier = exp((mu - 0.5 * sigma * sigma) * dt + sigma * sqrt(dt) * z)
        return max(0.0001, currentPrice * multiplier)
    }
    
    private func generateGARCHOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        // Parameters chosen to keep alpha+beta < 1
        let alpha = 0.10
        let beta = 0.85
        let targetVar = max(1e-8, config.volatility * config.volatility)
        let omega = targetVar * (1 - alpha - beta)
        if garchVariance == nil { garchVariance = targetVar }
        
        let steps = max(4, Int(max(1, round(config.candleInterval / 15.0))))
        let dt = max(1e-4, (config.candleInterval / Double(steps)) / 86400.0)
        let mu = config.trendStrength * config.volatility
        
        var variance = max(1e-10, garchVariance ?? targetVar)
        var price = open
        var highPrice = open
        var lowPrice = open
        var prevReturn: Double = 0.0
        
        for _ in 0..<steps {
            let sigma = sqrt(max(1e-12, variance))
            let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
            let logReturn = (mu - 0.5 * sigma * sigma) * dt + sigma * sqrt(dt) * z
            price = price * exp(logReturn)
            prevReturn = logReturn
            // Update variance per GARCH(1,1)
            variance = omega + alpha * (prevReturn * prevReturn) + beta * variance
            if price > highPrice { highPrice = price }
            if price < lowPrice { lowPrice = price }
        }
        garchVariance = variance // persist state
        let close = price
        let high = max(open, max(highPrice, close))
        let low = min(open, min(lowPrice, close))
        return (high, low, close)
    }
    
    // MARK: - Ornstein-Uhlenbeck on log-price
    private func generateOUOpenPrice() -> Double {
        let thetaLog = log(max(1e-6, config.initialPrice))
        let kappa = 0.3 // mean reversion speed per day
        let sigma = max(1e-6, config.volatility)
        let dt = max(1.0 / 390.0, config.candleInterval / 86400.0)
        let xPrev = log(max(1e-6, currentPrice))
        let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
        let xNext = xPrev + kappa * (thetaLog - xPrev) * dt + sigma * sqrt(dt) * z
        return max(0.0001, exp(xNext))
    }
    
    private func generateOUOHLC(open: Double) -> (high: Double, low: Double, close: Double) {
        let steps = max(4, Int(max(1, round(config.candleInterval / 15.0))))
        let thetaLog = log(max(1e-6, config.initialPrice))
        let kappa = 0.3
        let sigma = max(1e-6, config.volatility)
        let dt = max(1e-4, (config.candleInterval / Double(steps)) / 86400.0)
        
        var x = log(max(1e-6, open))
        var highPrice = open
        var lowPrice = open
        
        for _ in 0..<steps {
            let z = RandomGenerator.normal(mean: 0, standardDeviation: 1.0)
            x = x + kappa * (thetaLog - x) * dt + sigma * sqrt(dt) * z
            let p = exp(x)
            if p > highPrice { highPrice = p }
            if p < lowPrice { lowPrice = p }
        }
        let close = exp(x)
        let high = max(open, max(highPrice, close))
        let low = min(open, min(lowPrice, close))
        return (high, low, close)
    }
    
    // MARK: - Volume Generation
    private func generateVolume(priceVolatility: Double) -> Double {
        return RandomGenerator.volume(
            baseVolume: config.baseVolume,
            priceVolatility: priceVolatility,
            multiplier: config.volumeVolatilityMultiplier
        )
    }
} 
