#!/usr/bin/env swift

import Foundation
import SwiftyOHLC

// MARK: - Command Line Interface

// Parse command line arguments
let arguments = CommandLine.arguments.dropFirst()

if arguments.isEmpty {
    printUsage()
    exit(1)
}

let command = arguments.first!

switch command {
case "generate":
    handleGenerateCommand(Array(arguments.dropFirst()))
case "analyze":
    handleAnalyzeCommand(Array(arguments.dropFirst()))
case "export":
    handleExportCommand(Array(arguments.dropFirst()))
case "help", "--help", "-h":
    printUsage()
case "version", "--version", "-v":
    printVersion()
default:
    print("❌ Unknown command: \(command)")
    printUsage()
    exit(1)
}

// MARK: - Command Handlers

func handleGenerateCommand(_ args: [String]) {
    guard !args.isEmpty else {
        print("❌ Please specify the number of candles to generate")
        print("Usage: clt-swiftyohlc generate <count> [mode]")
        exit(1)
    }
    
    guard let count = Int(args[0]) else {
        print("❌ Invalid count: \(args[0])")
        exit(1)
    }
    
    let mode: MarketMode = args.count > 1 ? parseMarketMode(args[1]) : .flat
    
    let config = GeneratorConfig(
        marketMode: mode,
        candleCount: count
    )
    
    let generator = SwiftyOHLC(config: config)
    let candles = generator.generate()
    
    print("✅ Generated \(candles.count) candles in \(mode.description) mode")
    
    // Display first few candles
    let displayCount = min(5, candles.count)
    print("\nFirst \(displayCount) candles:")
    for (index, candle) in candles.prefix(displayCount).enumerated() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: candle.timestamp)
        print("  \(index + 1). [\(timeString)] O: \(String(format: "%.2f", candle.open)), H: \(String(format: "%.2f", candle.high)), L: \(String(format: "%.2f", candle.low)), C: \(String(format: "%.2f", candle.close)), V: \(String(format: "%.0f", candle.volume))")
    }
}

func handleAnalyzeCommand(_ args: [String]) {
    guard !args.isEmpty else {
        print("❌ Please specify the number of candles to analyze")
        print("Usage: clt-swiftyohlc analyze <count> [mode]")
        exit(1)
    }
    
    guard let count = Int(args[0]) else {
        print("❌ Invalid count: \(args[0])")
        exit(1)
    }
    
    let mode: MarketMode = args.count > 1 ? parseMarketMode(args[1]) : .flat
    
    let config = GeneratorConfig(
        marketMode: mode,
        candleCount: count
    )
    
    let generator = SwiftyOHLC(config: config)
    let candles = generator.generate()
    
    let analysis = CandleAnalyzer.analyze(candles)
    
    print("📊 Analysis Results for \(mode.description) mode:")
    print("  Total candles: \(analysis.totalCandles)")
    print("  Average volume: \(String(format: "%.2f", analysis.averageVolume))")
    print("  Price range: \(String(format: "%.2f", analysis.priceRange.upperBound - analysis.priceRange.lowerBound))")
    print("  Bullish candles: \(analysis.bullishCandles)")
    print("  Bearish candles: \(analysis.bearishCandles)")
    print("  Doji candles: \(analysis.dojiCandles)")
    print("  Price change: \(String(format: "%.2f", analysis.priceChangePercent))%")
}

func handleExportCommand(_ args: [String]) {
    guard args.count >= 2 else {
        print("❌ Please specify count and filename")
        print("Usage: clt-swiftyohlc export <count> <filename> [mode] [symbol] [description]")
        exit(1)
    }
    
    guard let count = Int(args[0]) else {
        print("❌ Invalid count: \(args[0])")
        exit(1)
    }
    
    let filename = args[1]
    let mode: MarketMode = args.count > 2 ? parseMarketMode(args[2]) : .flat
    let symbol: String = args.count > 3 ? args[3] : "SYMBOL"
    let description: String = args.count > 4 ? args[4] : "Generated OHLC data"
    
    let config = GeneratorConfig(
        marketMode: mode,
        candleCount: count
    )
    
    let generator = SwiftyOHLC(config: config)
    let candles = generator.generate()
    
    do {
        let csvContent = generateCSVWithMetadata(candles: candles, symbol: symbol, description: description)
        try csvContent.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
        print("✅ Exported \(candles.count) candles to \(filename)")
        print("  Symbol: \(symbol)")
        print("  Description: \(description)")
    } catch {
        print("❌ Export failed: \(error)")
        exit(1)
    }
}

// MARK: - Helper Functions

func generateCSVWithMetadata(candles: [Candle], symbol: String, description: String) -> String {
    var csv = ""
    
    // Add metadata comments
    csv += "# Symbol: \(symbol)\n"
    csv += "# Description: \(description)\n"
    csv += "# Generated: \(Date())\n"
    csv += "# Mode: \(candles.first?.timestamp ?? Date())\n"
    csv += "#\n"
    
    // Add headers
    csv += "Timestamp,Open,High,Low,Close,Volume\n"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    for candle in candles {
        let timestamp = dateFormatter.string(from: candle.timestamp)
        let row = "\(timestamp),\(candle.open),\(candle.high),\(candle.low),\(candle.close),\(candle.volume)\n"
        csv += row
    }
    
    return csv
}

func parseMarketMode(_ modeString: String) -> MarketMode {
    switch modeString.lowercased() {
    case "flat":
        return .flat
    case "uptrend":
        return .uptrend
    case "downtrend":
        return .downtrend
    case "panic":
        return .panic
    case "newsspike", "news-spike":
        return .newsSpike
    case "consolidation":
        return .consolidation
    case "volatile":
        return .volatile
    default:
        print("⚠️  Unknown mode '\(modeString)', using flat mode")
        return .flat
    }
}

func printUsage() {
    print("""
    Usage: clt-swiftyohlc <command> [options]
    
    Commands:
      generate <count> [mode]           Generate specified number of candles
      analyze <count> [mode]            Analyze generated candles
      export <count> <file> [mode] [symbol] [description] Export candles to file
      help                              Show this help message
      version                           Show version information
    
    Available modes:
      flat (default)                    Flat - sideways movement
      uptrend                           Uptrend
      downtrend                         Downtrend
      panic                             Panic - sharp decline
      newsspike                         News spike
      consolidation                     Consolidation
      volatile                          Volatile market
    
    Examples:
      clt-swiftyohlc generate 100
      clt-swiftyohlc generate 50 uptrend
      clt-swiftyohlc analyze 200 panic
      clt-swiftyohlc export 500 candles.csv volatile
      clt-swiftyohlc export 100 btc.csv uptrend BTC "Bitcoin price data"
      clt-swiftyohlc export 200 aapl.csv flat AAPL "Apple stock data"
    """)
}

func printVersion() {
    print("clt-swiftyohlc v1.0.0")
}
