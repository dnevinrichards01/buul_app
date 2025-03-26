//
//  Utils.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/5/25.
//

import SwiftUI

class Utils {
    
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static func nilOrEmptyString(_ str: String?) -> Bool {
        return str == nil || str == ""
    }
    
    static func compactMapKeys<T: Hashable>(dictionary: [String: String?], transform: (String) -> T?) -> [T: String?] {
        var newDict: [T: String?] = [:]
        for (key, value) in dictionary {
            if let newKey = transform(key) {
                newDict[newKey] = value
            }
        }
        return newDict
    }
    
    static func camelCaseToSnakeCase(_ input: String) -> String {
        let pattern = "([a-z0-9])([A-Z])" // Matches lowercase/number followed by uppercase
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        let snakeCase = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "$1_$2")
        return snakeCase.lowercased()
    }
    
    static func camelCaseToSpaces(_ input: String) -> String {
        let pattern = "([a-z0-9])([A-Z])" // Matches lowercase/number followed by uppercase
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        let snakeCase = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "$1 $2")
        return snakeCase.lowercased()
    }
    
    static func snakeCaseToCamelCase(_ input: String) -> String {
        let words = input.split(separator: "_")
        let firstWord = words.first?.lowercased() ?? ""
        let capitalizedWords = words.dropFirst().map { $0.capitalized }
        return ([firstWord] + capitalizedWords).joined()
    }
    
    static func getOTPEndpoint(_ signUpField: SignUpFields, _ authenticate: Bool) -> String {
        if !authenticate && signUpField == .password {
            return "api/user/resetpassword/"
        } else if !authenticate && (signUpField == .email || signUpField == .phoneNumber) {
            return "api/user/emailphonesignupvalidation/"
        } else {
            return "api/user/requestverificationcode/"
        }
    }
    
    static func getSignUpFieldsValidateEndpoint(_ signUpField: SignUpFields) -> String {
        if [.brokerage, .symbol].contains(signUpField) {
            return "api/user/setbrokerageinvestment/"
        } else  {
            return "api/user/namepasswordvalidation/"
        }
    }
    
    static func truncateTo6Digits(text: String) -> String {
        let digitsOnly = text.filter { $0.isNumber }
        if digitsOnly.count <= 6 {
            return digitsOnly
        } else {
            return String(digitsOnly.prefix(6))
        }
    }
    
    static func getIndex(text: String, index: Int) -> String {
        if let indexObject = text.index(text.startIndex, offsetBy: index, limitedBy: text.endIndex),
           text.count - 1 >= index {
            return String(text[indexObject])
        }
        return ""
    }
    
    static func getBrokerage(sessionManager: UserSessionManager, brokerageString: String? = nil) -> Brokerages? {
        let brokerageName: String? = brokerageString ?? sessionManager.brokerageName
        for brokerage in Brokerages.allCases {
            print(brokerage.rawValue, brokerageName)
            if brokerage.rawValue == brokerageName {
                return brokerage
            }
        }
        return nil
    }
    
    static func processDefaultGraphData(graphData: [RecieveStockDataPoint]) -> [[StockDataPoint]] {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfDay = calendar.dateInterval(of: .day, for: now)!.start
        let justAfterStartOfDay = calendar.date(byAdding: .minute, value: 1, to: startOfDay)!
        let defaultDay = [
            StockDataPoint(date: startOfDay, price: 0),
            StockDataPoint(date: max(now, justAfterStartOfDay), price: 0)
        ]
        let defaultWeek = [
            StockDataPoint(date: calendar.date(byAdding: .weekOfYear, value: -1, to: now)!, price: 0),
            StockDataPoint(date: now, price: 0)
        ]
        let defaultMonth = [
            StockDataPoint(date: calendar.date(byAdding: .month, value: -1, to: now)!, price: 0),
            StockDataPoint(date: now, price: 0)
        ]
        let defaultThreeMonths = [
            StockDataPoint(date: calendar.date(byAdding: .month, value: -3, to: now)!, price: 0),
            StockDataPoint(date: now, price: 0)
        ]
        let startOfYear = calendar.dateInterval(of: .year, for: now)!.start
        let justAfterStartOfYear = calendar.date(byAdding: .day, value: 1, to: startOfYear)!
        let defaultYtd = [
            StockDataPoint(date: startOfYear, price: 0),
            StockDataPoint(date: max(now, justAfterStartOfYear), price: 0)
        ]
        let defaultYear = [
            StockDataPoint(date: calendar.date(byAdding: .year, value: -1, to: now)!, price: 0),
            StockDataPoint(date: now, price: 0)
        ]
        let defaultFiveYears = [
            StockDataPoint(date: calendar.date(byAdding: .year, value: -5, to: now)!, price: 0),
            StockDataPoint(date: now, price: 0)
        ]
        let defaultAll = [
            StockDataPoint(date: calendar.date(byAdding: .year, value: -5, to: now)!, price: 0),
            StockDataPoint(date: now, price: 0)
        ]
        let defaults = [defaultDay, defaultWeek, defaultMonth, defaultThreeMonths, defaultYtd, defaultYear, defaultFiveYears, defaultAll]
        
        var graphDataWithDates: [StockDataPoint]
        do {
            graphDataWithDates = try graphData.map {
                StockDataPoint(date: try Utils.isoformatToDate(isoDateString: $0.date), price: $0.price)
            }
        } catch {
            return defaults
        }
        
        // store the og unprocessed data, then reprocess as needed
        let graphDataWithDatesFilled = Utils.fillRecentMinuteGaps(data: graphDataWithDates)
        var day: [StockDataPoint]
        day = graphDataWithDatesFilled.filter {
            let cutoff = calendar.dateInterval(of: .day, for: now)!.start
            return $0.date >= cutoff
        }.sorted(by: { $0.date < $1.date })
        
        let week: [StockDataPoint]
        let month: [StockDataPoint]
        let hourlyGrouped: [Date : [StockDataPoint]]
        do {
            hourlyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = calendar.dateComponents([.year, .month, .day, .hour], from: $0.date)
                if let group = calendar.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            
            week = hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
            
            month = hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = calendar.date(byAdding: .month, value: -1, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
        } catch {
            week = defaultWeek
            month = defaultMonth
        }
        
        let threeMonths: [StockDataPoint]
        let ytd: [StockDataPoint]
        let year: [StockDataPoint]
        let dailyGrouped: [Date : [StockDataPoint]]
        do {
            dailyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            
            threeMonths = dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .month, value: -3, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
            ytd = dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = calendar.dateInterval(of: .year, for: now)!.start
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
            year = dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
        } catch {
            threeMonths = defaultThreeMonths
            ytd = defaultYtd
            year = defaultYear
        }
        
        let fiveYears: [StockDataPoint]
        let weeklyGrouped: [Date : [StockDataPoint]]
        do {
            weeklyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            fiveYears = weeklyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .year, value: -5, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
        } catch {
            fiveYears = defaultFiveYears
        }
        
        
        let all: [StockDataPoint]
        let monthlyGrouped: [Date : [StockDataPoint]]
        do {
            monthlyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            
            all = monthlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .sorted(by: { $0.date < $1.date })
        } catch {
            all = defaultAll
        }
        
        var result = [day, week, month, threeMonths, ytd, year, fiveYears, all]
//        print(result.count)
        for i in result.indices {
//            print(i, result[i].count)
            if result[i].count < 2 {
                result[i] = defaults[i]
                
            }
            print(i, result[i].count)
        }
        return result
    }
    
    // could split this up into multiple functions one for each view, more work when you switch views but more distributed
    static func processGraphData(graphData: [RecieveStockDataPoint], defaultData: [[StockDataPoint]]) -> [[StockDataPoint]] {
        let calendar = Calendar.current
        let now = Date()
        
        var graphDataWithDates: [StockDataPoint]
        do {
            graphDataWithDates = try graphData.map {
                StockDataPoint(date: try Utils.isoformatToDate(isoDateString: $0.date), price: $0.price)
            }
        } catch {
            print("default Data returned")
            return defaultData
        }
        
        // store the og unprocessed data, then reprocess as needed
        let graphDataWithDatesFilled = Utils.fillRecentMinuteGaps(data: graphDataWithDates)
        var day: [StockDataPoint]
        do {
            day = try graphDataWithDatesFilled.filter {
                if let cutoff = calendar.dateInterval(of: .day, for: now)?.start {
                    $0.date >= cutoff
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }.sorted(by: { $0.date < $1.date })
        } catch {
            print("default day")
            day = defaultData[0]
        }
        print("day count", day.count)
        
        let week: [StockDataPoint]
        let month: [StockDataPoint]
        let hourlyGrouped: [Date : [StockDataPoint]]
        do {
            hourlyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = calendar.dateComponents([.year, .month, .day, .hour], from: $0.date)
                if let group = calendar.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            
            week = hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
            
            month = hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .month, value: -1, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
        } catch {
            print("default by hours")
            week = defaultData[1]
            month = defaultData[2]
        }
        
        var threeMonths: [StockDataPoint]
        var ytd: [StockDataPoint]
        var year: [StockDataPoint]
        let dailyGrouped: [Date : [StockDataPoint]]
        do {
            dailyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            
            threeMonths = dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .month, value: -3, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
            ytd = dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = calendar.dateInterval(of: .year, for: now)!.start
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
            year = dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
        } catch {
            print("default by days")
            threeMonths = defaultData[3]
            ytd = defaultData[4]
            year = defaultData[5]
        }
        
        let fiveYears: [StockDataPoint]
        let weeklyGrouped: [Date : [StockDataPoint]]
        do {
            weeklyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            fiveYears = weeklyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    let cutoff = Calendar.current.date(byAdding: .year, value: -5, to: now)!
                    return $0.date >= cutoff
                }
                .sorted(by: { $0.date < $1.date })
        } catch {
            print("default 5y")
            fiveYears = defaultData[6]
        }
        
        
        let all: [StockDataPoint]
        let monthlyGrouped: [Date : [StockDataPoint]]
        do {
            monthlyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw Utils.DateParsingError.dateComputationError
                }
            }
            
            all = monthlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .sorted(by: { $0.date < $1.date })
        } catch {
            print("default all")
            all = defaultData[7]
        }
        
        var result = [day, week, month, threeMonths, ytd, year, fiveYears, all]
