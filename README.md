# SwiftyOHLC

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/SwiftyOHLC)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-supported-brightgreen.svg)](https://developer.apple.com/macos/)
[![Linux](https://img.shields.io/badge/Linux-supported-brightgreen.svg)](https://www.linux.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A Swift library for generating synthetic OHLC (Open-High-Low-Close) candlestick data with multiple market simulation modes and comprehensive analysis tools.

## Description

It provides tools to generate realistic synthetic candlestick data that mimics various market conditions, from stable sideways movements to volatile panic scenarios. The library includes analysis capabilities and visualization tools for technical analysis research and development.

## What is OHLC?

OHLC (Open-High-Low-Close) charts are a fundamental tool in technical analysis for financial markets. Each candlestick represents the price movement of a financial instrument over a specific time period, showing:

- **Open**: The opening price for the period
- **High**: The highest price reached during the period
- **Low**: The lowest price reached during the period
- **Close**: The closing price for the period

OHLC charts are essential for technical analysis as they provide a visual representation of price action, market sentiment, and potential trading opportunities. They are widely used by traders and analysts to identify patterns, trends, and support/resistance levels.

For more information, see the [Wikipedia article on OHLC charts](https://en.wikipedia.org/wiki/Open-high-low-close_chart).

<img width="1723" height="1049" alt="Screenshot 2025-08-02 at 09 45 17" src="https://github.com/user-attachments/assets/099cfac2-6db9-40fb-9e6f-869b9975b94b" />

## Library Features

### Core Library (`SwiftyOHLC`)

The main library provides:

- **Synthetic Data Generation**: Generate realistic candlestick data with configurable parameters
- **Multiple Market Modes**: Simulate different market conditions:
  - `flat`: Sideways movement with minimal volatility
  - `uptrend`: Bullish market with upward price movement
  - `downtrend`: Bearish market with downward price movement
  - `panic`: Sharp decline with high volatility
  - `newsSpike`: Sudden price movements simulating news events
  - `consolidation`: Range-bound trading with moderate volatility
  - `volatile`: High-frequency price fluctuations

- **Technical Analysis Tools**:
  - Candle pattern recognition (bullish, bearish, doji)
  - Volume analysis
  - Price range calculations
  - Statistical analysis of market data

- **Data Export**: Export generated data to CSV format with metadata

### Key Components

- **`Candle`**: Core data structure representing a single candlestick
- **`GeneratorConfig`**: Configuration for data generation parameters
- **`MarketMode`**: Enumeration of different market simulation modes
- **`SwiftyOHLC`**: Main generator class for synthetic data
- **`CandleAnalyzer`**: Analysis utilities for candlestick data
- **`CandleExporter`**: Export functionality for generated data

## Command Line Tools

### clt-swiftyohlc

A comprehensive command-line tool for generating, analyzing, and exporting OHLC data.

#### Commands:

- **`generate <count> [mode]`**: Generate specified number of candles
  ```bash
  clt-swiftyohlc generate 100
  clt-swiftyohlc generate 50 uptrend
  ```

- **`analyze <count> [mode]`**: Analyze generated candles with statistical metrics
  ```bash
  clt-swiftyohlc analyze 200 panic
  ```

- **`export <count> <file> [mode] [symbol] [description]`**: Export candles to CSV file
  ```bash
  clt-swiftyohlc export 500 candles.csv volatile
  clt-swiftyohlc export 100 btc.csv uptrend BTC "Bitcoin price data"
  ```

#### Available Market Modes:
- `flat` (default): Sideways movement
- `uptrend`: Bullish market
- `downtrend`: Bearish market
- `panic`: Sharp decline
- `newsspike`: News-driven spikes
- `consolidation`: Range-bound trading
- `volatile`: High volatility

### clt-ohlcplot

A visualization tool that converts CSV data into interactive HTML charts with advanced technical analysis.

#### Features:

- **Interactive OHLC Charts**: Highcharts-based candlestick visualization
- **Technical Indicators**: Moving averages (SMA 20, SMA 50)
- **Volume Analysis**: Volume charts with price correlation
- **Volatility Analysis**: 14-period volatility calculations
- **Price Distribution**: Statistical analysis of price changes
- **Export Capabilities**: Save charts as interactive HTML files

#### Usage:
```bash
clt-ohlcplot plot data.csv chart.html
clt-ohlcplot plot data.csv chart.html --title="Bitcoin Analysis" --height=800
```

#### Options:
- `--title=<title>`: Chart title
- `--theme=<theme>`: Chart theme (light/dark)
- `--height=<height>`: Chart height in pixels

## Installation

### Requirements
- macOS 10.15 or later
- Swift 6.0 or later

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SwiftyOHLC.git
cd SwiftyOHLC
```

2. Build the project:
```bash
swift build
```

3. Build the command-line tools:
```bash
swift build -c release
```

### Using as a Library

Add SwiftyOHLC to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftyOHLC.git", from: "1.0.0")
]
```

## Usage Examples

### Basic Data Generation

```swift
import SwiftyOHLC

let config = GeneratorConfig(
    marketMode: .uptrend,
    candleCount: 100,
    initialPrice: 100.0,
    volatility: 0.02
)

let generator = SwiftyOHLC(config: config)
let candles = generator.generate()
```

### Analysis

```swift
let analysis = CandleAnalyzer.analyze(candles)
print("Bullish candles: \(analysis.bullishCandles)")
print("Bearish candles: \(analysis.bearishCandles)")
print("Average volume: \(analysis.averageVolume)")
```

### Export to CSV

```swift
let csvContent = CandleExporter.exportToCSV(candles: candles)
try csvContent.write(toFile: "data.csv", atomically: true, encoding: .utf8)
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on the GitHub repository. 
