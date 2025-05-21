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
        print("core data save")

        for i in series.indices {
            let dataPoints = series[i]
            let stockSeries = CoreStockSeries(context: context)
            stockSeries.id = UUID()
            stockSeries.i = Int16(i)

            for point in dataPoints {
                let stockPoint = CoreStockDataPoint(context: context)
                stockPoint.date = point.date
                stockPoint.price = point.price
                stockPoint.series = stockSeries // link the point to the series
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    // MARK: - Load from Core Data
    func fetchAllSeries() -> [Int : [StockDataPoint]] {
        let request: NSFetchRequest<CoreStockSeries> = CoreStockSeries.fetchRequest()
        do {
            let seriesList = try context.fetch(request)
            return seriesList.reduce(into: [:]) { dict, series in
                // Skip deleted or incomplete objects
                guard !series.isFault, !series.isDeleted else {
                    print("Skipping invalid series object: \(series)")
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
        } catch {
            print("Failed to fetch series: \(error)")
            return [:]
        }
    }

    // MARK: - Optional: Clear All
    func clearAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = CoreStockSeries.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(delete)
            try context.save()
            context.reset()
            print("All series and data points cleared.")
        } catch {
            print("Failed to clear: \(error)")
        }
    }
}
