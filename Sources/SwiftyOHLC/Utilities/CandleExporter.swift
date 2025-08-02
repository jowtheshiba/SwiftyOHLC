import Foundation

/// Utilities for exporting candlestick data
public struct CandleExporter {
    
    /// Exports candles to CSV format
    /// - Parameters:
    ///   - candles: Array of candles
    ///   - includeHeaders: Whether to include headers
    /// - Returns: CSV string
    public static func toCSV(_ candles: [Candle], includeHeaders: Bool = true) -> String {
        var csv = ""
        
        if includeHeaders {
            csv += "Timestamp,Open,High,Low,Close,Volume\n"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for candle in candles {
            let timestamp = dateFormatter.string(from: candle.timestamp)
            let row = "\(timestamp),\(candle.open),\(candle.high),\(candle.low),\(candle.close),\(candle.volume)\n"
            csv += row
        }
        
        return csv
    }
    
    /// Exports candles to JSON format
    /// - Parameter candles: Array of candles
    /// - Returns: JSON string
    public static func toJSON(_ candles: [Candle]) -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(candles)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    /// Exports candles to TradingView format
    /// - Parameter candles: Array of candles
    /// - Returns: String in TradingView format
    public static func toTradingView(_ candles: [Candle]) -> String {
        var result = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for candle in candles {
            let timestamp = dateFormatter.string(from: candle.timestamp)
            let row = "\(timestamp),\(candle.open),\(candle.high),\(candle.low),\(candle.close),\(candle.volume)\n"
            result += row
        }
        
        return result
    }
    
    /// Exports candles to MetaTrader format
    /// - Parameter candles: Array of candles
    /// - Returns: String in MetaTrader format
    public static func toMetaTrader(_ candles: [Candle]) -> String {
        var result = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd,HH:mm"
        
        for candle in candles {
            let timestamp = dateFormatter.string(from: candle.timestamp)
            let row = "\(timestamp),\(candle.open),\(candle.high),\(candle.low),\(candle.close),\(candle.volume)\n"
            result += row
        }
        
        return result
    }
    
    /// Saves candles to file
    /// - Parameters:
    ///   - candles: Array of candles
    ///   - filePath: File path
    ///   - format: Export format
    /// - Returns: Success of operation
    public static func saveToFile(_ candles: [Candle], filePath: String, format: ExportFormat) -> Bool {
        let content: String
        
        switch format {
        case .csv:
            content = toCSV(candles)
        case .json:
            content = toJSON(candles) ?? ""
        case .tradingView:
            content = toTradingView(candles)
        case .metaTrader:
            content = toMetaTrader(candles)
        }
        
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    /// Export formats
    public enum ExportFormat {
        case csv
        case json
        case tradingView
        case metaTrader
    }
}

// MARK: - Convenience Extensions
extension Array where Element == Candle {
    
    /// Exports array of candles to CSV
    /// - Parameter includeHeaders: Whether to include headers
    /// - Returns: CSV string
    public func toCSV(includeHeaders: Bool = true) -> String {
        return CandleExporter.toCSV(self, includeHeaders: includeHeaders)
    }
    
    /// Exports array of candles to JSON
    /// - Returns: JSON string
    public func toJSON() -> String? {
        return CandleExporter.toJSON(self)
    }
    
    /// Exports array of candles to TradingView format
    /// - Returns: String in TradingView format
    public func toTradingView() -> String {
        return CandleExporter.toTradingView(self)
    }
    
    /// Exports array of candles to MetaTrader format
    /// - Returns: String in MetaTrader format
    public func toMetaTrader() -> String {
        return CandleExporter.toMetaTrader(self)
    }
    
    /// Saves array of candles to file
    /// - Parameters:
    ///   - filePath: File path
    ///   - format: Export format
    /// - Returns: Success of operation
    public func saveToFile(_ filePath: String, format: CandleExporter.ExportFormat) -> Bool {
        return CandleExporter.saveToFile(self, filePath: filePath, format: format)
    }
} 