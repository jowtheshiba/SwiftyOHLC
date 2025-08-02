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
case "plot":
    handlePlotCommand(Array(arguments.dropFirst()))
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

func handlePlotCommand(_ args: [String]) {
    guard args.count >= 2 else {
        print("❌ Please specify input CSV file and output HTML file")
        print("Usage: clt-ohlcplot plot <input.csv> <output.html> [options]")
        exit(1)
    }
    
    let inputFile = args[0]
    let outputFile = args[1]
    
    // Parse optional arguments
    var options: [String: String] = [:]
    for i in 2..<args.count {
        let arg = args[i]
        if arg.hasPrefix("--") {
            let parts = arg.dropFirst(2).split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                options[String(parts[0])] = String(parts[1])
            }
        }
    }
    
    do {
        let candles = try parseCSVFile(inputFile)
        let htmlContent = generateInteractiveHTML(candles: candles, options: options)
        try htmlContent.write(toFile: outputFile, atomically: true, encoding: .utf8)
        print("✅ Generated interactive HTML plot: \(outputFile)")
        print("  Input: \(inputFile)")
        print("  Candles: \(candles.count)")
    } catch {
        print("❌ Error: \(error)")
        exit(1)
    }
}

// MARK: - CSV Parsing

func parseCSVFile(_ filename: String) throws -> [Candle] {
    let content = try String(contentsOfFile: filename, encoding: .utf8)
    let lines = content.components(separatedBy: .newlines)
    
    var candles: [Candle] = []
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    for (index, line) in lines.enumerated() {
        // Skip empty lines and comments
        if line.isEmpty || line.hasPrefix("#") {
            continue
        }
        
        let columns = line.components(separatedBy: ",")
        guard columns.count >= 6 else {
            print("⚠️  Skipping line \(index + 1): insufficient columns")
            continue
        }
        
        guard let timestamp = dateFormatter.date(from: columns[0].trimmingCharacters(in: .whitespaces)),
              let open = Double(columns[1].trimmingCharacters(in: .whitespaces)),
              let high = Double(columns[2].trimmingCharacters(in: .whitespaces)),
              let low = Double(columns[3].trimmingCharacters(in: .whitespaces)),
              let close = Double(columns[4].trimmingCharacters(in: .whitespaces)),
              let volume = Double(columns[5].trimmingCharacters(in: .whitespaces)) else {
            print("⚠️  Skipping line \(index + 1): invalid data format")
            continue
        }
        
        let candle = Candle(
            timestamp: timestamp,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
        candles.append(candle)
    }
    
    guard !candles.isEmpty else {
        throw PlotError.noValidData
    }
    
    return candles
}

// MARK: - HTML Generation

func generateInteractiveHTML(candles: [Candle], options: [String: String]) -> String {
    let title = options["title"] ?? "OHLC Chart"
    _ = options["theme"] ?? "dark" // Default to dark theme
    let height = options["height"] ?? "800"
    
    // Calculate moving averages
    let sma20 = calculateSMA(candles: candles, period: 20)
    let sma50 = calculateSMA(candles: candles, period: 50)
    
    // Calculate volatility
    let volatilityData = calculateVolatility(candles: candles, period: 14)
    
    // Calculate price changes distribution
    let priceChanges = calculatePriceChanges(candles: candles)
    
    let candleData = candles.map { candle in
        let timestamp = Int(candle.timestamp.timeIntervalSince1970 * 1000)
        return "[\(timestamp), \(candle.open), \(candle.high), \(candle.low), \(candle.close), \(candle.volume)]"
    }.joined(separator: ",\n        ")
    
    let volumeData = candles.map { candle in
        let timestamp = Int(candle.timestamp.timeIntervalSince1970 * 1000)
        return "[\(timestamp), \(candle.volume)]"
    }.joined(separator: ",\n        ")
    
    let sma20Data = sma20.map { (timestamp, value) in
        return "[\(timestamp), \(value)]"
    }.joined(separator: ",\n        ")
    
    let sma50Data = sma50.map { (timestamp, value) in
        return "[\(timestamp), \(value)]"
    }.joined(separator: ",\n        ")
    
    let volatilityChartData = volatilityData.map { (timestamp, value) in
        return "[\(timestamp), \(value)]"
    }.joined(separator: ",\n        ")
    
    let priceChangesData = priceChanges.map { (change, count) in
        return "[\(change), \(count)]"
    }.joined(separator: ",\n        ")
    
    let html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>\(title)</title>
        <script src="https://code.highcharts.com/stock/highstock.js"></script>
        <script src="https://code.highcharts.com/stock/modules/data.js"></script>
        <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
        <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
        <script src="https://code.highcharts.com/stock/modules/export-data.js"></script>
        <script src="https://code.highcharts.com/stock/modules/accessibility.js"></script>
        <script src="https://code.highcharts.com/highcharts.js"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 50%, #16213e 100%);
                color: #ffffff;
                min-height: 100vh;
                overflow-x: hidden;
            }
            
            .container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 20px;
            }
            
            .header {
                text-align: center;
                margin-bottom: 30px;
                background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
                padding: 30px;
                border-radius: 20px;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.1);
            }
            
            .header h1 {
                font-size: 2.5rem;
                font-weight: 700;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
                margin-bottom: 10px;
            }
            
            .header p {
                font-size: 1.1rem;
                color: #a0a0a0;
                font-weight: 300;
            }
            
            .charts-grid {
                display: grid;
                grid-template-columns: 1fr;
                gap: 30px;
                margin-bottom: 30px;
            }
            
            .chart-container {
                background: linear-gradient(135deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.02) 100%);
                border-radius: 20px;
                padding: 20px;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.1);
                box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            }
            
            .chart-title {
                font-size: 1.3rem;
                font-weight: 600;
                color: #ffffff;
                margin-bottom: 15px;
                text-align: center;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
            }
            
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-top: 30px;
            }
            
            .stat-card {
                background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
                padding: 25px;
                border-radius: 15px;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.1);
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }
            
            .stat-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 40px rgba(0,0,0,0.4);
            }
            
            .stat-card h3 {
                font-size: 1.1rem;
                font-weight: 600;
                color: #667eea;
                margin-bottom: 10px;
            }
            
            .stat-value {
                font-size: 1.8rem;
                font-weight: 700;
                color: #ffffff;
                margin-bottom: 5px;
            }
            
            .stat-description {
                font-size: 0.9rem;
                color: #a0a0a0;
                font-weight: 300;
            }
            
            .chart-wrapper {
                height: \(height)px;
                border-radius: 15px;
                overflow: hidden;
            }
            
            .small-chart {
                height: 400px;
                border-radius: 15px;
                overflow: hidden;
            }
            
            @media (max-width: 768px) {
                .container {
                    padding: 10px;
                }
                
                .header h1 {
                    font-size: 2rem;
                }
                
                .stats-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>\(title)</h1>
                <p>Advanced Financial Analysis Dashboard</p>
            </div>
            
            <div class="charts-grid">
                <div class="chart-container">
                    <div class="chart-title">📈 Main OHLC Chart with Moving Averages</div>
                    <div class="chart-wrapper" id="mainChart"></div>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">📊 Volatility Analysis</div>
                    <div class="small-chart" id="volatilityChart"></div>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">📉 Price Changes Distribution</div>
                    <div class="small-chart" id="distributionChart"></div>
                </div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>📊 Total Candles</h3>
                    <div class="stat-value">\(candles.count)</div>
                    <div class="stat-description">Data points analyzed</div>
                </div>
                <div class="stat-card">
                    <h3>📅 Date Range</h3>
                    <div class="stat-value">\(formatDate(candles.first?.timestamp))</div>
                    <div class="stat-description">to \(formatDate(candles.last?.timestamp))</div>
                </div>
                <div class="stat-card">
                    <h3>💰 Price Range</h3>
                    <div class="stat-value">\(String(format: "%.2f", getPriceRange(candles)))</div>
                    <div class="stat-description">High - Low difference</div>
                </div>
                <div class="stat-card">
                    <h3>📈 Total Volume</h3>
                    <div class="stat-value">\(String(format: "%.0f", getTotalVolume(candles)))</div>
                    <div class="stat-description">Trading volume</div>
                </div>
                <div class="stat-card">
                    <h3>📊 Average Volatility</h3>
                    <div class="stat-value">\(String(format: "%.2f", getAverageVolatility(candles)))</div>
                    <div class="stat-description">14-period average</div>
                </div>
                <div class="stat-card">
                    <h3>📉 Price Change</h3>
                    <div class="stat-value">\(String(format: "%.2f", getPriceChangePercent(candles)))%</div>
                    <div class="stat-description">Overall change</div>
                </div>
            </div>
        </div>
        
        <script>
            // Main OHLC Chart
            Highcharts.stockChart('mainChart', {
                chart: {
                    backgroundColor: 'transparent',
                    style: {
                        fontFamily: 'SF Pro Display, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
                    }
                },
                
                rangeSelector: {
                    selected: 1,
                    buttons: [
                        { type: 'minute', count: 30, text: '30m' },
                        { type: 'hour', count: 1, text: '1h' },
                        { type: 'hour', count: 6, text: '6h' },
                        { type: 'day', count: 1, text: '1d' },
                        { type: 'all', text: 'All' }
                    ],
                    inputStyle: {
                        backgroundColor: 'rgba(255,255,255,0.1)',
                        color: '#ffffff'
                    },
                    labelStyle: {
                        color: '#ffffff'
                    }
                },
                
                title: {
                    text: '\(title)',
                    style: {
                        color: '#ffffff',
                        fontSize: '18px',
                        fontWeight: '600'
                    }
                },
                
                subtitle: {
                    text: 'Generated with SwiftyOHLC',
                    style: {
                        color: '#a0a0a0'
                    }
                },
                
                xAxis: {
                    type: 'datetime',
                    labels: {
                        style: {
                            color: '#ffffff'
                        }
                    },
                    lineColor: 'rgba(255,255,255,0.2)',
                    tickColor: 'rgba(255,255,255,0.2)'
                },
                
                yAxis: [{
                    labels: {
                        align: 'right',
                        x: -3,
                        style: {
                            color: '#ffffff'
                        }
                    },
                    title: {
                        text: 'Price',
                        style: {
                            color: '#ffffff'
                        }
                    },
                    height: '60%',
                    lineWidth: 2,
                    lineColor: 'rgba(255,255,255,0.2)',
                    gridLineColor: 'rgba(255,255,255,0.1)',
                    resize: {
                        enabled: true
                    }
                }, {
                    labels: {
                        align: 'right',
                        x: -3,
                        style: {
                            color: '#ffffff'
                        }
                    },
                    title: {
                        text: 'Volume',
                        style: {
                            color: '#ffffff'
                        }
                    },
                    top: '65%',
                    height: '35%',
                    offset: 0,
                    lineWidth: 2,
                    lineColor: 'rgba(255,255,255,0.2)',
                    gridLineColor: 'rgba(255,255,255,0.1)'
                }],
                
                legend: {
                    enabled: true,
                    style: {
                        color: '#ffffff'
                    }
                },
                
                plotOptions: {
                    candlestick: {
                        color: '#ff6b6b',
                        upColor: '#51cf66',
                        lineColor: '#ff6b6b',
                        upLineColor: '#51cf66'
                    },
                    column: {
                        color: '#74c0fc',
                        borderColor: '#74c0fc'
                    },
                    line: {
                        lineWidth: 2
                    }
                },
                
                series: [{
                    type: 'candlestick',
                    name: 'OHLC',
                    id: 'ohlc',
                    data: [
                        \(candleData)
                    ]
                }, {
                    type: 'line',
                    name: 'SMA 20',
                    data: [
                        \(sma20Data)
                    ],
                    color: '#ffd43b',
                    lineWidth: 2
                }, {
                    type: 'line',
                    name: 'SMA 50',
                    data: [
                        \(sma50Data)
                    ],
                    color: '#ff922b',
                    lineWidth: 2
                }, {
                    type: 'column',
                    name: 'Volume',
                    id: 'volume',
                    data: [
                        \(volumeData)
                    ],
                    yAxis: 1
                }],
                
                tooltip: {
                    backgroundColor: 'rgba(0,0,0,0.8)',
                    borderColor: 'rgba(255,255,255,0.2)',
                    style: {
                        color: '#ffffff'
                    },
                    formatter: function () {
                        var s = '<b>' + Highcharts.dateFormat('%A, %b %e, %Y', this.x) + '</b><br/>';
                        
                        if (this.series.name === 'OHLC') {
                            s += 'Open: ' + Highcharts.numberFormat(this.point.open, 2) + '<br/>';
                            s += 'High: ' + Highcharts.numberFormat(this.point.high, 2) + '<br/>';
                            s += 'Low: ' + Highcharts.numberFormat(this.point.low, 2) + '<br/>';
                            s += 'Close: ' + Highcharts.numberFormat(this.point.close, 2) + '<br/>';
                        } else if (this.series.name.includes('SMA')) {
                            s += 'SMA: ' + Highcharts.numberFormat(this.y, 2);
                        } else {
                            s += 'Volume: ' + Highcharts.numberFormat(this.y, 0);
                        }
                        
                        return s;
                    }
                }
            });
            
            // Volatility Chart
            Highcharts.chart('volatilityChart', {
                chart: {
                    backgroundColor: 'transparent',
                    type: 'area'
                },
                
                title: {
                    text: 'Volatility Analysis',
                    style: {
                        color: '#ffffff',
                        fontSize: '16px',
                        fontWeight: '600'
                    }
                },
                
                xAxis: {
                    type: 'datetime',
                    labels: {
                        style: {
                            color: '#ffffff'
                        }
                    },
                    lineColor: 'rgba(255,255,255,0.2)',
                    tickColor: 'rgba(255,255,255,0.2)'
                },
                
                yAxis: {
                    title: {
                        text: 'Volatility',
                        style: {
                            color: '#ffffff'
                        }
                    },
                    labels: {
                        style: {
                            color: '#ffffff'
                        }
                    },
                    gridLineColor: 'rgba(255,255,255,0.1)'
                },
                
                plotOptions: {
                    area: {
                        fillColor: {
                            linearGradient: {
                                x1: 0,
                                y1: 0,
                                x2: 0,
                                y2: 1
                            },
                            stops: [
                                [0, 'rgba(255, 107, 107, 0.3)'],
                                [1, 'rgba(255, 107, 107, 0.1)']
                            ]
                        },
                        lineColor: '#ff6b6b',
                        lineWidth: 2
                    }
                },
                
                series: [{
                    name: 'Volatility',
                    data: [
                        \(volatilityChartData)
                    ]
                }],
                
                tooltip: {
                    backgroundColor: 'rgba(0,0,0,0.8)',
                    borderColor: 'rgba(255,255,255,0.2)',
                    style: {
                        color: '#ffffff'
                    }
                }
            });
            
            // Distribution Chart
            Highcharts.chart('distributionChart', {
                chart: {
                    backgroundColor: 'transparent',
                    type: 'column'
                },
                
                title: {
                    text: 'Price Changes Distribution',
                    style: {
                        color: '#ffffff',
                        fontSize: '16px',
                        fontWeight: '600'
                    }
                },
                
                xAxis: {
                    title: {
                        text: 'Price Change (%)',
                        style: {
                            color: '#ffffff'
                        }
                    },
                    labels: {
                        style: {
                            color: '#ffffff'
                        }
                    },
                    lineColor: 'rgba(255,255,255,0.2)',
                    tickColor: 'rgba(255,255,255,0.2)'
                },
                
                yAxis: {
                    title: {
                        text: 'Frequency',
                        style: {
                            color: '#ffffff'
                        }
                    },
                    labels: {
                        style: {
                            color: '#ffffff'
                        }
                    },
                    gridLineColor: 'rgba(255,255,255,0.1)'
                },
                
                plotOptions: {
                    column: {
                        color: '#74c0fc',
                        borderColor: '#74c0fc',
                        borderRadius: 3
                    }
                },
                
                series: [{
                    name: 'Frequency',
                    data: [
                        \(priceChangesData)
                    ]
                }],
                
                tooltip: {
                    backgroundColor: 'rgba(0,0,0,0.8)',
                    borderColor: 'rgba(255,255,255,0.2)',
                    style: {
                        color: '#ffffff'
                    }
                }
            });
        </script>
    </body>
    </html>
    """
    
    return html
}

// MARK: - Helper Functions

func formatDate(_ date: Date?) -> String {
    guard let date = date else { return "N/A" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
}

func getPriceRange(_ candles: [Candle]) -> Double {
    guard !candles.isEmpty else { return 0 }
    let minPrice = candles.map { $0.low }.min() ?? 0
    let maxPrice = candles.map { $0.high }.max() ?? 0
    return maxPrice - minPrice
}

func getTotalVolume(_ candles: [Candle]) -> Double {
    return candles.reduce(0) { $0 + $1.volume }
}

// MARK: - Technical Indicators

func calculateSMA(candles: [Candle], period: Int) -> [(Int, Double)] {
    guard candles.count >= period else { return [] }
    
    var smaData: [(Int, Double)] = []
    
    for i in (period - 1)..<candles.count {
        let startIndex = i - period + 1
        let endIndex = i
        let prices = candles[startIndex...endIndex].map { $0.close }
        let average = prices.reduce(0, +) / Double(prices.count)
        
        let timestamp = Int(candles[i].timestamp.timeIntervalSince1970 * 1000)
        smaData.append((timestamp, average))
    }
    
    return smaData
}

func calculateVolatility(candles: [Candle], period: Int) -> [(Int, Double)] {
    guard candles.count >= period else { return [] }
    
    var volatilityData: [(Int, Double)] = []
    
    for i in (period - 1)..<candles.count {
        let startIndex = i - period + 1
        let endIndex = i
        let returns = candles[startIndex...endIndex].enumerated().dropFirst().map { index, candle in
            let previousCandle = candles[startIndex + index - 1]
            return (candle.close - previousCandle.close) / previousCandle.close
        }
        
        let mean = returns.reduce(0, +) / Double(returns.count)
        let variance = returns.map { pow($0 - mean, 2) }.reduce(0, +) / Double(returns.count)
        let volatility = sqrt(variance) * 100 // Convert to percentage
        
        let timestamp = Int(candles[i].timestamp.timeIntervalSince1970 * 1000)
        volatilityData.append((timestamp, volatility))
    }
    
    return volatilityData
}

func calculatePriceChanges(candles: [Candle]) -> [(Double, Int)] {
    guard candles.count > 1 else { return [] }
    
    var changes: [Double] = []
    
    for i in 1..<candles.count {
        let previousClose = candles[i - 1].close
        let currentClose = candles[i].close
        let change = ((currentClose - previousClose) / previousClose) * 100
        changes.append(change)
    }
    
    // Group changes into bins
    let minChange = changes.min() ?? 0
    let maxChange = changes.max() ?? 0
    let binCount = 10
    let binSize = (maxChange - minChange) / Double(binCount)
    
    var distribution: [Double: Int] = [:]
    
    for change in changes {
        let bin = round(change / binSize) * binSize
        distribution[bin, default: 0] += 1
    }
    
    return distribution.sorted { $0.key < $1.key }
}

func getAverageVolatility(_ candles: [Candle]) -> Double {
    let volatilityData = calculateVolatility(candles: candles, period: 14)
    guard !volatilityData.isEmpty else { return 0 }
    
    let average = volatilityData.map { $0.1 }.reduce(0, +) / Double(volatilityData.count)
    return average
}

func getPriceChangePercent(_ candles: [Candle]) -> Double {
    guard let firstCandle = candles.first,
          let lastCandle = candles.last else { return 0 }
    
    let change = ((lastCandle.close - firstCandle.open) / firstCandle.open) * 100
    return change
}

func printUsage() {
    print("""
    Usage: clt-ohlcplot <command> [options]
    
    Commands:
      plot <input.csv> <output.html> [options]  Generate interactive HTML from CSV
      help                                      Show this help message
      version                                   Show version information
    
    Options for plot command:
      --title=<title>                           Chart title (default: "OHLC Chart")
      --theme=<theme>                           Chart theme: light or dark (default: light)
      --height=<height>                         Chart height in pixels (default: 600)
    
    Examples:
      clt-ohlcplot plot data.csv chart.html
      clt-ohlcplot plot data.csv chart.html --title="Bitcoin Price" --theme=dark
      clt-ohlcplot plot data.csv chart.html --height=800 --title="Stock Analysis"
    """)
}

func printVersion() {
    print("clt-ohlcplot v1.0.0")
}

// MARK: - Error Types

enum PlotError: Error, LocalizedError {
    case noValidData
    
    var errorDescription: String? {
        switch self {
        case .noValidData:
            return "No valid data found in CSV file"
        }
    }
} 