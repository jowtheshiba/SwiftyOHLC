import Foundation

/// Market behavior modes for generating synthetic data
public enum MarketMode: CaseIterable, Sendable {
    /// Flat - sideways movement with small fluctuations
    case flat
    
    /// Uptrend - steady price increase
    case uptrend
    
    /// Downtrend - steady price decrease
    case downtrend
    
    /// Panic - sharp downward movements with high volatility
    case panic
    
    /// News spike - sharp increase followed by retracement
    case newsSpike
    
    /// Consolidation - narrow range with small movements
    case consolidation
    
    /// Volatile market - random sharp movements
    case volatile
    
    /// Geometric Brownian Motion - stochastic process with drift and volatility
    case gbm
    
    /// Mode description for user
    public var description: String {
        switch self {
        case .flat:
            return "Flat - sideways movement"
        case .uptrend:
            return "Uptrend"
        case .downtrend:
            return "Downtrend"
        case .panic:
            return "Panic - sharp decline"
        case .newsSpike:
            return "News spike"
        case .consolidation:
            return "Consolidation"
        case .volatile:
            return "Volatile market"
        case .gbm:
            return "Geometric Brownian Motion"
        }
    }
    
    /// Recommended volatility parameters for the mode
    public var suggestedVolatility: Double {
        switch self {
        case .flat:
            return 0.001 // 0.1%
        case .uptrend, .downtrend:
            return 0.005 // 0.5%
        case .panic:
            return 0.03 // 3%
        case .newsSpike:
            return 0.02 // 2%
        case .consolidation:
            return 0.002 // 0.2%
        case .volatile:
            return 0.015 // 1.5%
        case .gbm:
            return 0.01 // 1%
        }
    }
    
    /// Recommended trend for the mode (from -1 to 1)
    public var suggestedTrend: Double {
        switch self {
        case .flat, .consolidation, .volatile:
            return 0.0
        case .uptrend:
            return 0.8
        case .downtrend:
            return -0.8
        case .panic:
            return -0.9
        case .newsSpike:
            return 0.6
        case .gbm:
            return 0.1
        }
    }
} 