//        print(result.count)
        for i in result.indices {
            print(i, result[i].count)
            if result[i].count < 2 {
                result[i] = defaultData[i]
//                print(i, result[i].count)
            }
        }
        return result
    }
    
    static func fillRecentMinuteGaps(data: [StockDataPoint]) -> [StockDataPoint] {
        guard data.count > 1 else { return data }
        print("filling")

        var filled: [StockDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        let cutoffDate = calendar.date(byAdding: .hour, value: -24, to: now)!

        for i in 0..<data.count - 1 {
            let current = data[i]
            let next = data[i + 1]

            filled.append(current)

            // Only gap-fill if the current point is within the past 24 hours
            guard next.date >= cutoffDate else {
                continue
            }

            let gap = calendar.dateComponents([.minute], from: current.date, to: next.date).minute ?? 0

            if gap > 1 {
                print("filling one segment")
                var fillerTime = calendar.date(byAdding: .minute, value: 1, to: current.date)!
                for _ in 1..<gap {
                    // Only fill if filler point is within 24 hours
                    if fillerTime < cutoffDate { break }
                    filled.append(StockDataPoint(date: fillerTime, price: current.price))
                    fillerTime = calendar.date(byAdding: .minute, value: 1, to: fillerTime)!
                }
            }
        }

        filled.append(data.last!) // Don’t forget the last one
        return filled
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
}
