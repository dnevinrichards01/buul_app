//
//  graph.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI
import Charts
import CoreGraphics

struct StockGraphView: View {
    var graphHeight: Double = 300
    var stockData: [StockDataPoint]
    @Binding var mostRecentValue: Double?
    
    @State private var selectedPrice: Double? = nil
    @State private var selectedDate: Date? = nil
    @State private var exactX: CGFloat? = nil
    @State private var exactDate: Date? = nil
    @State private var interpolatedY: CGFloat? = nil
    @State private var interpolatedPrice: Double? = nil
    
    var timePeriod: GraphUtils.GraphPartitions
    @Binding var color: Color
    
    
    var body: some View {
        VStack(alignment: .leading) {
            // Top Left Stats
            VStack(alignment: .leading, spacing: 1) {
                Text("Investing")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, -5)
                    .foregroundStyle(.white)
                Text(formatAsCurrency(self.mostRecentValue ?? stockData.last!.price))
                    .font(.headline)
                    .foregroundStyle(.white)
                HStack {
                    Image(systemName: changeSymbol())
                        .foregroundStyle(color)
                        .font(.system(size: 12))
                        .padding(.trailing, -5)
                        .fontWeight(.bold)
                    Text(changeText())
                        .foregroundColor(color)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
            }
            .padding()
            .padding(.top, 20)
            .padding(.bottom, 40)
            
            // Stock Chart
            GeometryReader { geometry in
                ZStack {
                    let range: [Double] = getRange()
                    let domain: [Date] = getDomain()
                    
                    Chart {
                        ForEach(stockData) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Price", point.price)
                            )
                            .foregroundStyle(color)
                            .lineStyle(StrokeStyle(lineWidth: 1))
//                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartXAxis(.hidden)  // Hides X-axis
                    .chartYAxis(.hidden)  // Hides Y-axis
                    .chartYScale(domain: range[0]...range[1])
                    .chartXScale(domain: domain[0]...domain[1])
                    .chartPlotStyle { plotArea in
                        plotArea
                            .background(.clear) // Remove background grid
                            .border(.clear)     // Remove any borders
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: graphHeight)
                    .chartOverlay { proxy in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let location = value.location
                                        if let date: Date = proxy.value(atX: location.x) {
                                            let lastDate = stockData.last!.date
                                            let lastPrice = stockData.last!.price
                                            if date >= stockData.last!.date && timePeriod == .oneDay {
                                                exactDate = lastDate
                                                exactX = proxy.position(forX: lastDate)
                                                interpolatedPrice = lastPrice
                                                interpolatedY = proxy.position(forY: lastPrice)
                                                selectedPrice = lastPrice
                                                selectedDate = lastDate
                                            } else {
                                                exactDate = date
                                                exactX = location.x
                                                if let _interpolatedPrice = interpolatePrice(for: date) {
                                                    interpolatedPrice = _interpolatedPrice
                                                    interpolatedY = proxy.position(forY: _interpolatedPrice)
                                                    if let closestPoint = nearestPrice(for: date) {
                                                        selectedPrice = closestPoint.price
                                                        selectedDate = closestPoint.date
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                    .onEnded { _ in
                                        exactX = nil
                                        exactDate = nil
                                        selectedPrice = nil
                                        selectedDate = nil
                                        interpolatedY = nil
                                        interpolatedPrice = nil
                                    }
                            )
                    }
                    let graphWidth = geometry.size.width
                    let graphHeight = graphHeight
                    if let selectedPrice = selectedPrice,
                       let selectedDate = selectedDate,
                       let xPos = exactX,
                       let yPos = interpolatedY,
                       let exactDate = exactDate, exactDate >= domain[0], exactDate <= domain[1]
                        {
                            Circle()
                                .fill(color)
                                .frame(width: 15, height: 15)
                                .offset(
                                    x: xPos - graphWidth / 2,
                                    y: yPos - graphHeight / 2
                                )
                            VStack(alignment: .center) {
                                Text(formatAsCurrency(selectedPrice))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(formatDate(selectedDate))
                                    .foregroundColor(color)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: 120, alignment: .center)
                            .offset(
                                x: boundTooltipX(xPos, width: graphWidth),
                                y: 30 - graphHeight / 2 - 65
                            )
                            let rectHeight = min(graphHeight - yPos, graphHeight / 2)
                            Rectangle()
                                .fill(color) // Base color
                                .frame(width: 2, height: rectHeight) // Line height
                                .frame(maxWidth: .infinity)
                                .offset(
                                    x: xPos - graphWidth / 2,
                                    y: yPos + rectHeight / 2 - graphHeight / 2
                                ) // Position it correctly
                                .mask( // Apply the fading gradient mask
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: color.opacity(1.0), location: 0.0), // Full color at start
                                            .init(color: color.opacity(0.7), location: 0.5), // Quick fade
                                            .init(color: color.opacity(0.55), location: 0.6), // Slower fade
                                            .init(color: Color.clear, location: 1.0) // Fully transparent at the end
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: rectHeight)
                                    .offset(y: yPos + rectHeight / 2 - graphHeight / 2)
                                )
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    // Helper function for change in price
    
    func binarySearchIndex(for date: Date) -> Int {
        var low = 0
        var high = stockData.count - 1

        while low < high {
            let mid = (low + high) / 2
            if stockData[mid].date < date {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }
    
    func nearestPrice(for date: Date) -> StockDataPoint? {
        guard stockData.count > 1 else { return nil }

        // Perform Binary Search for the closest index
        let index = binarySearchIndex(for: date)

        // Ensure we have valid surrounding points
        if index == 0 || index >= stockData.count {
            return nil
        }

        let point1 = stockData[index - 1]  // Left neighbor
//        let point2 = stockData[index]      // Right neighbor
        
        return point1
    }
    
    func interpolatePrice(for date: Date) -> Double? {
        guard stockData.count > 1 else { return nil }

        // Perform Binary Search for the closest index
        let index = binarySearchIndex(for: date)

        // Ensure we have valid surrounding points
        if index == 0 || index >= stockData.count {
            return nil
        }

        let point1 = stockData[index - 1]  // Left neighbor
        let point2 = stockData[index]      // Right neighbor

        // Linear interpolation formula
        let t = (date.timeIntervalSince(point1.date)) / (point2.date.timeIntervalSince(point1.date))
        return point1.price + t * (point2.price - point1.price)
    }
    
    func getRange() -> [Double] {
        var minY = Double.greatestFiniteMagnitude
        var maxY = -Double.greatestFiniteMagnitude

        for point in stockData {
            if point.price < minY { minY = point.price }
            if point.price > maxY { maxY = point.price }
        }
        let padding = (maxY - minY) * 0.15
        return [minY - padding, maxY + padding]
    }
    
    func getDomain() -> [Date] {
        let min = stockData.first!.date
        var max = stockData.last!.date
        if timePeriod == .oneDay {
            max = Calendar.current.dateInterval(of: .day, for: max)!.end
        }
        return [min, max]
    }

    func formatAsCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    func boundTooltipX(_ x: CGFloat, width: CGFloat) -> CGFloat {
        let xPos = x - width / 2
        var buffer: CGFloat = 50
        if timePeriod == .oneWeek || timePeriod == .oneMonth {
            buffer = 70
        }
        if xPos < (buffer - width / 2) {
            return buffer - width / 2
        } else if xPos > width / 2 - buffer {
            return width / 2 - buffer
        } else {
            return xPos
        }
    }
    
    private static func getCustomDate() -> Date {
        let utcCalendar = Calendar(identifier: .gregorian)
        let utcTimeZone = TimeZone(secondsFromGMT: 0)! // UTC

        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 8
        components.minute = 30
        components.timeZone = utcTimeZone

        let utcDate = utcCalendar.date(from: components)!
        return utcDate
    }
    
    func formatDate(_ date: Date) -> String {
        let granularity = GraphUtils.granularityByPartition(
            partitionName: timePeriod,
            earliestDate: self.stockData.first!.date,
            now: Date()
        )
        let dateFormatString: String = GraphUtils.getDateFormatString(calendarComponents: granularity)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormatString
        return formatter.string(from: date)
    }
    
    func changeText() -> String {
        guard stockData.count > 1 else { return "0.00%" }
        let change = (self.mostRecentValue ?? stockData.last!.price) - stockData.first!.price
        var percentage: CGFloat
        if change == 0 {
            percentage = 0
        } else {
            percentage = (change / max(stockData[0].price, 0) ) * 100
        }
        return formatAsCurrency(abs(change)) + " (" + String(format: "%.2f%%", percentage) + ")"
    }
    
    func changeSymbol() -> String {
        guard stockData.count > 1 else { return "minus.circle.fill" }
        let change = (self.mostRecentValue ?? stockData.last!.price) - stockData.first!.price
        if change > 0 {
            return "arrowtriangle.up.fill"
        } else if change < 0 {
            return "arrowtriangle.down.fill"
        } else {
            return "minus.circle.fill"
        }
    }
    
    // Date Formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

let stockData: [StockDataPoint] = [
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 120),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 130),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 125),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 135),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 128),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 140),
    StockDataPoint(date: Date(), price: 10)
]

struct StockGraphView_Previews: PreviewProvider {
    static var previews: some View {
        StockGraphView(stockData: stockData, mostRecentValue: .constant(0.0), timePeriod: .oneDay, color: .constant(.gray))
    }
}

