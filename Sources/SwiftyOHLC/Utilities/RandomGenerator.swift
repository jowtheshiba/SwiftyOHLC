import Foundation

/// Utilities for generating random numbers with various distributions
public struct RandomGenerator {
    
    /// Generates a random number with normal distribution
    /// - Parameters:
    ///   - mean: Mean value
    ///   - standardDeviation: Standard deviation
    /// - Returns: Random number with normal distribution
    public static func normal(mean: Double = 0.0, standardDeviation: Double = 1.0) -> Double {
        // Box-Muller transform for generating normal distribution
        let u1 = Double.random(in: 0...1)
        let u2 = Double.random(in: 0...1)
        
        let z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * .pi * u2)
        return mean + z0 * standardDeviation
    }
    
    /// Generates a random number with exponential distribution
    /// - Parameter lambda: Parameter of exponential distribution
    /// - Returns: Random number with exponential distribution
    public static func exponential(lambda: Double = 1.0) -> Double {
        let u = Double.random(in: 0...1)
        return -log(1 - u) / lambda
    }
    
    /// Generates a random number with lognormal distribution
    /// - Parameters:
    ///   - mean: Mean value of logarithm
    ///   - standardDeviation: Standard deviation of logarithm
    /// - Returns: Random number with lognormal distribution
    public static func logNormal(mean: Double = 0.0, standardDeviation: Double = 1.0) -> Double {
        let normalValue = normal(mean: mean, standardDeviation: standardDeviation)
        return exp(normalValue)
    }
    
    /// Generates a random direction (-1 or 1)
    /// - Parameter probability: Probability of direction 1 (default 0.5)
    /// - Returns: -1 or 1
    public static func direction(probability: Double = 0.5) -> Double {
        return Double.random(in: 0...1) < probability ? 1.0 : -1.0
    }
    
    /// Generates a random number in range with normal distribution
    /// - Parameters:
    ///   - min: Minimum value
    ///   - max: Maximum value
    ///   - center: Center of distribution (default middle of range)
    ///   - concentration: Concentration around center (0.1 - 1.0)
    /// - Returns: Random number in range
    public static func normalInRange(min: Double, max: Double, center: Double? = nil, concentration: Double = 0.5) -> Double {
        let centerValue = center ?? (min + max) / 2
        let range = max - min
        let standardDeviation = range * concentration / 3
        
        var result: Double
        repeat {
            result = normal(mean: centerValue, standardDeviation: standardDeviation)
        } while result < min || result > max
        
        return result
    }
    
    /// Generates a random number with distribution that considers trend
    /// - Parameters:
    ///   - baseValue: Base value
    ///   - volatility: Volatility
    ///   - trendStrength: Trend strength (-1 to 1)
    /// - Returns: Random number considering trend
    public static func withTrend(baseValue: Double, volatility: Double, trendStrength: Double) -> Double {
        let randomComponent = normal(mean: 0, standardDeviation: volatility)
        let trendComponent = trendStrength * volatility * 2
        return baseValue * (1 + randomComponent + trendComponent)
    }
    
    /// Generates random volume considering price volatility
    /// - Parameters:
    ///   - baseVolume: Base volume
    ///   - priceVolatility: Price volatility
    ///   - multiplier: Multiplier for linking volume to volatility
    /// - Returns: Random volume
    public static func volume(baseVolume: Double, priceVolatility: Double, multiplier: Double = 2.0) -> Double {
        let volatilityMultiplier = 1.0 + (priceVolatility * multiplier)
        let randomMultiplier = normal(mean: 1.0, standardDeviation: 0.3)
        return baseVolume * volatilityMultiplier * max(0.1, randomMultiplier)
    }
} 