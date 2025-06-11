//
//  GraphUtils.swift
//  buul_app
//
//  Created by Nevin Richards on 6/10/25.
//

import Foundation
import SwiftUI

class GraphUtils {
    static let calendar: Calendar = Calendar.current
    let now: Date = Date()
//    let earliestDate: Date

    
    enum GraphPartitions: String, CaseIterable {
        case oneDay = "oneDay"
        case oneWeek = "oneWeek"
        case oneMonth = "oneMonth"
        case threeMonths = "threeMonths"
        case oneYear = "oneYear"
        case ytd = "ytd"
        case all = "all"
    }
    
    enum DateParsingError: Error {
        case invalidISODateString
        case dateComputationError
    }
    
    static func isoformatToDate(isoDateString: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // explicitly UTC
        guard let date = formatter.date(from: isoDateString) else {
            throw DateParsingError.invalidISODateString
        }
        return date
    }
    
    static func getSmallestUnit(calendarComponentsSet: Set<Calendar.Component>) -> Calendar.Component {
        let sortedUnits: [Calendar.Component] = [.minute, .hour, .day, .weekOfYear, .month, .yearForWeekOfYear, .year]
        var smallestIndex: Int = 7
        for component in calendarComponentsSet {
            if let index = sortedUnits.firstIndex(where: { $0 == component}),
               index < smallestIndex {
                smallestIndex = index
            }
        }
        return sortedUnits[smallestIndex]
    }
    
    static func granularityByTimeRange(dateComponents: DateComponents) -> Set<Calendar.Component> {
        if dateComponents.year ?? 0 > 5 {
            return [.year, .month]
        } else if dateComponents.year ?? 0 > 0 {
            return [.yearForWeekOfYear, .weekOfYear]
        } else if dateComponents.month ?? 0 > 0 {
            return [.year, .month, .day]
        } else if dateComponents.day ?? 0 > 2 {
            return [.year, .month, .day, .hour]
        } else {
            return [.year, .month, .day, .hour, .minute]
        }
    }
    
    static func granularityByPartition(partitionName: GraphPartitions, earliestDate: Date, now: Date) -> Set<Calendar.Component> {
        switch partitionName {
        case .oneDay: return [.year, .month, .day, .hour, .minute]
        case .oneWeek: return [.year, .month, .day, .hour]
        case .oneMonth: return [.year, .month, .day, .hour]
        case .threeMonths: return [.year, .month, .day]
        case .oneYear: return [.year, .month, .day]
        case .ytd:
            let startOfYear = calendar.dateInterval(of: .year, for: now)!.start
            let components = calendar.dateComponents([.year, .month, .day], from: startOfYear, to: now)
            return granularityByTimeRange(dateComponents: components)
        case .all:
            let components = calendar.dateComponents([.year, .month, .day], from: earliestDate, to: now)
            return granularityByTimeRange(dateComponents: components)
        }
    }
    
