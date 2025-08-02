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
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            :root {
                --primary-color: #0a0e1a;
                --secondary-color: #1a1f2e;
                --accent-color: #4facfe;
                --success-color: #00d4ff;
                --warning-color: #ffd700;
                --danger-color: #ff6b6b;
                --bg-primary: #050709;
                --bg-secondary: #0a0e1a;
                --bg-tertiary: #1a1f2e;
                --text-primary: #ffffff;
                --text-secondary: #a0a8c0;
                --text-accent: #4facfe;
                --border-color: rgba(79, 172, 254, 0.2);
                --shadow-color: rgba(0,0,0,0.6);
                --grid-color: rgba(79, 172, 254, 0.05);
                --chart-bg: #0a0e1a;
                --card-bg: rgba(26, 31, 46, 0.9);
                --gradient-primary: linear-gradient(135deg, #4facfe 0%, #00d4ff 100%);
                --gradient-secondary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                --gradient-accent: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
                --glow-blue: rgba(79, 172, 254, 0.3);
                --glow-cyan: rgba(0, 212, 255, 0.3);
            }
            
                    body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            min-height: 100vh;
            overflow-x: hidden;
            position: relative;
            line-height: 1.6;
        }
        
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, var(--glow-blue) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, var(--glow-cyan) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(102, 126, 234, 0.1) 0%, transparent 50%),
                linear-gradient(90deg, var(--grid-color) 1px, transparent 1px),
                linear-gradient(0deg, var(--grid-color) 1px, transparent 1px);
            background-size: 300px 300px, 250px 250px, 200px 200px, 50px 50px, 50px 50px;
            opacity: 0.4;
            pointer-events: none;
            z-index: -1;
        }
            
            .container {
                max-width: 1400px;
                margin: 0 auto;
                padding: 30px;
                position: relative;
            }
            
            .header {
                text-align: center;
                margin-bottom: 40px;
                background: var(--card-bg);
                padding: 40px;
                border-radius: 16px;
                border: 1px solid var(--border-color);
                box-shadow: 0 12px 40px var(--shadow-color);
                backdrop-filter: blur(15px);
                position: relative;
                overflow: hidden;
            }
            
            .header::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 2px;
                background: var(--gradient-primary);
            }
            
            .header h1 {
                font-size: 2.8rem;
                font-weight: 800;
                background: var(--gradient-primary);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
                margin-bottom: 10px;
                font-family: 'Inter', sans-serif;
                text-shadow: 0 0 30px var(--glow-blue);
            }
            
            .header p {
                font-size: 1.1rem;
                color: var(--text-secondary);
                font-weight: 400;
                margin-bottom: 20px;
            }
            
            .header .metadata {
                display: flex;
                justify-content: center;
                gap: 30px;
                flex-wrap: wrap;
                font-size: 0.9rem;
                color: var(--text-secondary);
            }
            
            .metadata-item {
                display: flex;
                align-items: center;
                gap: 5px;
            }
            
            .charts-grid {
                display: grid;
                grid-template-columns: 1fr;
                gap: 30px;
                margin-bottom: 40px;
            }
            
            .chart-container {
                background: var(--card-bg);
                border-radius: 16px;
                padding: 30px;
                border: 1px solid var(--border-color);
                box-shadow: 0 12px 40px var(--shadow-color);
                backdrop-filter: blur(15px);
                transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
            }
            
            .chart-container::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 2px;
                background: var(--gradient-secondary);
                opacity: 0;
                transition: opacity 0.3s ease;
            }
            
            .chart-container:hover::before {
                opacity: 1;
            }
            
            .chart-container:hover {
                box-shadow: 0 20px 60px var(--shadow-color);
                transform: translateY(-4px) scale(1.02);
            }
            
            .chart-title {
                font-size: 1.4rem;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 20px;
                text-align: center;
                border-bottom: 2px solid var(--accent-color);
                padding-bottom: 12px;
                text-shadow: 0 0 15px var(--glow-blue);
                position: relative;
            }
            
            .chart-title::after {
                content: '';
                position: absolute;
                bottom: -2px;
                left: 50%;
                transform: translateX(-50%);
                width: 50px;
                height: 2px;
                background: var(--gradient-primary);
                border-radius: 1px;
            }
            
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 20px;
                margin-top: 30px;
            }
            
            .stat-card {
                background: var(--card-bg);
                padding: 25px;
                border-radius: 16px;
                border: 1px solid var(--border-color);
                box-shadow: 0 12px 40px var(--shadow-color);
                backdrop-filter: blur(15px);
                transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                overflow: hidden;
            }
            
            .stat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: linear-gradient(45deg, transparent 30%, var(--glow-blue) 50%, transparent 70%);
                transform: translateX(-100%);
                transition: transform 0.6s ease;
            }
            
            .stat-card:hover::before {
                transform: translateX(100%);
            }
            
            .stat-card:hover {
                box-shadow: 0 20px 60px var(--shadow-color);
                transform: translateY(-4px) scale(1.02);
            }
            
            .stat-card h3 {
                font-size: 1rem;
                font-weight: 600;
                color: var(--text-primary);
                margin-bottom: 10px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .stat-value {
                font-size: 2rem;
                font-weight: 800;
                background: var(--gradient-primary);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
                margin-bottom: 8px;
                font-family: 'Inter', monospace;
                text-shadow: 0 0 20px var(--glow-blue);
            }
            
            .stat-description {
                font-size: 0.9rem;
                color: var(--text-secondary);
                font-weight: 400;
            }
            
            .chart-wrapper {
                height: \(height)px;
                border-radius: 6px;
                overflow: hidden;
                position: relative;
                background: var(--chart-bg);
            }
            
            .small-chart {
                height: 400px;
                border-radius: 6px;
                overflow: hidden;
                position: relative;
                background: var(--chart-bg);
            }
            
            .loading-animation {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                z-index: 1000;
                background: var(--card-bg);
                padding: 30px;
                border-radius: 16px;
                border: 1px solid var(--border-color);
                box-shadow: 0 12px 40px var(--shadow-color);
                backdrop-filter: blur(15px);
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 20px;
            }
            
            .spinner {
                width: 40px;
                height: 40px;
                border: 3px solid var(--border-color);
                border-top: 3px solid var(--accent-color);
                border-radius: 50%;
                animation: spin 1s linear infinite;
                box-shadow: 0 0 20px var(--glow-blue);
            }
            
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            
            @media (max-width: 768px) {
                .container {
                    padding: 15px;
                }
                
                .header h1 {
                    font-size: 2.5rem;
                }
                
                .header p {
                    font-size: 1.1rem;
                }
                
                .stats-grid {
                    grid-template-columns: 1fr;
                }
                
                .chart-container {
                    padding: 20px;
                }
            }
            
            @media (max-width: 480px) {
                .header h1 {
                    font-size: 2rem;
                }
                
                .stat-value {
                    font-size: 1.8rem;
                }
            }
        </style>
    </head>
    <body>
        <div class="loading-animation" id="loading">
            <div class="spinner"></div>
            <div style="color: var(--text-primary); font-weight: 600;">Loading Scientific Analysis...</div>
        </div>
        
        <div class="container">
            <div class="header">
                <h1>\(title)</h1>
                <p>Scientific Financial Data Analysis</p>
                <div class="metadata">
                    <div class="metadata-item">
                        <span>📊</span>
                        <span>Data Points: \(candles.count)</span>
                    </div>
                    <div class="metadata-item">
                        <span>📅</span>
                        <span>Period: \(formatDate(candles.first?.timestamp)) - \(formatDate(candles.last?.timestamp))</span>
                    </div>
                    <div class="metadata-item">
                        <span>🔬</span>
                        <span>Analysis: OHLC + Volatility + Distribution</span>
                    </div>
                </div>
            </div>
            
            <div class="charts-grid">
                <div class="chart-container">
                    <div class="chart-title">📈 OHLC Chart with Moving Averages</div>
                    <div class="chart-wrapper" id="mainChart"></div>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">📊 Volatility Analysis (14-period)</div>
                    <div class="small-chart" id="volatilityChart"></div>
                </div>
                
                <div class="chart-container">
                    <div class="chart-title">📉 Price Changes Distribution</div>
                    <div class="small-chart" id="distributionChart"></div>
                </div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Data Points</h3>
                    <div class="stat-value">\(candles.count)</div>
                    <div class="stat-description">Total candles analyzed</div>
                </div>
                <div class="stat-card">
                    <h3>Price Range</h3>
                    <div class="stat-value">\(String(format: "%.2f", getPriceRange(candles)))</div>
                    <div class="stat-description">High - Low difference</div>
                </div>
                <div class="stat-card">
                    <h3>Total Volume</h3>
                    <div class="stat-value">\(String(format: "%.0f", getTotalVolume(candles)))</div>
                    <div class="stat-description">Trading volume</div>
                </div>
                <div class="stat-card">
                    <h3>Avg Volatility</h3>
                    <div class="stat-value">\(String(format: "%.2f", getAverageVolatility(candles)))</div>
                    <div class="stat-description">14-period average</div>
                </div>
                <div class="stat-card">
                    <h3>Price Change</h3>
                    <div class="stat-value">\(String(format: "%.2f", getPriceChangePercent(candles)))%</div>
                    <div class="stat-description">Overall change</div>
                </div>
                <div class="stat-card">
                    <h3>Analysis Date</h3>
                    <div class="stat-value">\(formatDate(Date()))</div>
                    <div class="stat-description">Generated on</div>
                </div>
            </div>
        </div>
        
        <script>
            // Hide loading animation
            function hideLoading() {
                const loading = document.getElementById('loading');
                loading.style.opacity = '0';
                setTimeout(() => {
                    loading.style.display = 'none';
                }, 500);
            }
            
            // Initialize and hide loading
            setTimeout(hideLoading, 1000);
            
            // Main OHLC Chart
            Highcharts.stockChart('mainChart', {
                chart: {
                    backgroundColor: 'var(--chart-bg)',
                    style: {
                        fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
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
                        color: 'var(--text-primary)',
                        fontSize: '16px',
                        fontWeight: '600'
                    }
                },
                
                subtitle: {
                    text: 'Scientific Financial Analysis',
                    style: {
                        color: 'var(--text-secondary)'
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
                        upColor: '#4facfe',
                        lineColor: '#ff6b6b',
                        upLineColor: '#4facfe',
                        animation: {
                            duration: 1000
                        }
                    },
                    column: {
                        color: '#00d4ff',
                        borderColor: '#00d4ff',
                        animation: {
                            duration: 1000
                        }
                    },
                    line: {
                        lineWidth: 3,
                        animation: {
                            duration: 1000
                        }
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
                    color: '#4facfe',
                    lineWidth: 2
                }, {
                    type: 'line',
                    name: 'SMA 50',
                    data: [
                        \(sma50Data)
                    ],
                    color: '#00d4ff',
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
                    type: 'area',
                    animation: {
                        duration: 1000,
                        easing: 'easeOutQuart'
                    }
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
                                [0, 'rgba(79, 172, 254, 0.4)'],
                                [1, 'rgba(79, 172, 254, 0.1)']
                            ]
                        },
                        lineColor: '#4facfe',
                        lineWidth: 3,
                        animation: {
                            duration: 1000
                        }
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
                    type: 'column',
                    animation: {
                        duration: 1000,
                        easing: 'easeOutQuart'
                    }
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
                        color: '#00d4ff',
                        borderColor: '#00d4ff',
                        borderRadius: 5,
                        animation: {
                            duration: 1000
                        }
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