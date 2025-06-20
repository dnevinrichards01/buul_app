//
//  CoreDataStockManager.swift
//  accumate_app
//
//  Created by Nevin Richards on 5/14/25.
//

import Foundation
import SwiftUI
import LocalAuthentication
import CoreData

class CoreDataStockManager {
    static let shared = CoreDataStockManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "CoreStockDataPoint") // your .xcdatamodeld name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save(series: [[StockDataPoint]]) {
        
        let backgroundContext = container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        backgroundContext.perform {
//            print("core data save")
            
            for i in series.indices {
                let dataPoints = series[i]
                let stockSeries = CoreStockSeries(context: backgroundContext)
                stockSeries.id = UUID()
                stockSeries.i = Int16(i)
                
                for point in dataPoints {
                    let stockPoint = CoreStockDataPoint(context: backgroundContext)
                    stockPoint.date = point.date
                    stockPoint.price = point.price
                    stockPoint.series = stockSeries // link the point to the series
                }
            }
            
            do {
                try backgroundContext.save()
            } catch {
//                print("Failed to save: \(error)")
            }
        }
    }

    // MARK: - Load from Core Data
    func fetchAllSeries() async -> [Int: [StockDataPoint]] {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return await withCheckedContinuation { continuation in
            backgroundContext.perform {
                let request: NSFetchRequest<CoreStockSeries> = CoreStockSeries.fetchRequest()
                // force core data to full pull the data and its relationships
                request.returnsObjectsAsFaults = false
                request.relationshipKeyPathsForPrefetching = ["dataPoints"]
                
                do {
                    let seriesList = try backgroundContext.fetch(request)
                    let result: [Int: [StockDataPoint]] = seriesList.reduce(into: [:]) { dict, series in
                        // Skip deleted or incomplete objects
                        _ = series.i // force load so won't get 'isfault'
                        guard !series.isFault, !series.isDeleted else {
//                            print("Skipping invalid series object: \(series)")
                            return
                        }
                        let points: [CoreStockDataPoint] = series.dataPoints?.allObjects as? [CoreStockDataPoint] ?? []
                        //                let points: [CoreStockDataPoint] = Array(series.dataPoints as? Set<CoreStockDataPoint> ?? [])
                        let stockPoints: [StockDataPoint] = points
                            .filter { !$0.isFault && !$0.isDeleted }
                            .sorted { $0.date ?? Date() < $1.date ?? Date()}
                            .compactMap { (point: CoreStockDataPoint) in
                                guard let date = point.date else { return nil }
                                return StockDataPoint(date: date, price: point.price)
                            }
                        dict[Int(series.i)] = stockPoints
                    }
                    continuation.resume(returning: result)
                } catch {
//                    print("Failed to fetch series: \(error)")
                    continuation.resume(returning: [:])
                }
            }
        }
    }

    // MARK: - Optional: Clear All
    func clearAll() {
        let backgroundContext = container.newBackgroundContext()

        backgroundContext.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = CoreStockSeries.fetchRequest()
            let delete = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try backgroundContext.execute(delete)
                try backgroundContext.save()
                // i wonder if reset may cause crash if not yet logged out but you tried logging out and you go back to graph page
                backgroundContext.reset()
//                print("All series and data points cleared.")
            } catch {
//                print("Failed to clear: \(error)")
            }
        }
    }
}