    static func cutoffDateByPartition(partitionName: GraphPartitions, now: Date, earliestDate: Date) -> Date {
        let calendar = calendar
        switch partitionName {
        case .oneDay:
            return calendar.dateInterval(of: .day, for: now)!.start
        case .oneWeek:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        case .oneMonth:
            return calendar.date(byAdding: .month, value: -1, to: now)!
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: now)!
        case .oneYear:
            return calendar.date(byAdding: .year, value: -1, to: now)!
        case .ytd:
            return calendar.dateInterval(of: .year, for: now)!.start
        case .all:
            return earliestDate
        }
    }
    
    static func getDefaultGranularity(partitionType: GraphPartitions) -> Calendar.Component {
        switch partitionType {
        case .oneDay:
            return .minute
        case .oneWeek:
            return .hour
        case .oneMonth:
            return .hour
        case .threeMonths:
            return .day
        case .oneYear:
            return .day
        case .ytd:
            return .day
        case .all:
            return .month
        }
    }
    
    static func createDefaultGraphData(now: Date, earliestDate: Date) -> [[StockDataPoint]] {
        var defaultDataList: [[StockDataPoint]] = []
        for partitionType in GraphPartitions.allCases {
            var partitionDefaultData: [StockDataPoint] = []
            var currDate: Date = cutoffDateByPartition(partitionName: partitionType, now: now, earliestDate: earliestDate)
            while currDate < now {
                partitionDefaultData.append(StockDataPoint(date: currDate, price: 0))
                currDate = calendar.date(byAdding: getDefaultGranularity(partitionType: partitionType), value: 1, to: currDate)!
            }
            partitionDefaultData.append(StockDataPoint(date: now, price: 0))
            defaultDataList.append(partitionDefaultData)
        }
        defaultDataList.insert([], at: 6) // for the now removed 5y partition
        return defaultDataList
    }
    
    static func groupPartition(partition: [StockDataPoint], dateComponentsToGroupBy: Set<Calendar.Component>) -> [StockDataPoint] {
        let calendar = calendar
        var groupedPartition: [StockDataPoint] = []
        var prevGroupDate: Date?
        do {
            for dataPoint in partition {
                let components = calendar.dateComponents(dateComponentsToGroupBy, from: dataPoint.date)
                guard let groupDate = calendar.date(from: components) else {
                    throw DateParsingError.dateComputationError
                }
                if prevGroupDate != groupDate {
                    prevGroupDate = groupDate
                    groupedPartition.append(dataPoint)
                }
            }
        } catch {
            groupedPartition = []
        }
        return groupedPartition
    }
    
    static func getGraphDataPartition(graphData: [StockDataPoint], partitionType: GraphPartitions, earliestDate: Date, now: Date) -> [StockDataPoint] {
        let partition: [StockDataPoint]
        let cutoffDate = cutoffDateByPartition(partitionName: partitionType, now: now, earliestDate: earliestDate)
        if let startIndex = graphData.firstIndex(where: { $0.date >= cutoffDate }) {
            partition = Array(graphData[startIndex...])
        } else {
            partition = []
        }
        
        let granularity = granularityByPartition(partitionName: partitionType, earliestDate: earliestDate, now: now)
        let groupedPartition = groupPartition(partition: partition, dateComponentsToGroupBy: granularity)
        return groupedPartition
    }
    
    static func getGraphDataPartitions(graphData: [StockDataPoint], earliestDate: Date, now: Date) -> [[StockDataPoint]] {
        var partitions: [[StockDataPoint]] = []
        for partitionType in GraphPartitions.allCases {
            partitions.append(getGraphDataPartition(graphData: graphData, partitionType: partitionType, earliestDate: earliestDate, now: now))
        }
        return partitions
    }
    
    static func startingValuesPerGraphDataGroup(graphDataPartitions: [[StockDataPoint]]) -> [Double] {
        var resultList: [Double] = []
        for i in 0..<graphDataPartitions.count-1 {
            let earlierPeriod = graphDataPartitions[i]
            let olderPeriod = graphDataPartitions[i+1]
            var recentmostOlderPeriodPrice: Double = 0
            if let oldestEarlierPeriodDate = earlierPeriod.first?.date,
               let startIndex = olderPeriod.lastIndex(where: { $0.date < oldestEarlierPeriodDate }) {
                recentmostOlderPeriodPrice = olderPeriod[startIndex].price
            }
            resultList.append(recentmostOlderPeriodPrice)
        }
        resultList.append(0)
        return resultList
    }
    
    // truncate everything
    static func truncateDate(date: Date, granularity: Set<Calendar.Component>) -> Date {
        var components = DateComponents()
        for component in granularity {
            let componentValue = calendar.component(component, from: date)
            components.setValue(componentValue, for: component)
        }
        return calendar.date(from: components)!
    }
    
    static func fillGaps(
        data: [StockDataPoint],
        partitionType: GraphPartitions,
        startValue: Double,
        earliestDate: Date,
        now: Date
    ) -> [StockDataPoint] {
        var augmentedData = data
        var filled: [StockDataPoint] = []
        let granularity = granularityByPartition(partitionName: partitionType, earliestDate: earliestDate, now: now)
        let smallestUnit = getSmallestUnit(calendarComponentsSet: granularity)
        let calendar = calendar
        
        let startDate = cutoffDateByPartition(partitionName: partitionType, now: now, earliestDate: earliestDate)
        let startDateTruncated = truncateDate(date: startDate, granularity: granularity)
        let endDateTruncated = truncateDate(date: now, granularity: granularity)
        
        if let firstDataPointDate = data.first?.date,
           startDateTruncated < truncateDate(date: firstDataPointDate, granularity: granularity) {
            augmentedData.insert(StockDataPoint(date: startDateTruncated, price: startValue), at: 0)
        }
        if let lastDataPointDate = data.last?.date, let lastDataPointPrice = data.last?.price,
           endDateTruncated > truncateDate(date: lastDataPointDate, granularity: granularity) {
            augmentedData.append(StockDataPoint(date: endDateTruncated, price: lastDataPointPrice))
        }
        
        for i in 0..<augmentedData.count - 1 {
            let current = augmentedData[i]
            let currentDate = truncateDate(date: current.date, granularity: granularity)
            let next = augmentedData[i + 1]
            let nextDate = truncateDate(date: next.date, granularity: granularity)
            
            filled.append(current)
            
            var fillerTime = calendar.date(byAdding: smallestUnit, value: 1, to: currentDate)!
            while fillerTime < nextDate {
                filled.append(StockDataPoint(date: fillerTime, price: current.price))
                fillerTime = calendar.date(byAdding: smallestUnit, value: 1, to: fillerTime)!
            }
        }

        filled.append(augmentedData.last!)
        return filled
    }
    
    static func fillGapsInGraphDataPartitions(partitions: [[StockDataPoint]], startingValues: [Double], earliestDate: Date, now: Date) -> [[StockDataPoint]] {
        var gapsFilledPartitions: [[StockDataPoint]] = []
        for i in GraphPartitions.allCases.indices {
            let gapsFilledPartition = fillGaps(
                data: partitions[i],
                partitionType: GraphPartitions.allCases[i],
                startValue: startingValues[i],
                earliestDate: earliestDate,
                now: now
            )
            gapsFilledPartitions.append(gapsFilledPartition)
        }
        return gapsFilledPartitions
    }
    
    
    static func processGraphData(graphData: [StockDataPoint], now: Date) -> [[StockDataPoint]] {
        let earliestDate: Date
        if let firstInvestmentIndex = graphData.firstIndex(where: {$0.price > 0}) {
            earliestDate = graphData[firstInvestmentIndex].date
        } else {
            earliestDate = calendar.date(byAdding: .year, value: -5, to: now)!
        }
        
        let defaults = createDefaultGraphData(now: now, earliestDate: earliestDate)
        let partitions = getGraphDataPartitions(graphData: graphData, earliestDate: earliestDate, now: now)
        let startingValues = startingValuesPerGraphDataGroup(graphDataPartitions: partitions)
        let filledGaps = fillGapsInGraphDataPartitions(partitions: partitions, startingValues: startingValues, earliestDate: earliestDate, now: now)
        
        var result = filledGaps
        for i in result.indices {
            if result[i].count < 2 {
                result[i] = defaults[i]
            }
        }
        result.insert([], at: 6) // for the 5y partition which is now removed
        return result
    }
    
    static func getColors(graphData: [[StockDataPoint]]) -> [Color] {
        var colors: [Color] = []
        for partitionData in graphData {
            colors.append(getPartitionColor(partitionData: partitionData))
        }
        return colors
    }
    
    static func getPartitionColor(partitionData: [StockDataPoint]) -> Color {
        guard partitionData.count > 1 else { return .gray }
        let change = partitionData.last!.price - partitionData[0].price
        if change > 0 {
            return .green
        } else if change < 0 {
            return .red
        } else {
            return .gray
        }
    }
}
